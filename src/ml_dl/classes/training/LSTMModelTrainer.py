from typing import Tuple, Dict

import torch
from torch.optim import AdamW
from transformers import RobertaModel

from src.classes.training.MetricsHandler import MetricsHandler
from src.classes.training.Trainer import Trainer
from src.settings import LR


class LSTMModelTrainer(Trainer):
    """
    LSTMModelTrainer for handling the training and evaluation of an LSTM-based model that uses CodeBERT embeddings.
    Inherits from the Trainer class.
    """

    def __init__(self, model: torch.nn.Module, max_length: int = 128):
        """
        Initialize the LSTMModelTrainer with a model, optimizer, loss function, and CodeBERT components.

        :param model: The LSTM-based model to be trained.
        :param max_length: The maximum sequence length for tokenization.
        """
        super().__init__(model)
        # Initialize the optimizer with model parameters and a learning rate.
        self._optimizer = AdamW(self._model.parameters(), lr=LR)

        # Load CodeBERT tokenizer and model
        self._codebert = RobertaModel.from_pretrained("microsoft/codebert-base")
        self._codebert.eval()  # Set CodeBERT to evaluation mode
        for param in self._codebert.parameters():
            param.requires_grad = False  # Freeze CodeBERT weights

        self._max_length = max_length

    def _embed_code(self, raw_codes: Dict[str, torch.Tensor]) -> torch.Tensor:
        """
        Tokenize and embed raw code strings using CodeBERT.

        :param raw_codes: A list of raw code strings.
        :return: A tensor of embeddings with shape [batch_size, seq_length, embedding_dim].
        """
        with torch.no_grad():
            outputs = self._codebert(**raw_codes)
        # The last_hidden_state shape is [batch_size, seq_length, hidden_dim]
        embeddings = outputs.last_hidden_state
        return embeddings

    def _evaluate_batch(self, batch: Tuple[torch.Tensor, torch.Tensor, torch.Tensor]) -> Tuple[float, Dict[str, float]]:
        """
        Evaluate a single batch of data by embedding raw code and computing loss/metrics.

        :param batch: A tuple containing a list of code strings and a labels tensor.
        :return: A tuple containing the loss value and a dictionary of computed metrics.
        """
        # Prepare inputs for the model
        inputs = {'input_ids': batch[0], 'attention_mask': batch[1]}
        labels = batch[2]

        # Convert raw code to embeddings via CodeBERT
        embeddings = self._embed_code(inputs)

        # Evaluate the LSTM on these embeddings
        with torch.no_grad():
            outputs = self._model(embeddings)
            loss = self._loss_fn(outputs, labels)
            predictions = torch.sigmoid(outputs).round().cpu().numpy()
            batch_metrics = MetricsHandler.compute_metrics(labels.cpu().numpy(), predictions)

        return loss.item(), batch_metrics

    def _train_batch(self, batch: Tuple[torch.Tensor, torch.Tensor, torch.Tensor]) -> Tuple[float, Dict[str, float]]:
        """
        Train a single batch of data by embedding raw code and performing a training step on the LSTM.

        :param batch: A tuple containing a list of code strings and a labels tensor.
        :return: A tuple containing the loss value and a dictionary of computed metrics.
        """
        # Prepare inputs for the model
        inputs = {'input_ids': batch[0], 'attention_mask': batch[1]}
        labels = batch[2]

        # Zero the gradients in the LSTM model
        self._model.zero_grad()

        # Get token embeddings from CodeBERT
        embeddings = self._embed_code(inputs)

        # Forward pass through the LSTM classifier
        outputs = self._model(embeddings)
        loss = self._loss_fn(outputs, labels)

        # Backward pass and optimization
        loss.backward()
        self._optimizer.step()

        # Compute predictions and metrics
        predictions = torch.sigmoid(outputs).round().detach().cpu().numpy()
        batch_metrics = MetricsHandler.compute_metrics(labels.detach().cpu().numpy(), predictions)

        return loss.item(), batch_metrics
