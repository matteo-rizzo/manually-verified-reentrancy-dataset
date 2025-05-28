import glob
import os
import sys
from typing import List, Tuple, Optional, Dict, Any

import numpy as np
from sklearn.base import clone
from sklearn.ensemble import RandomForestClassifier, GradientBoostingClassifier
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import accuracy_score, classification_report, confusion_matrix
from sklearn.naive_bayes import GaussianNB, MultinomialNB
from sklearn.neighbors import KNeighborsClassifier
from sklearn.preprocessing import LabelEncoder
from sklearn.svm import SVC
from sklearn.decomposition import PCA  # Import PCA
from xgboost import XGBClassifier
from collections import defaultdict

# --- Configuration ---
RANDOM_SEED: int = 0
DEVICE: str = "cpu"

# Path Configuration
BASE_PROJECT_PATH: str = "dataset/cv_splits_manually_verified_handcrafted"
FOLD_DIRECTORIES: List[str] = ["cv_split_1", "cv_split_2", "cv_split_3"]
N_FOLDS: int = len(FOLD_DIRECTORIES)

# XGBoost GPU Configuration
USE_GPU_FOR_XGBOOST: bool = DEVICE != "cpu"

# TF-IDF Configuration
TFIDF_MAX_FEATURES: int = 4500

# PCA Configuration
APPLY_PCA: bool = True  # Set to False to disable PCA
PCA_N_COMPONENTS: int = 530  # Number of principal components to keep
# Alternatively, use a float for variance explained, e.g., 0.95
# PCA_N_COMPONENTS: float = 0.95

if APPLY_PCA and isinstance(PCA_N_COMPONENTS, int) and PCA_N_COMPONENTS > TFIDF_MAX_FEATURES:
    print(
        f"Warning: PCA_N_COMPONENTS ({PCA_N_COMPONENTS}) is greater than TFIDF_MAX_FEATURES ({TFIDF_MAX_FEATURES}). Adjusting PCA_N_COMPONENTS.")
    PCA_N_COMPONENTS = TFIDF_MAX_FEATURES

# --- Classifier Definitions ---
CLASSIFIERS: Dict[str, Any] = {
    "svm": SVC(kernel='linear', probability=False, C=0.1, random_state=RANDOM_SEED),
    "gnb": GaussianNB(),
    "logistic_regression": LogisticRegression(
        C=0.1, solver='liblinear', max_iter=100, random_state=RANDOM_SEED
    ),
    "knn": KNeighborsClassifier(
        n_neighbors=10, weights='distance', metric='minkowski', n_jobs=-1
    ),
    "random_forest": RandomForestClassifier(
        n_estimators=100, max_depth=8, min_samples_split=5,
        min_samples_leaf=2, max_features='sqrt', n_jobs=-1,
        random_state=RANDOM_SEED
    ),
    "gradient_boosting": GradientBoostingClassifier(
        n_estimators=100, learning_rate=0.05, max_depth=4,
        min_samples_split=2, min_samples_leaf=1, random_state=RANDOM_SEED
    ),
    "xgboost": XGBClassifier(
        eval_metric='mlogloss',
        n_estimators=100,
        max_depth=5, learning_rate=0.1, colsample_bytree=0.8,
        subsample=0.8, random_state=RANDOM_SEED, n_jobs=-1,
        tree_method='gpu_hist' if USE_GPU_FOR_XGBOOST else 'hist',
        predictor='gpu_predictor' if USE_GPU_FOR_XGBOOST else 'auto'
    )
}

# Metrics to calculate and report average/std dev for
METRICS_TO_AVERAGE: Dict[str, str] = {
    "accuracy": "Accuracy",
    "precision_macro": "Macro Precision",
    "recall_macro": "Macro Recall",
    "f1_macro": "Macro F1-score",
    "precision_weighted": "Weighted Precision",
    "recall_weighted": "Weighted Recall",
    "f1_weighted": "Weighted F1-score"
}


# --- Helper Functions ---

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
    print(f"Loading data from: {folder_path}")
    for class_name in class_subdirectories:
        class_dir_path = os.path.join(folder_path, class_name)
        sol_files = glob.glob(os.path.join(class_dir_path, "*.sol"))
        if not sol_files:
            print(f"Warning: No .sol files found in {class_dir_path}")
            continue
        for file_path in sol_files:
            try:
                with open(file_path, 'r', encoding='utf-8', errors='ignore') as f_contract:
                    texts.append(f_contract.read())
                    labels.append(class_name)
            except Exception as e:
                print(f"Error reading file {file_path}: {e}")
        print(f"  Loaded {len(sol_files)} contracts from class '{class_name}'")
    if not texts:
        print(f"Error: No contracts loaded from {folder_path}. Check for .sol files in subdirectories.")
        return None, None
    return texts, labels


def record_nan_for_all_metrics(classifier_name: str, metrics_storage: defaultdict):
    for metric_key in METRICS_TO_AVERAGE.keys():
        metrics_storage[classifier_name][metric_key].append(np.nan)


# --- Main Script ---
def run_cross_validation():
    print("--- Solidity Contract Classification (Cross-Validation with PCA) ---")
    print(f"Random Seed: {RANDOM_SEED}")
    print(f"Number of Folds: {N_FOLDS}")
    if APPLY_PCA:
        print(f"PCA Enabled: Yes, Target Components/Variance: {PCA_N_COMPONENTS}")
    else:
        print("PCA Enabled: No")
    if "xgboost" in CLASSIFIERS:
        print(f"XGBoost GPU usage: {'Enabled' if USE_GPU_FOR_XGBOOST else 'Disabled'}")

    all_folds_classifier_metrics: defaultdict = defaultdict(lambda: defaultdict(list))

    for fold_index, fold_dir_name in enumerate(FOLD_DIRECTORIES):
        current_fold_num = fold_index + 1
        print(f"\n\n{'=' * 20} Processing Fold {current_fold_num}/{N_FOLDS}: {fold_dir_name} {'=' * 20}")

        fold_base_path = os.path.join(BASE_PROJECT_PATH, fold_dir_name)
        train_data_path = os.path.join(fold_base_path, "train")
        test_data_path = os.path.join(fold_base_path, "test")

        if not os.path.isdir(fold_base_path):
            print(f"Error: Base path for fold '{fold_dir_name}' not found. Skipping.")
            for clf_name in CLASSIFIERS.keys():
                record_nan_for_all_metrics(clf_name, all_folds_classifier_metrics)
            continue

        print(f"\n--- [Fold {current_fold_num}] Step 1: Loading Data ---")
        train_texts, train_labels_str = load_solidity_contracts(train_data_path)
        test_texts, test_labels_str = load_solidity_contracts(test_data_path)

        if not all([train_texts, train_labels_str, test_texts, test_labels_str]):
            print(f"Error: Data loading failed for fold '{fold_dir_name}'. Skipping.")
            for clf_name in CLASSIFIERS.keys():
                record_nan_for_all_metrics(clf_name, all_folds_classifier_metrics)
            continue
        print(f"Loaded {len(train_texts)} training samples and {len(test_texts)} testing samples.")

        print(f"\n--- [Fold {current_fold_num}] Step 2: Encoding Labels ---")
        label_encoder = LabelEncoder()
        train_labels_encoded = label_encoder.fit_transform(train_labels_str)
        test_labels_encoded = label_encoder.transform(test_labels_str)
        class_names_from_encoder = label_encoder.classes_
        print(f"Labels encoded. Classes: {class_names_from_encoder}")
        if len(class_names_from_encoder) < 2:
            print(f"Error: At least two classes required. Found {len(class_names_from_encoder)}. Skipping fold.")
            for clf_name in CLASSIFIERS.keys():
                record_nan_for_all_metrics(clf_name, all_folds_classifier_metrics)
            continue

        print(f"\n--- [Fold {current_fold_num}] Step 3: TF-IDF Vectorization ---")
        tfidf_vectorizer = TfidfVectorizer(max_features=TFIDF_MAX_FEATURES)
        X_train_tfidf = tfidf_vectorizer.fit_transform(train_texts)
        X_test_tfidf = tfidf_vectorizer.transform(test_texts)
        print(f"TF-IDF training data shape: {X_train_tfidf.shape}")
        print(f"TF-IDF test data shape: {X_test_tfidf.shape}")

        # Prepare data for classifiers (either TF-IDF or PCA-transformed TF-IDF)
        X_train_processed = X_train_tfidf
        X_test_processed = X_test_tfidf

        if APPLY_PCA:
            print(f"\n--- [Fold {current_fold_num}] Step 3.5: Applying PCA ---")
            # PCA requires dense data
            X_train_tfidf_dense = X_train_tfidf.toarray()
            X_test_tfidf_dense = X_test_tfidf.toarray()

            # Adjust n_components if it's an integer and greater than number of available features
            current_n_features = X_train_tfidf_dense.shape[1]
            pca_n_c = PCA_N_COMPONENTS
            if isinstance(PCA_N_COMPONENTS, int) and PCA_N_COMPONENTS > current_n_features:
                print(
                    f"  Warning: PCA_N_COMPONENTS ({PCA_N_COMPONENTS}) > actual features ({current_n_features}). Using {current_n_features} components.")
                pca_n_c = current_n_features

            if pca_n_c <= 0:  # handles cases where current_n_features might be 0
                print(
                    f"  Error: Number of features after TF-IDF is {current_n_features}. Cannot apply PCA with {pca_n_c} components. Skipping PCA.")
                # Data remains as TF-IDF
            else:
                pca = PCA(n_components=pca_n_c, random_state=RANDOM_SEED)
                print(f"  Fitting PCA on training data with n_components={pca_n_c}...")
                X_train_processed = pca.fit_transform(X_train_tfidf_dense)
                print(f"  Transforming test data using fitted PCA...")
                X_test_processed = pca.transform(X_test_tfidf_dense)
                print(f"  Shape of training data after PCA: {X_train_processed.shape}")
                print(f"  Shape of test data after PCA: {X_test_processed.shape}")
                if isinstance(pca_n_c, float):
                    print(
                        f"  Explained variance with {pca.n_components_} components: {np.sum(pca.explained_variance_ratio_):.4f}")

        print(f"\n--- [Fold {current_fold_num}] Step 4: Training and Evaluating Classifiers ---")
        for clf_name, model_prototype in CLASSIFIERS.items():
            model = clone(model_prototype)
            print(f"\n----- Classifier: {clf_name.upper()} (Fold {current_fold_num}) -----")
            try:
                print(f"Training {clf_name}...")
                # Data after PCA is dense, so no special .toarray() needed for GNB here.
                # If PCA is not applied, X_train_processed is sparse TF-IDF, so GNB needs .toarray()
                if clf_name == "gnb" and not APPLY_PCA:  # only convert if GNB and data is still sparse
                    current_X_train = X_train_processed.toarray()
                else:
                    current_X_train = X_train_processed

                model.fit(current_X_train, train_labels_encoded)
                print(f"{clf_name} training complete.")

                print(f"Predicting with {clf_name} on the test set...")
                if clf_name == "gnb" and not APPLY_PCA:
                    current_X_test = X_test_processed.toarray()
                else:
                    current_X_test = X_test_processed
                y_pred_encoded = model.predict(current_X_test)

                accuracy = accuracy_score(test_labels_encoded, y_pred_encoded)
                report_dict = classification_report(
                    test_labels_encoded, y_pred_encoded,
                    target_names=class_names_from_encoder,
                    zero_division=0, output_dict=True
                )
                all_folds_classifier_metrics[clf_name]['accuracy'].append(accuracy)
                all_folds_classifier_metrics[clf_name]['precision_macro'].append(report_dict['macro avg']['precision'])
                all_folds_classifier_metrics[clf_name]['recall_macro'].append(report_dict['macro avg']['recall'])
                all_folds_classifier_metrics[clf_name]['f1_macro'].append(report_dict['macro avg']['f1-score'])
                all_folds_classifier_metrics[clf_name]['precision_weighted'].append(
                    report_dict['weighted avg']['precision'])
                all_folds_classifier_metrics[clf_name]['recall_weighted'].append(report_dict['weighted avg']['recall'])
                all_folds_classifier_metrics[clf_name]['f1_weighted'].append(report_dict['weighted avg']['f1-score'])

                print(f"\n{clf_name} - Fold {current_fold_num} Test Set Evaluation:")
                print(f"  Accuracy: {accuracy:.4f}")
                print("\n  Classification Report (Current Fold):")
                print(classification_report(
                    test_labels_encoded, y_pred_encoded,
                    labels=np.arange(len(class_names_from_encoder)),
                    target_names=class_names_from_encoder, zero_division=0
                ))
                print("\n  Confusion Matrix (Current Fold):")
                print(f"  (Rows: True Labels, Columns: Predicted Labels for classes: {class_names_from_encoder})")
                cm = confusion_matrix(test_labels_encoded, y_pred_encoded,
                                      labels=np.arange(len(class_names_from_encoder)))
                print(cm)

            except Exception as e:
                print(f"!!! ERROR processing classifier {clf_name} in fold {current_fold_num}: {e} !!!")
                record_nan_for_all_metrics(clf_name, all_folds_classifier_metrics)
                if "XGBoost" in str(e) and USE_GPU_FOR_XGBOOST:
                    print("  XGBoost GPU error suspected. Consider setting USE_GPU_FOR_XGBOOST to False.")
                continue

    print(f"\n\n{'=' * 30} Overall Cross-Validation Results {'=' * 30}")
    for clf_name in CLASSIFIERS.keys():
        print(f"\n--- Summary for Classifier: {clf_name.upper()} ---")
        if not all_folds_classifier_metrics[clf_name]['accuracy']:
            print("  No results recorded for this classifier.")
            continue
        for metric_key, metric_display_name in METRICS_TO_AVERAGE.items():
            metric_scores_for_folds = all_folds_classifier_metrics[clf_name].get(metric_key, [])
            valid_scores = [score for score in metric_scores_for_folds if not np.isnan(score)]
            num_successful_folds_for_metric = len(valid_scores)
            print(f"  Metric: {metric_display_name}")
            fold_scores_str = ", ".join(
                [f"{score:.4f}" if not np.isnan(score) else "N/A" for score in metric_scores_for_folds])
            print(f"    - Fold Scores       : [{fold_scores_str}]")
            if num_successful_folds_for_metric > 0:
                mean_score = np.mean(valid_scores)
                std_dev_score = np.std(valid_scores)
                print(f"    - Average           : {mean_score:.4f}")
                print(f"    - Std. Deviation    : {std_dev_score:.4f}")
                print(f"    - Successful Folds  : {num_successful_folds_for_metric}/{N_FOLDS}")
            else:
                print("    - No successful evaluations for this metric across folds.")
            if 0 < num_successful_folds_for_metric < N_FOLDS:
                print(f"      (Note: Calculated over {num_successful_folds_for_metric} out of {N_FOLDS} total folds.)")
        print("-" * 70)
    print("\n--- Script Finished ---")


if __name__ == "__main__":
    run_cross_validation()