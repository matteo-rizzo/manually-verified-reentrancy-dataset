import torch
from torch import nn


class LSTMClassifier(nn.Module):
    def __init__(self, embedding_dim, hidden_dim, output_dim, num_layers=1, dropout=0.5, pooling="avg_max"):
        """
        Optimized LSTM classifier with bidirectional LSTM, dropout, and combined average and max pooling.

        :param embedding_dim: Dimension of input embeddings.
        :param hidden_dim: Number of hidden units in one LSTM direction.
        :param output_dim: Number of output classes.
        :param num_layers: Number of LSTM layers.
        :param dropout: Dropout rate applied to the pooled representation.
        :param pooling: Pooling strategy; "avg_max" uses both average and max pooling,
                        any other value will use average pooling only.
        """
        super(LSTMClassifier, self).__init__()
        self.lstm = nn.LSTM(
            input_size=embedding_dim,
            hidden_size=hidden_dim,
            num_layers=num_layers,
            batch_first=True,
            bidirectional=True,
            dropout=dropout if num_layers > 1 else 0.0
        )
        self.dropout = nn.Dropout(dropout)
        self.pooling = pooling

        if self.pooling == "avg_max":
            # Bidirectional: hidden_dim * 2, then concatenated average and max pooling gives hidden_dim * 4.
            fc_input_dim = hidden_dim * 4
        else:
            fc_input_dim = hidden_dim * 2

        self.fc = nn.Linear(fc_input_dim, output_dim)

    def forward(self, x, lengths=None):
        """
        Forward pass of the LSTM classifier.

        :param x: Tensor of shape [batch, seq_len, embedding_dim].
        :param lengths: Optional 1D tensor or list of actual sequence lengths for each sample in the batch.
        :return: Output logits of shape [batch, output_dim].
        """
        # If sequence lengths are provided, pack the padded sequence for improved efficiency.
        if lengths is not None:
            packed_x = nn.utils.rnn.pack_padded_sequence(x, lengths, batch_first=True, enforce_sorted=False)
            packed_out, _ = self.lstm(packed_x)
            lstm_out, _ = nn.utils.rnn.pad_packed_sequence(packed_out, batch_first=True)
        else:
            lstm_out, _ = self.lstm(x)

        if self.pooling == "avg_max":
            # Compute average and max pooling along the sequence dimension.
            avg_pool = torch.mean(lstm_out, dim=1)
            max_pool, _ = torch.max(lstm_out, dim=1)
            pooled = torch.cat((avg_pool, max_pool), dim=1)
        else:
            pooled = torch.mean(lstm_out, dim=1)

        pooled = self.dropout(pooled)
        output = self.fc(pooled)
        return output
