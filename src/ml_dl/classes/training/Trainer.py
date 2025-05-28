from typing import Tuple, Dict, Any

import numpy as np
import torch
from numpy import floating
from torch import optim, nn
from torch.utils.data import DataLoader
from tqdm import tqdm

from src.classes.training.MetricsHandler import MetricsHandler
from src.settings import DEVICE, LR


class Trainer:
    """
    Trainer class for handling the training and evaluation of a model.
    """

    def __init__(self, model: nn.Module):
        """
        Initialize the trainer with model, loss criterion, and optimizer.

        :param model: The neural network model to be trained.
        """
        self.__untrained_model = model
        self._model = model.to(DEVICE)
        self._optimizer = optim.Adam(model.parameters(), lr=LR)
        self._loss_fn = nn.BCEWithLogitsLoss().to(DEVICE)

    def set_class_weights(self, class_weights):
        self._loss_fn = nn.BCEWithLogitsLoss(weight=class_weights).to(DEVICE)

    def reset_model(self):
        self._model = self.__untrained_model
        self._optimizer = optim.Adam(self.__untrained_model.parameters(), lr=LR)

    def _evaluate_batch(self, batch: Tuple) -> Tuple[float, Dict[str, float]]:
        """
        Evaluate a single batch of data.

        :param batch: A tuple containing input data and labels.
        :return: A tuple containing the loss and a dictionary of metrics.
        """
        # Move batch elements to the appropriate device (CPU/GPU)
        batch = tuple(b.to(DEVICE) for b in batch)

        # Prepare the inputs for the model
        inputs, labels = batch

        # Disable gradient computation for evaluation
        with torch.no_grad():
            outputs = self._model(inputs)

            # Compute the loss
            loss = self._loss_fn(outputs, labels)

            # Make predictions and compute batch metrics
            predictions = torch.sigmoid(outputs).round().cpu().numpy()
            batch_metrics = MetricsHandler.compute_metrics(labels.cpu().numpy(), predictions)

        # Return the loss and metrics
        return loss.item(), batch_metrics

    def _train_batch(self, batch: Tuple) -> Tuple[float, Dict[str, float]]:
        """
        Train a single batch of data.

        :param batch: A tuple containing input data and labels.
        :return: A tuple containing the loss and a dictionary of metrics.
        """
        # Prepare inputs for the model
        inputs, labels = batch

        # Zero the parameter gradients
        self._model.zero_grad()

        # Forward pass
        outputs = self._model(inputs)

        # Compute the loss
        loss = self._loss_fn(outputs, labels)

        # Backward pass and optimize
        loss.backward()
        self._optimizer.step()

        # Make predictions and compute metrics
        predictions = torch.sigmoid(outputs).round().detach().cpu().numpy()
        batch_metrics = MetricsHandler.compute_metrics(labels.detach().cpu().numpy(), predictions)

        return loss.item(), batch_metrics

    def run_epoch(self, dataloader: DataLoader, train_mode: bool = True) -> tuple[
        floating[Any], dict[str, floating[Any]]]:
        """
        Run a single epoch of training or evaluation.

        :param dataloader: DataLoader providing the data for the epoch.
        :param train_mode: Boolean flag indicating whether to train or evaluate.
        :return: A tuple containing the average loss and a dictionary of average metrics.
        """
        # Set the mode for the epoch (Training or Testing)
        phase = 'Training' if train_mode else 'Testing'
        self._model.train() if train_mode else self._model.eval()

        losses, metrics_list = [], []

        # Iterate over the data loader
        for batch in tqdm(dataloader, desc=phase):
            # Move batch elements to the appropriate device
            batch = tuple(b.to(DEVICE) for b in batch)

            loss, batch_metrics = self._train_batch(batch) if train_mode else self._evaluate_batch(batch)

            # Accumulate the loss and metrics
            losses.append(loss)
            metrics_list.append(batch_metrics)

        # Compute average loss and metrics for the epoch
        avg_loss = np.mean(losses)
        avg_metrics = {metric: np.mean([m[metric] for m in metrics_list]) for metric in metrics_list[0]}

        return avg_loss, avg_metrics
