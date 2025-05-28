import os
import warnings

import torch


def warn(*args, **kwargs):
    pass


warnings.warn = warn

# Set the device for torch (use GPU if available)
DEVICE = torch.device("cuda:0" if torch.cuda.is_available() else "cpu")
print(f"Running on device {DEVICE}")

# Reproducibility
RANDOM_SEED = 0

# Default configuration constants
PATH_TO_DATASET = os.path.join("dataset", "handcrafted")
DATASET_NAME = "handcrafted.csv"
MAX_FEATURES = 128
PCA_COMPONENTS = 128
USE_CLASS_WEIGHTS = False
BATCH_SIZE = 8
NUM_FOLDS = 3
NUM_EPOCHS = 30
LR = 0.0001
TEST_SIZE = 0.1
FILE_TYPE = "source"
SUBSET = ""
LABEL_TYPE = "property"
