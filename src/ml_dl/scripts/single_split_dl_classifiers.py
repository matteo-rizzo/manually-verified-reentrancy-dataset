import glob
import os
import sys
import numpy as np
import gc
from collections import defaultdict
from typing import List, Tuple, Optional, Dict, Any

from sklearn.preprocessing import LabelEncoder
from sklearn.feature_extraction.text import TfidfVectorizer  # For FFNN
from sklearn.metrics import accuracy_score, classification_report, confusion_matrix

import torch
import torch.nn as nn
import torch.optim as optim
from torch.utils.data import Dataset, DataLoader
# from torchinfo import summary # Optional

from transformers import AutoTokenizer, AutoModel, AutoModelForSequenceClassification, AdamW, \
    get_linear_schedule_with_warmup

# --- Configuration ---
RANDOM_SEED: int = 0
np.random.seed(RANDOM_SEED)
torch.manual_seed(RANDOM_SEED)
if torch.cuda.is_available():
    torch.cuda.manual_seed_all(RANDOM_SEED)

DEVICE = torch.device("cuda" if torch.cuda.is_available() else "cpu")
print(f"Using device: {DEVICE}")

BASE_PROJECT_PATH: str = "dataset/cv_splits_manually_verified_handcrafted"
FOLD_DIRECTORIES: List[str] = ["cv_split_1", "cv_split_2", "cv_split_3"]
# FOLD_DIRECTORIES: List[str] = ["cv_split_1"] # For faster testing
N_FOLDS: int = len(FOLD_DIRECTORIES)

# DL Model General Parameters
MAX_LEN_CODEBERT_INPUT: int = 128  # For CodeBERT tokenizer (both fine-tuning and embedding extraction)
TFIDF_MAX_FEATURES_FFNN: int = 4500  # Max features for TF-IDF used by FFNN
BATCH_SIZE: int = 1
EPOCHS: int = 15  # Start low for testing
# EPOCHS: int = 1 # For faster testing

LEARNING_RATE_FFNN: float = 1e-3
LEARNING_RATE_LSTM: float = 1e-3
LEARNING_RATE_CODEBERT_FINETUNE: float = 2e-5

# Model Specific Parameters
LSTM_UNITS: int = 128  # LSTM hidden units
LSTM_NUM_LAYERS: int = 1
FFNN_HIDDEN_UNITS: int = 128  # Hidden units for FFNN
DROPOUT_RATE: float = 0.3
CODEBERT_MODEL_NAME: str = "microsoft/codebert-base"  # Used for fine-tuning and as base for LSTM embeddings

METRICS_TO_AVERAGE: Dict[str, str] = {
    "accuracy": "Accuracy", "precision_macro": "Macro Precision", "recall_macro": "Macro Recall",
    "f1_macro": "Macro F1-score", "precision_weighted": "Weighted Precision",
    "recall_weighted": "Weighted Recall", "f1_weighted": "Weighted F1-score"
}


# --- Helper: Data Loading (same as before) ---
def load_solidity_contracts(folder_path: str) -> Tuple[Optional[List[str]], Optional[List[str]]]:
    if not os.path.isdir(folder_path):
        print(f"Error: Data folder not found: {folder_path}")
        return None, None
    texts: List[str] = []
    labels: List[str] = []
    class_subdirectories = [d for d in os.listdir(folder_path) if os.path.isdir(os.path.join(folder_path, d))]
    if not class_subdirectories:
        print(f"Error: No class subdirectories found in {folder_path}")
        return None, None
    # print(f"Loading data from: {folder_path}") # Less verbose for this version
    for class_name in class_subdirectories:
        class_dir_path = os.path.join(folder_path, class_name)
        sol_files = glob.glob(os.path.join(class_dir_path, "*.sol"))
        if not sol_files: continue
        for file_path in sol_files:
            try:
                with open(file_path, 'r', encoding='utf-8', errors='ignore') as f_contract:
                    texts.append(f_contract.read())
                    labels.append(class_name)
            except Exception as e:
                print(f"Error reading file {file_path}: {e}")
    if not texts:
        print(f"Error: No contracts loaded from {folder_path}.")
        return None, None
    return texts, labels


def record_nan_for_all_metrics(classifier_name: str, metrics_storage: defaultdict):
    for metric_key in METRICS_TO_AVERAGE.keys():
        metrics_storage[classifier_name][metric_key].append(np.nan)


# --- PyTorch Dataset Class ---
class SolidityCustomDataset(Dataset):
    def __init__(self, data_inputs: Any, labels: np.ndarray, model_type: str,
                 hf_tokenizer: Optional[AutoTokenizer] = None, max_len_hf: Optional[int] = None):
        self.data_inputs = data_inputs  # Can be raw texts, TF-IDF features, or CodeBERT embeddings
        self.labels = labels
        self.model_type = model_type
        self.hf_tokenizer = hf_tokenizer  # Only for 'codebert_finetune'
        self.max_len_hf = max_len_hf  # Only for 'codebert_finetune'

    def __len__(self):
        return len(self.labels)

    def __getitem__(self, idx):
        label = torch.tensor(self.labels[idx], dtype=torch.long)

        if self.model_type == "codebert_finetune":
            text = self.data_inputs[idx]  # Raw text
            if not self.hf_tokenizer or not self.max_len_hf:
                raise ValueError("Tokenizer and max_len must be provided for CodeBERT fine-tuning.")
            encoding = self.hf_tokenizer.encode_plus(
                text, add_special_tokens=True, max_length=self.max_len_hf,
                padding='max_length', truncation=True, return_attention_mask=True,
                return_tensors='pt'
            )
            return {
                'input_ids': encoding['input_ids'].flatten(),
                'attention_mask': encoding['attention_mask'].flatten()
            }, label

        elif self.model_type == "ffnn_tfidf":
            # data_inputs are precomputed TF-IDF features (numpy array or sparse matrix row)
            features = self.data_inputs[idx]
            if not isinstance(features, np.ndarray):  # Handle sparse matrix row if necessary
                features = features.toarray().squeeze()
            return torch.tensor(features, dtype=torch.float), label

        elif self.model_type == "lstm_codebert_emb":
            # data_inputs are precomputed CodeBERT embedding sequences (numpy array)
            embedding_sequence = self.data_inputs[idx]
            return torch.tensor(embedding_sequence, dtype=torch.float), label

        else:
            raise ValueError(f"Unsupported model_type in Dataset: {self.model_type}")


# --- PyTorch Model Definitions ---
class FFNN_TFIDF(nn.Module):
    def __init__(self, input_features_dim: int, hidden_units: int, num_classes: int, dropout_rate: float):
        super(FFNN_TFIDF, self).__init__()
        self.fc1 = nn.Linear(input_features_dim, hidden_units)
        self.relu = nn.ReLU()
        self.dropout = nn.Dropout(dropout_rate)
        self.fc2 = nn.Linear(hidden_units, num_classes)

    def forward(self, x):  # x shape: (batch_size, input_features_dim)
        out = self.fc1(x)
        out = self.relu(out)
        out = self.dropout(out)
        out = self.fc2(out)
        return out


class LSTM_with_CodeBERT_Embeddings(nn.Module):
    def __init__(self, codebert_embedding_dim: int, lstm_units: int, num_layers: int,
                 num_classes: int, dropout_rate: float, bidirectional: bool = False):
        super(LSTM_with_CodeBERT_Embeddings, self).__init__()
        self.lstm = nn.LSTM(codebert_embedding_dim, lstm_units, num_layers=num_layers,
                            batch_first=True, dropout=dropout_rate if num_layers > 1 else 0,
                            bidirectional=bidirectional)
        self.dropout = nn.Dropout(dropout_rate)
        fc_input_dim = lstm_units * 2 if bidirectional else lstm_units
        self.fc = nn.Linear(fc_input_dim, num_classes)

    def forward(self, x):  # x shape: (batch_size, seq_len, codebert_embedding_dim)
        lstm_out, (h_n, _) = self.lstm(x)
        # Use the hidden state of the last layer's last time step
        if self.lstm.bidirectional:
            out = torch.cat((h_n[-2, :, :], h_n[-1, :, :]), dim=1)
        else:
            out = h_n[-1, :, :]
        out = self.dropout(out)
        out = self.fc(out)
        return out


# --- Helper: Extract CodeBERT Embeddings (for LSTM) ---
def extract_codebert_embeddings(texts: List[str], model_name: str, tokenizer_name: str,
                                max_len: int, device: torch.device, batch_size: int = 32) -> np.ndarray:
    print(f"Extracting CodeBERT embeddings using {model_name}...")
    tokenizer = AutoTokenizer.from_pretrained(tokenizer_name)
    embedder_model = AutoModel.from_pretrained(model_name).to(device)
    for param in embedder_model.parameters():  # Freeze the embedder
        param.requires_grad = False
    embedder_model.eval()

    all_embeddings_list = []
    for i in range(0, len(texts), batch_size):
        batch_texts = texts[i:i + batch_size]
        inputs = tokenizer(batch_texts, return_tensors='pt', padding='max_length',
                           truncation=True, max_length=max_len).to(device)
        with torch.no_grad():
            outputs = embedder_model(**inputs)
            # Use last_hidden_state as token embeddings
            # Shape: (batch_size, sequence_length, hidden_size)
            last_hidden_states = outputs.last_hidden_state.cpu().numpy()
            all_embeddings_list.append(last_hidden_states)
        print(f"  Processed batch {i // batch_size + 1}/{(len(texts) - 1) // batch_size + 1}")

    del embedder_model, tokenizer
    torch.cuda.empty_cache()
    gc.collect()
    return np.concatenate(all_embeddings_list, axis=0)


# --- Training and Evaluation Functions (mostly same as before) ---
def train_epoch_pytorch(model, data_loader, loss_fn, optimizer, device, scheduler=None, model_type="generic"):
    model.train()
    total_loss = 0
    correct_predictions = 0
    total_samples = 0

    for batch_idx, batch_data in enumerate(data_loader):
        targets = batch_data[1].to(device)
        if model_type == "codebert_finetune":  # Input is a dict
            input_ids = batch_data[0]['input_ids'].to(device)
            attention_mask = batch_data[0]['attention_mask'].to(device)
            outputs = model(input_ids, attention_mask=attention_mask).logits
        else:  # Input is a single tensor (TF-IDF or CodeBERT embeddings)
            inputs = batch_data[0].to(device)
            outputs = model(inputs)

        loss = loss_fn(outputs, targets)
        total_loss += loss.item() * targets.size(0)

        _, preds = torch.max(outputs, dim=1)
        correct_predictions += torch.sum(preds == targets).item()
        total_samples += targets.size(0)

        optimizer.zero_grad()
        loss.backward()
        nn.utils.clip_grad_norm_(model.parameters(), max_norm=1.0)
        optimizer.step()
        if scheduler:
            scheduler.step()

    avg_loss = total_loss / total_samples
    avg_accuracy = correct_predictions / total_samples
    return avg_loss, avg_accuracy


def evaluate_model_pytorch(model, data_loader, loss_fn, device, model_type="generic"):
    model.eval()
    total_loss = 0
    correct_predictions = 0
    total_samples = 0
    all_preds_encoded = []
    all_targets_encoded = []

    with torch.no_grad():
        for batch_idx, batch_data in enumerate(data_loader):
            targets = batch_data[1].to(device)
            if model_type == "codebert_finetune":
                input_ids = batch_data[0]['input_ids'].to(device)
                attention_mask = batch_data[0]['attention_mask'].to(device)
                outputs = model(input_ids, attention_mask=attention_mask).logits
            else:
                inputs = batch_data[0].to(device)
                outputs = model(inputs)

            loss = loss_fn(outputs, targets)  # Can be optional if only evaluating
            total_loss += loss.item() * targets.size(0)

            _, preds = torch.max(outputs, dim=1)
            correct_predictions += torch.sum(preds == targets).item()
            total_samples += targets.size(0)

            all_preds_encoded.extend(preds.cpu().numpy())
            all_targets_encoded.extend(targets.cpu().numpy())

    avg_loss = total_loss / total_samples
    avg_accuracy = correct_predictions / total_samples
    return avg_loss, avg_accuracy, np.array(all_preds_encoded), np.array(all_targets_encoded)


# --- Main Script ---
def run_pytorch_dl_cv_custom():
    print("--- Solidity Contract Classification (PyTorch Custom DL CV) ---")
    print(f"Device: {DEVICE}, Folds: {N_FOLDS}, Epochs: {EPOCHS}, Batch: {BATCH_SIZE}")

    all_folds_classifier_metrics: defaultdict = defaultdict(lambda: defaultdict(list))

    for fold_index, fold_dir_name in enumerate(FOLD_DIRECTORIES):
        current_fold_num = fold_index + 1
        print(f"\n\n{'=' * 20} Processing Fold {current_fold_num}/{N_FOLDS}: {fold_dir_name} {'=' * 20}")

        fold_base_path = os.path.join(BASE_PROJECT_PATH, fold_dir_name)
        train_data_path = os.path.join(fold_base_path, "train")
        test_data_path = os.path.join(fold_base_path, "test")

        if not os.path.isdir(fold_base_path):
            print(f"SKIP: Base path for fold '{fold_dir_name}' not found.")
            for clf_key in ["ffnn_tfidf", "lstm_codebert_emb", "codebert_finetune"]: record_nan_for_all_metrics(clf_key,
                                                                                                                all_folds_classifier_metrics)
            continue

        print(f"\n--- [Fold {current_fold_num}] Loading Data ---")
        train_texts_fold, train_labels_str_fold = load_solidity_contracts(train_data_path)
        test_texts_fold, test_labels_str_fold = load_solidity_contracts(test_data_path)

        if not all([train_texts_fold, train_labels_str_fold, test_texts_fold, test_labels_str_fold]):
            print(f"SKIP: Data loading failed for fold '{fold_dir_name}'.")
            for clf_key in ["ffnn_tfidf", "lstm_codebert_emb", "codebert_finetune"]: record_nan_for_all_metrics(clf_key,
                                                                                                                all_folds_classifier_metrics)
            continue

        label_encoder_fold = LabelEncoder()
        train_labels_encoded_fold = label_encoder_fold.fit_transform(train_labels_str_fold)
        test_labels_encoded_fold = label_encoder_fold.transform(test_labels_str_fold)
        num_classes_fold = len(label_encoder_fold.classes_)
        class_names_fold = label_encoder_fold.classes_
        print(f"Labels encoded. Num classes: {num_classes_fold}. Classes: {class_names_fold}")
        if num_classes_fold < 2:
            print(f"SKIP: At least two classes required. Found {num_classes_fold}.")
            for clf_key in ["ffnn_tfidf", "lstm_codebert_emb", "codebert_finetune"]: record_nan_for_all_metrics(clf_key,
                                                                                                                all_folds_classifier_metrics)
            continue

        # --- Classifier Loop ---
        # Note: Renamed clf_name keys to be more descriptive
        classifiers_to_run_pytorch = {
            #"ffnn_tfidf": {"lr": LEARNING_RATE_FFNN},
            #"lstm_codebert_emb": {"lr": LEARNING_RATE_LSTM},
            "codebert_finetune": {"lr": LEARNING_RATE_CODEBERT_FINETUNE, "model_name": CODEBERT_MODEL_NAME}
        }

        for clf_name, clf_params in classifiers_to_run_pytorch.items():
            print(f"\n----- Classifier: {clf_name.upper()} (Fold {current_fold_num}) -----")
            torch.cuda.empty_cache();
            gc.collect()
            model_pt, optimizer_pt, scheduler_pt = None, None, None
            train_dataset_pt, test_dataset_pt = None, None

            # --- Data Preparation for Current Classifier ---
            if clf_name == "ffnn_tfidf":
                print("Preparing TF-IDF features for FFNN...")
                tfidf_vectorizer = TfidfVectorizer(max_features=TFIDF_MAX_FEATURES_FFNN)
                X_train_tfidf_sparse = tfidf_vectorizer.fit_transform(train_texts_fold)
                X_test_tfidf_sparse = tfidf_vectorizer.transform(test_texts_fold)

                # Convert to dense numpy arrays for PyTorch Dataset
                X_train_data_processed = X_train_tfidf_sparse.toarray()
                X_test_data_processed = X_test_tfidf_sparse.toarray()

                current_input_features_dim = X_train_data_processed.shape[1]
                print(f"TF-IDF features created with shape: {X_train_data_processed.shape}")

                train_dataset_pt = SolidityCustomDataset(X_train_data_processed, train_labels_encoded_fold, clf_name)
                test_dataset_pt = SolidityCustomDataset(X_test_data_processed, test_labels_encoded_fold, clf_name)
                model_pt = FFNN_TFIDF(current_input_features_dim, FFNN_HIDDEN_UNITS, num_classes_fold, DROPOUT_RATE)
                optimizer_pt = optim.Adam(model_pt.parameters(), lr=clf_params["lr"])

            elif clf_name == "lstm_codebert_emb":
                print("Extracting CodeBERT embeddings for LSTM...")
                # Extract embeddings using the base CodeBERT model (frozen)
                X_train_codebert_embeddings = extract_codebert_embeddings(
                    train_texts_fold, CODEBERT_MODEL_NAME, CODEBERT_MODEL_NAME,
                    # Using same name for model and tokenizer
                    MAX_LEN_CODEBERT_INPUT, DEVICE, BATCH_SIZE
                )
                X_test_codebert_embeddings = extract_codebert_embeddings(
                    test_texts_fold, CODEBERT_MODEL_NAME, CODEBERT_MODEL_NAME,
                    MAX_LEN_CODEBERT_INPUT, DEVICE, BATCH_SIZE
                )
                codebert_hidden_size = X_train_codebert_embeddings.shape[-1]  # Should be 768 for base
                print(f"CodeBERT embeddings extracted. Train shape: {X_train_codebert_embeddings.shape}")

                train_dataset_pt = SolidityCustomDataset(X_train_codebert_embeddings, train_labels_encoded_fold,
                                                         clf_name)
                test_dataset_pt = SolidityCustomDataset(X_test_codebert_embeddings, test_labels_encoded_fold, clf_name)
                model_pt = LSTM_with_CodeBERT_Embeddings(codebert_hidden_size, LSTM_UNITS, LSTM_NUM_LAYERS,
                                                         num_classes_fold, DROPOUT_RATE)
                optimizer_pt = optim.Adam(model_pt.parameters(), lr=clf_params["lr"])

            elif clf_name == "codebert_finetune":
                print(f"Preparing data for CodeBERT fine-tuning using {clf_params['model_name']}...")
                hf_tokenizer = AutoTokenizer.from_pretrained(clf_params['model_name'])
                # Raw texts are passed to Dataset, tokenization happens in __getitem__
                train_dataset_pt = SolidityCustomDataset(train_texts_fold, train_labels_encoded_fold, clf_name,
                                                         hf_tokenizer, MAX_LEN_CODEBERT_INPUT)
                test_dataset_pt = SolidityCustomDataset(test_texts_fold, test_labels_encoded_fold, clf_name,
                                                        hf_tokenizer, MAX_LEN_CODEBERT_INPUT)

                model_pt = AutoModelForSequenceClassification.from_pretrained(clf_params['model_name'],
                                                                              num_labels=num_classes_fold)
                optimizer_pt = AdamW(model_pt.parameters(), lr=clf_params["lr"], eps=1e-8)
                total_steps = (len(train_dataset_pt) // BATCH_SIZE + (
                    1 if len(train_dataset_pt) % BATCH_SIZE != 0 else 0)) * EPOCHS
                scheduler_pt = get_linear_schedule_with_warmup(optimizer_pt, num_warmup_steps=0,
                                                               num_training_steps=total_steps)

            else:
                continue  # Should not happen

            model_pt.to(DEVICE)
            train_loader = DataLoader(train_dataset_pt, batch_size=BATCH_SIZE, shuffle=True, num_workers=0)
            test_loader = DataLoader(test_dataset_pt, batch_size=BATCH_SIZE, shuffle=False, num_workers=0)
            loss_fn_pt = nn.CrossEntropyLoss().to(DEVICE)

            # --- Training & Evaluation ---
            best_val_loss = float('inf')
            epochs_no_improve = 0
            patience_early_stopping = 50

            try:
                for epoch in range(EPOCHS):
                    print(f"Epoch {epoch + 1}/{EPOCHS}")
                    train_loss, train_acc = train_epoch_pytorch(model_pt, train_loader, loss_fn_pt, optimizer_pt,
                                                                DEVICE, scheduler_pt, clf_name)
                    val_loss, val_acc, _, _ = evaluate_model_pytorch(model_pt, test_loader, loss_fn_pt, DEVICE,
                                                                     clf_name)
                    print(
                        f"  Train Loss: {train_loss:.4f}, TA: {train_acc:.4f} | Val Loss: {val_loss:.4f}, VA: {val_acc:.4f}")

                    if val_loss < best_val_loss:
                        best_val_loss = val_loss
                        epochs_no_improve = 0
                        # torch.save(model_pt.state_dict(), f"{clf_name}_fold{current_fold_num}_best.pth") # Optional
                    else:
                        epochs_no_improve += 1
                    if epochs_no_improve >= patience_early_stopping:
                        print(f"Early stopping at epoch {epoch + 1}.")
                        break

                # (Optional: Load best model if saved)
                print(f"\nFinal evaluation for {clf_name} on test set (Fold {current_fold_num})...")
                _, _, y_pred_classes_fold, y_true_classes_fold = evaluate_model_pytorch(model_pt, test_loader,
                                                                                        loss_fn_pt, DEVICE, clf_name)

                accuracy_val = accuracy_score(y_true_classes_fold, y_pred_classes_fold)
                report_dict = classification_report(y_true_classes_fold, y_pred_classes_fold,
                                                    target_names=class_names_fold,
                                                    labels=np.arange(len(class_names_fold)), zero_division=0,
                                                    output_dict=True)
                cm = confusion_matrix(y_true_classes_fold, y_pred_classes_fold, labels=np.arange(len(class_names_fold)))

                all_folds_classifier_metrics[clf_name]['accuracy'].append(accuracy_val)
                all_folds_classifier_metrics[clf_name]['precision_macro'].append(report_dict['macro avg']['precision'])
                all_folds_classifier_metrics[clf_name]['recall_macro'].append(report_dict['macro avg']['recall'])
                all_folds_classifier_metrics[clf_name]['f1_macro'].append(report_dict['macro avg']['f1-score'])
                all_folds_classifier_metrics[clf_name]['precision_weighted'].append(
                    report_dict['weighted avg']['precision'])
                all_folds_classifier_metrics[clf_name]['recall_weighted'].append(report_dict['weighted avg']['recall'])
                all_folds_classifier_metrics[clf_name]['f1_weighted'].append(report_dict['weighted avg']['f1-score'])

                print(f"\n{clf_name} - Fold {current_fold_num} Results:")
                print(f"  Accuracy: {accuracy_val:.4f}")
                print(classification_report(y_true_classes_fold, y_pred_classes_fold, target_names=class_names_fold,
                                            labels=np.arange(len(class_names_fold)), zero_division=0))
                print("Confusion Matrix:\n", cm)

            except Exception as e_train_eval:
                print(f"!!! ERROR for {clf_name} in fold {current_fold_num}: {e_train_eval} !!!")
                import traceback;
                traceback.print_exc()
                record_nan_for_all_metrics(clf_name, all_folds_classifier_metrics)
            finally:
                del model_pt, optimizer_pt, scheduler_pt, train_loader, test_loader, train_dataset_pt, test_dataset_pt
                if 'tfidf_vectorizer' in locals(): del tfidf_vectorizer
                if 'hf_tokenizer' in locals(): del hf_tokenizer
                torch.cuda.empty_cache();
                gc.collect()

    # --- Overall CV Results ---
    print(f"\n\n{'=' * 30} Overall Cross-Validation Results {'=' * 30}")
    for clf_name_summary in ["ffnn_tfidf", "lstm_codebert_emb", "codebert_finetune"]:
        print(f"\n--- Summary for Classifier: {clf_name_summary.upper()} ---")
        if not all_folds_classifier_metrics[clf_name_summary]['accuracy']:
            print("  No results recorded.");
            continue
        for metric_key, metric_display_name in METRICS_TO_AVERAGE.items():
            scores = all_folds_classifier_metrics[clf_name_summary].get(metric_key, [])
            valid_scores = [s for s in scores if not np.isnan(s)]
            num_ok = len(valid_scores)
            print(f"  Metric: {metric_display_name}")
            scores_str = ", ".join([f"{s:.4f}" if not np.isnan(s) else "N/A" for s in scores])
            print(f"    - Fold Scores       : [{scores_str}]")
            if num_ok > 0:
                print(f"    - Average           : {np.mean(valid_scores):.4f}")
                print(f"    - Std. Deviation    : {np.std(valid_scores):.4f}")
                print(f"    - Successful Folds  : {num_ok}/{N_FOLDS}")
            else:
                print("    - No successful evaluations.")
            if 0 < num_ok < N_FOLDS: print(f"      (Calculated over {num_ok} of {N_FOLDS} folds.)")
        print("-" * 70)
    print("\n--- Script Finished ---")


if __name__ == "__main__":
    run_pytorch_dl_cv_custom()