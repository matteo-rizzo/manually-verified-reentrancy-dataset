from typing import Tuple, Dict

import torch
from torch.optim import AdamW

from src.classes.training.MetricsHandler import MetricsHandler
from src.classes.training.Trainer import Trainer
from src.settings import LR


class BERTModelTrainer(Trainer):
    """
    BERTModelTrainer class for handling the training and evaluation of a BERT-based model.
    Inherits from the Trainer class.
    """

    def __init__(self, model: torch.nn.Module):
        """
        Initialize the BERTModelTrainer with model, optimizer, and loss function.

        :param model: The BERT model to be trained.
        """
        super().__init__(model)

        # Initialize the optimizer with model parameters and a learning rate
        self._optimizer = AdamW(self._model.parameters(), lr=LR)

    def _evaluate_batch(self, batch: Tuple[torch.Tensor, torch.Tensor, torch.Tensor]) -> Tuple[float, Dict[str, float]]:
        """
        Evaluate a single batch of data.

        :param batch: A tuple containing input_ids, attention_mask, and labels.
        :return: A tuple containing the loss and a dictionary of metrics.
        """
        # Prepare the inputs for the model
        inputs = {'input_ids': batch[0], 'attention_mask': batch[1]}
        labels = batch[2]

        # Disable gradient computation for evaluation
        with torch.no_grad():
            outputs = self._model(**inputs)

            # Compute the loss
            loss = self._loss_fn(outputs.logits, labels)

            # Make predictions and compute batch metrics
            predictions = torch.sigmoid(outputs.logits).round().cpu().numpy()
            batch_metrics = MetricsHandler.compute_metrics(labels.cpu().numpy(), predictions)

        # Return the loss and metrics
        return loss.item(), batch_metrics

    def _train_batch(self, batch: Tuple[torch.Tensor, torch.Tensor, torch.Tensor]) -> Tuple[float, Dict[str, float]]:
        """
        Train a single batch of data.

        :param batch: A tuple containing input_ids, attention_mask, and labels.
        :return: A tuple containing the loss and a dictionary of metrics.
        """
        # Prepare inputs for the model
        inputs = {'input_ids': batch[0], 'attention_mask': batch[1]}
        labels = batch[2]

        # Zero the parameter gradients
        self._model.zero_grad()

        # Forward pass
        outputs = self._model(**inputs)

        # Compute the loss
        loss = self._loss_fn(outputs.logits, labels)

        # Backward pass and optimize
        loss.backward()
        self._optimizer.step()

        # Make predictions and compute metrics
        predictions = torch.sigmoid(outputs.logits).round().detach().cpu().numpy()
        batch_metrics = MetricsHandler.compute_metrics(batch[2].detach().cpu().numpy(), predictions)

        return loss.item(), batch_metrics
