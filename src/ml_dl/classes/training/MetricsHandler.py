import os
from typing import Dict, List, Any

import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
from sklearn.metrics import accuracy_score, precision_score, recall_score, f1_score


class MetricsHandler:
    @staticmethod
    def print_metrics(metrics: Dict):
        """
        Print the evaluation metrics.

        :param metrics: A dictionary containing metric names as keys and their values.
        """
        for k, v in metrics.items():
            print(f"{k.capitalize()}: {v:.4f}, ", end="")
        print("\n")

    @staticmethod
    def plot_metrics(history: Dict[str, List[float]], fold: int, num_epochs: int, log_id: str, log_dir: str) -> None:
        """
        Plot training and validation metrics and save the plots.

        :param history: A dictionary containing lists of training and validation losses and metrics for each epoch.
        :param fold: The current fold number.
        :param num_epochs: The number of training epochs.
        :param log_id: Identifier for logging purposes, typically the model name.
        :param log_dir: The logging directory.
        """
        save_dir = os.path.join(log_dir, log_id)
        os.makedirs(save_dir, exist_ok=True)

        epochs = range(1, num_epochs + 1)
        metrics = ['precision', 'recall', 'f1']

        fig, axs = plt.subplots(3, 1, figsize=(10, 15))

        for i, metric in enumerate(metrics):
            train_metric = [m[metric] for m in history['train_metrics']]
            val_metric = [m[metric] for m in history['val_metrics']]
            axs[i].plot(epochs, train_metric, label=f'Training {metric.capitalize()}')
            axs[i].plot(epochs, val_metric, label=f'Validation {metric.capitalize()}')
            axs[i].set_title(f'Training and Validation {metric.capitalize()} - Fold {fold + 1}')
            axs[i].set_xlabel('Epochs')
            axs[i].set_ylabel(metric.capitalize())
            axs[i].legend()

        plt.tight_layout()
        plt.savefig(f"{save_dir}/fold_{fold + 1}_metrics.png")
        plt.close()

        plt.figure(figsize=(10, 5))
        plt.plot(epochs, history['train_loss'], label='Training Loss')
        plt.plot(epochs, history['val_loss'], label='Validation Loss')
        plt.title(f'Training and Validation Loss - Fold {fold + 1}')
        plt.xlabel('Epochs')
        plt.ylabel('Loss')
        plt.legend()
        plt.savefig(f"{save_dir}/fold_{fold + 1}_loss.png")
        plt.close()

    @staticmethod
    def compute_metrics(true_labels: List[Any], pred_labels: List[Any], is_binary: bool = True) -> Dict[str, float]:
        """
        Compute evaluation metrics for the given true and predicted labels.

        :param true_labels: The ground truth labels.
        :param pred_labels: The predicted labels.
        :param is_binary: Boolean flag to indicate if the task is binary classification.
        :return: A dictionary containing precision, recall, F1 score, and accuracy.
        """
        true_labels = np.array(true_labels)
        pred_labels = np.array(pred_labels)

        # Adjust metrics calculation for binary classification
        if is_binary:
            return {
                "accuracy": accuracy_score(true_labels, pred_labels),
                "precision": precision_score(true_labels, pred_labels, average='binary', zero_division=0),
                "recall": recall_score(true_labels, pred_labels, average='binary', zero_division=0),
                "f1": f1_score(true_labels, pred_labels, average='binary', zero_division=0)
            }
        else:
            # Multilabel classification
            return {
                "accuracy": accuracy_score(true_labels, pred_labels),
                "precision": precision_score(true_labels, pred_labels, average='samples', zero_division=0),
                "recall": recall_score(true_labels, pred_labels, average='samples', zero_division=0),
                "f1": f1_score(true_labels, pred_labels, average='samples', zero_division=0)
            }

    @staticmethod
    def save_results(results: pd.DataFrame, filename: str, log_dir: str) -> None:
        """
        Save the results to a CSV file.

        :param results: The results to save, typically a list of dictionaries.
        :param filename: The name of the file to save the results to.
        :param log_dir: The logging directory.
        """
        df = pd.DataFrame(results)
        os.makedirs(log_dir, exist_ok=True)
        df.to_csv(os.path.join(log_dir, filename), index=False)
        print(f"All fold results saved to '{os.path.join(log_dir, filename)}'")
