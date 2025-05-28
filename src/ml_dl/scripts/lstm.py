from typing import Dict

import numpy as np
import torch
from torch.utils.data import TensorDataset
from transformers import RobertaTokenizer

from src.classes.classifiers.LSTMClassifier import LSTMClassifier
from src.classes.data.DataPreprocessor import DataPreprocessor
from src.classes.training.ClassBalancer import ClassBalancer
from src.classes.training.CrossValidator import CrossValidator
from src.classes.training.LSTMModelTrainer import LSTMModelTrainer
from src.settings import BATCH_SIZE, NUM_EPOCHS, LR, DEVICE
from src.utility import make_reproducible, init_arg_parser, make_log_dir

BERT_MODEL_TYPE = 'microsoft/codebert-base'


def main(config: Dict):
    # Initialize the DataPreprocessor
    print("Initializing DataPreprocessor...")
    preprocessor = DataPreprocessor(
        path_to_dataset=config['path_to_dataset'],
        file_types=[config['file_type']],
        subset=config['subset']
    )

    print("Loading and processing data...")
    preprocessor.load_and_process_data()

    print("Accessing processed data...")
    inputs = preprocessor.get_inputs()
    labels = preprocessor.get_labels()

    print("Initializing RobertaTokenizer...")
    tokenizer = RobertaTokenizer.from_pretrained(config['bert_model_type'], ignore_mismatched_sizes=True)

    print("Tokenizing inputs...")
    x, y = tokenizer(
        inputs,
        add_special_tokens=True,
        max_length=512,
        return_token_type_ids=False,
        padding="max_length",
        truncation=True,
        return_attention_mask=True,
        return_tensors='pt'
    ), np.array(labels)

    print("Splitting data into training and test sets...")
    x_train, x_test, y_train, y_test = ClassBalancer.train_test_split(
        x['input_ids'], y, test_size=config['test_size'], random_state=config['random_seed']
    )

    print("Splitting attention masks for training and test sets...")
    train_masks, test_masks, _, _ = ClassBalancer.train_test_split(
        x['attention_mask'], y, test_size=config['test_size'], random_state=config['random_seed']
    )

    print("Creating TensorDataset objects for training and testing...")
    train_data = TensorDataset(x_train, train_masks, torch.tensor(y_train).float())
    test_data = TensorDataset(x_test, test_masks, torch.tensor(y_test).float())

    print("Initializing RobertaForSequenceClassification model...")
    model = LSTMClassifier(
        embedding_dim=768,
        hidden_dim=128,
        output_dim=preprocessor.get_num_labels()
    )
    model.to(DEVICE)

    print("Initializing CrossValidator...")
    cross_validator = CrossValidator(
        LSTMModelTrainer(model), train_data, test_data,
        num_epochs=config['num_epochs'],
        num_folds=config['num_folds'],
        batch_size=config['batch_size']
    )

    print("Starting k-fold cross-validation...")
    cross_validator.k_fold_cv(log_id="lstm", log_dir=config["log_dir"])


if __name__ == '__main__':
    # Parse command-line arguments for configurations
    parser = init_arg_parser()
    parser.add_argument("--bert_model_type", type=str, default=BERT_MODEL_TYPE, help="BERT model type")
    parser.add_argument("--batch_size", type=int, default=BATCH_SIZE, help="Batch size")
    parser.add_argument("--num_epochs", type=int, default=NUM_EPOCHS, help="Number of epochs")
    parser.add_argument("--learning_rate", type=float, default=LR, help="Learning rate")

    args = parser.parse_args()
    config = vars(args)

    # Ensure reproducibility by setting the random seed
    make_reproducible(config["random_seed"])

    # Create the logging directory
    config["log_dir"] = make_log_dir(experiment_id=f"{config['subset']}_{config['file_type']}")

    # Print all configurations for verification
    print("Configuration:")
    for arg in config:
        print(f"{arg}: {getattr(args, arg)}")

    # Execute the main function with the provided configurations
    main(config)
