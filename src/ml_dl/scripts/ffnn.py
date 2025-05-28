from typing import Dict

import numpy as np
import torch
from torch.utils.data import TensorDataset

from src.classes.classifiers.FFNNClassifier import FFNNClassifier
from src.classes.data.DataPreprocessor import DataPreprocessor
from src.classes.data.MultimodalVectorizer import MultimodalVectorizer
from src.classes.training.ClassBalancer import ClassBalancer
from src.classes.training.CrossValidator import CrossValidator
from src.classes.training.Trainer import Trainer
from src.settings import BATCH_SIZE, NUM_EPOCHS, LR, MAX_FEATURES, USE_CLASS_WEIGHTS
from src.utility import make_reproducible, init_arg_parser, make_log_dir

MULTIMODAL = False
MULTIMODAL_FILE_TYPES = ["source", "bytecode", "runtime"]


def main(config: Dict):
    preprocessor = DataPreprocessor(
        path_to_dataset=config['path_to_dataset'],
        file_types=MULTIMODAL_FILE_TYPES if config["multimodal"] else [config['file_type']],
        subset=config['subset']
    )
    print("Loading and processing data...")
    preprocessor.load_and_process_data()

    vectorizer = MultimodalVectorizer(max_features=config["max_features"], multimodal=config["multimodal"])

    print("Transforming input documents into TF-IDF features...")
    x = vectorizer.transform_inputs(preprocessor.get_inputs())
    print(f"TF-IDF feature matrix shape: {x.shape}")

    print("Converting labels to numpy array...")
    y = np.array(preprocessor.get_labels())
    print(f"Labels shape: {y.shape}")

    # Split the data into training and test sets using ClassBalancer
    print("Splitting data into training and test sets...")
    x_train, x_test, y_train, y_test = ClassBalancer.train_test_split(
        x, y, test_size=config['test_size'], random_state=config['random_seed']
    )

    train_data = TensorDataset(torch.tensor(x_train, dtype=torch.float32), torch.tensor(y_train, dtype=torch.float32))
    test_data = TensorDataset(torch.tensor(x_test, dtype=torch.float32), torch.tensor(y_test, dtype=torch.float32))

    # Initialize the FFNNClassifier
    print("Initializing the FFNNClassifier...")
    input_size = len(MULTIMODAL_FILE_TYPES) * config["max_features"] if config["multimodal"] else config["max_features"]
    model = FFNNClassifier(input_size=input_size, output_size=preprocessor.get_num_labels())

    # Start cross-validation
    print("Starting cross-validation...")
    cross_validator = CrossValidator(
        Trainer(model), train_data, test_data,
        num_epochs=config['num_epochs'],
        num_folds=config['num_folds'],
        batch_size=config['batch_size']
    )

    print("Starting k-fold cross-validation...")
    cross_validator.k_fold_cv(log_id="ffnn", log_dir=config["log_dir"], use_class_weights=config["use_class_weights"])


if __name__ == '__main__':
    # Initialize argument parser and add custom arguments
    parser = init_arg_parser()
    parser.add_argument("--max_features", type=int, default=MAX_FEATURES, help="Maximum features for TF-IDF vectorizer")
    parser.add_argument("--batch_size", type=int, default=BATCH_SIZE, help="Batch size")
    parser.add_argument("--num_epochs", type=int, default=NUM_EPOCHS, help="Number of epochs")
    parser.add_argument("--learning_rate", type=float, default=LR, help="Learning rate")
    parser.add_argument("--multimodal", type=bool, default=MULTIMODAL, help="Process multiple modalities at once")
    parser.add_argument("--use_class_weights", type=bool, default=USE_CLASS_WEIGHTS, help="Use class weights")

    # Parse command-line arguments
    args = parser.parse_args()
    config = vars(args)

    # Ensure reproducibility by setting the random seed
    make_reproducible(config["random_seed"])

    # Create the logging directory
    experiment_id = f"{config['subset']}_{'multimodal' if config['multimodal'] else config['file_type']}"
    config["log_dir"] = make_log_dir(experiment_id)

    # Print all configurations for verification
    print("Configuration:")
    for arg in config:
        print(f"{arg}: {getattr(args, arg)}")

    # Execute the main function with the provided configurations
    main(config)
