import torch
from torch import nn


class FFNNClassifier(nn.Module):
    """
    Simple Feed-Forward Neural Network (FFNN) with three fully connected layers.
    """

    def __init__(self, input_size: int, output_size: int):
        """
        Initialize the network layers.

        :param input_size: Size of the input features.
        :param output_size: Number of output classes.
        """
        super(FFNNClassifier, self).__init__()

        # Define three fully connected layers with ReLU activation
        self.fc1 = nn.Linear(input_size, 512)
        self.fc2 = nn.Linear(512, 128)
        self.fc3 = nn.Linear(128, output_size)
        self.relu = nn.ReLU()

    def forward(self, x: torch.Tensor) -> torch.Tensor:
        """
        Forward pass through the network.

        :param x: Input tensor.
        :return: Output tensor.
        """
        # Apply ReLU activation after each fully connected layer except the last one
        x = self.relu(self.fc1(x))
        x = self.relu(self.fc2(x))
        x = self.fc3(x)
        return x
