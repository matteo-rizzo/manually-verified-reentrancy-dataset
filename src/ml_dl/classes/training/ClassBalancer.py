from typing import Tuple, Union, List

import numpy as np
import torch
from iterstrat.ml_stratifiers import MultilabelStratifiedKFold
from sklearn.model_selection import StratifiedShuffleSplit
from torch import Tensor
from torch.utils.data import Subset, WeightedRandomSampler
from torch_geometric.data import Data

from src.classes.data.graphs.GraphDataset import GraphDataset


class ClassBalancer:

    @staticmethod
    def compute_weights(counts: np.ndarray) -> np.ndarray:
        """
        Compute weights for each class to handle class imbalance.

        :param counts: Array containing the count of each class.
        :return: Array containing the computed weights for each class.
        """
        with np.errstate(divide='ignore', invalid='ignore'):
            weights = np.divide(1.0, counts, out=np.zeros_like(counts, dtype=float), where=counts != 0)
        weights = np.where(weights == 0, 1e-10, weights)  # Ensure no zero weights
        return weights

    @staticmethod
    def extract_labels(subset: Subset) -> np.ndarray:
        """
        Extract labels from the subset, ensuring they are in a consistent shape.

        :param subset: The subset of the original dataset.
        :return: A numpy array of padded labels.
        """
        if isinstance(subset.dataset, GraphDataset):
            labels = [data.y.numpy() for data in subset]

            # Determine the maximum length for padding
            max_length = max(len(label.flatten()) for label in labels)

            # Pad labels to the maximum length
            padded_labels = np.array([
                np.pad(label.flatten(), (0, max_length - len(label.flatten())), mode='constant') for label in labels
            ])
        else:
            labels = subset.dataset.tensors[-1][subset.indices].numpy()

            # Ensure labels are a 2D array with shape (num_samples, num_classes)
            if labels.ndim == 1:
                labels = labels.reshape(-1, 1)

        return labels

    @staticmethod
    def make_balanced_sampler(subset: Subset) -> WeightedRandomSampler:
        """
        Create a balanced sampler for the subset to handle class imbalance.

        :param subset: The subset of the original dataset for which to create the sampler.
        :return: A WeightedRandomSampler instance.
        """
        labels = ClassBalancer.extract_labels(subset)

        if labels.ndim == 1 or labels.shape[1] == 1:  # Binary classification case
            label_counts = np.bincount(labels.flatten().astype(int))  # Ensure labels are integers
            weights = ClassBalancer.compute_weights(label_counts)
            sample_weights = np.array(
                [weights[int(label)] for label in labels.flatten()])  # Convert to int for indexing
        else:
            label_counts = labels.sum(axis=0)
            weights = ClassBalancer.compute_weights(label_counts)
            sample_weights = np.dot(labels, weights.reshape(-1, 1)).flatten()  # Ensure weights are 2D and flatten

        return WeightedRandomSampler(sample_weights, len(sample_weights))

    @staticmethod
    def calculate_class_weights(subset: Subset) -> torch.FloatTensor:
        """
        Calculate class weights for the subset to handle class imbalance.

        :param subset: The subset of the original dataset for which to calculate class weights.
        :return: A torch.FloatTensor containing the class weights.
        """
        labels = ClassBalancer.extract_labels(subset)
        class_sample_counts = labels.sum(axis=0)
        weights = ClassBalancer.compute_weights(class_sample_counts)
        return torch.FloatTensor(weights)

    @staticmethod
    def train_test_split(data: Union[np.ndarray, Tensor, List[Data]],
                         labels: Union[np.ndarray, Tensor, List[List[int]]],
                         test_size: float, random_state: int,
                         is_binary: bool = True) -> Tuple:
        """
        Split the data into training and test sets in a balanced manner.

        :param data: Features array or list of Data objects.
        :param labels: Labels array or list of multilabels corresponding to the Data objects.
        :param test_size: Proportion of the dataset to include in the test split.
        :param random_state: The random seed for reproducibility.
        :param is_binary: Boolean flag indicating if the task is binary classification.
        :return: Train and test datasets and their corresponding labels.
        """
        labels_np = np.array(labels)

        if isinstance(data, list) and isinstance(data[0], Data):
            if is_binary:
                splitter = StratifiedShuffleSplit(n_splits=1, test_size=test_size, random_state=random_state)
                train_indices, test_indices = next(splitter.split(np.zeros(len(labels)), labels_np.flatten()))
            else:
                mskf = MultilabelStratifiedKFold(n_splits=int(1 / test_size), shuffle=True, random_state=random_state)
                train_indices, test_indices = next(mskf.split(np.zeros(len(labels)), labels_np))
            x_train = [data[i] for i in train_indices]
            x_test = [data[i] for i in test_indices]
            y_train = [labels[i] for i in train_indices]
            y_test = [labels[i] for i in test_indices]
        else:
            if is_binary:
                splitter = StratifiedShuffleSplit(n_splits=1, test_size=test_size, random_state=random_state)
                train_indices, test_indices = next(splitter.split(data, labels_np.flatten()))
            else:
                mskf = MultilabelStratifiedKFold(n_splits=int(1 / test_size), shuffle=True, random_state=random_state)
                train_indices, test_indices = next(mskf.split(data, labels_np))
            x_train, x_test = data[train_indices], data[test_indices]
            y_train, y_test = labels_np[train_indices], labels_np[test_indices]

        return x_train, x_test, y_train, y_test
