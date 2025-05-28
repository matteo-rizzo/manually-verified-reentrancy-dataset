from typing import Any, List, Dict, Union

import numpy as np
from numpy import floating
from sklearn.model_selection import KFold
from torch.utils.data import DataLoader, Subset, Dataset
from torch_geometric.loader import DataLoader as GeometricDataLoader

from src.classes.data.graphs.GraphDataset import GraphDataset
from src.classes.training.ClassBalancer import ClassBalancer
from src.classes.training.MetricsHandler import MetricsHandler
from src.classes.training.Trainer import Trainer


class CrossValidator:

    def __init__(self, trainer: Trainer, train_data: Union[Dataset, GraphDataset],
                 test_data: Union[Dataset, GraphDataset],
                 num_epochs: int, num_folds: int, batch_size: int):
        """
        Initialize the CrossValidator with trainer, training data, test data, and configuration parameters.

        :param trainer: An instance of the Trainer class.
        :param train_data: The training dataset.
        :param test_data: The test dataset.
        :param num_epochs: Number of epochs to train the model.
        :param num_folds: Number of folds for cross-validation.
        :param batch_size: Batch size for data loading.
        """
        self.__trainer = trainer
        self.__train_data = train_data
        self.__test_data = test_data
        self.__num_epochs = num_epochs
        self.__num_folds = num_folds
        self.__batch_size = batch_size

        # Determine if the dataset is a GraphDataset
        self.is_graph_dataset = isinstance(self.__train_data, GraphDataset)

    def __get_dataloader(self, dataset: Union[Dataset, GraphDataset], shuffle: bool = False,
                         sampler=None) -> DataLoader:
        """
        Returns the appropriate DataLoader based on the dataset type.

        :param dataset: The dataset for which to create the DataLoader.
        :param shuffle: Whether to shuffle the data.
        :param sampler: Sampler for data sampling.
        :return: A DataLoader instance.
        """
        if self.is_graph_dataset:
            return GeometricDataLoader(dataset, batch_size=self.__batch_size, shuffle=shuffle, sampler=sampler)
        else:
            return DataLoader(dataset, batch_size=self.__batch_size, shuffle=shuffle, sampler=sampler)

    def __train_and_evaluate(self, train_dataloader: DataLoader, test_dataloader: DataLoader) -> Dict[str, List[float]]:
        """
        Train and evaluate the model for a specified number of epochs.

        :param train_dataloader: DataLoader for the training data.
        :param test_dataloader: DataLoader for the validation data.
        :return: A dictionary containing lists of training and validation losses and metrics for each epoch.
        """
        training_history = {
            'train_loss': [],
            'val_loss': [],
            'train_metrics': [],
            'val_metrics': []
        }

        for epoch in range(self.__num_epochs):
            print(f"\n --- Epoch {epoch + 1}/{self.__num_epochs} ---")

            # Train the model and print training metrics
            avg_train_loss, avg_train_metrics = self.__trainer.run_epoch(train_dataloader, train_mode=True)
            training_history['train_loss'].append(avg_train_loss)
            training_history['train_metrics'].append(avg_train_metrics)
            print(f"\n TRAIN | Loss: {avg_train_loss:.4f} | ", end="")
            MetricsHandler.print_metrics(avg_train_metrics)

            # Evaluate the model on the validation set and print validation metrics
            avg_test_loss, avg_test_metrics = self.__trainer.run_epoch(test_dataloader, train_mode=False)
            training_history['val_loss'].append(avg_test_loss)
            training_history['val_metrics'].append(avg_test_metrics)
            print(f" VALID | Loss: {avg_test_loss:.4f} | ", end="")
            MetricsHandler.print_metrics(avg_test_metrics)

        return training_history

    def __evaluate_on_test_set(self, test_dataloader: DataLoader) -> dict[str, floating[Any]]:
        """
        Evaluate the model on the test set.

        :param test_dataloader: DataLoader for the test data.
        :return: A dictionary of test set metrics.
        """
        avg_test_loss, avg_test_metrics = self.__trainer.run_epoch(test_dataloader, train_mode=False)

        # Print test set metrics
        print(f"\nTest Set Evaluation | Loss: {avg_test_loss:.4f} | ", end="")
        MetricsHandler.print_metrics(avg_test_metrics)

        return avg_test_metrics

    def k_fold_cv(self, log_id: str = "", log_dir: str = "", use_class_weights: bool = True) -> None:
        """
        Perform k-fold cross-validation.

        :param log_dir: The logging directory.
        :param log_id: Identifier for logging purposes, typically the model name.
        """
        kf = KFold(n_splits=self.__num_folds, shuffle=True)
        fold_metrics = []

        # Iterate over each fold
        for fold, (train_idx, val_idx) in enumerate(kf.split(self.__train_data)):
            # Create data loaders for training and validation sets
            train_subsampler = Subset(self.__train_data, train_idx)
            val_subsampler = Subset(self.__train_data, val_idx)

            # Calculate class weights and set them in the trainer
            if use_class_weights:
                class_weights = ClassBalancer.calculate_class_weights(train_subsampler)
                self.__trainer.set_class_weights(class_weights)

            train_loader = self.__get_dataloader(train_subsampler,
                                                 sampler=ClassBalancer.make_balanced_sampler(train_subsampler))
            val_loader = self.__get_dataloader(val_subsampler)

            print(f"Starting Fold {fold + 1}/{self.__num_folds}")

            # Train and evaluate the model for the current fold
            history = self.__train_and_evaluate(train_loader, val_loader)

            # Plot and save metrics for the current fold
            MetricsHandler.plot_metrics(history, fold, self.__num_epochs, log_id, log_dir)

            # Evaluate on the test set after each fold
            test_loader = self.__get_dataloader(self.__test_data)
            metrics = self.__evaluate_on_test_set(test_loader)
            fold_metrics.append(metrics)

            # Reset the model to untrained
            self.__trainer.reset_model()

        # Calculate average and standard deviation of each metric across all folds
        metric_keys = fold_metrics[0].keys()  # Assuming all metrics dictionaries have the same structure
        average_metrics = {key: np.mean([metric[key] for metric in fold_metrics]) for key in metric_keys}
        std_dev_metrics = {key: np.std([metric[key] for metric in fold_metrics]) for key in metric_keys}

        # Print average metrics and their standard deviations
        print("Average Metrics Over All Folds:")
        for key, value in average_metrics.items():
            print(f"{key}: {value:.4f} (±{std_dev_metrics[key]:.4f})")

        # Save metrics to CSV file
        MetricsHandler.save_results(fold_metrics, filename=f"{log_id}.csv", log_dir=log_dir)
