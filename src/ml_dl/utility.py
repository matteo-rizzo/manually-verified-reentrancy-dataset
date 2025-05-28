import argparse
import os
import random
from argparse import ArgumentParser
from typing import Dict

import numpy as np
import torch

from src.settings import SUBSET, FILE_TYPE, RANDOM_SEED, PATH_TO_DATASET, NUM_FOLDS, TEST_SIZE, LABEL_TYPE


def make_reproducible(random_seed: int):
    """
    Set random seeds for reproducibility.

    :param random_seed: The seed to use for random number generation.
    """
    torch.manual_seed(random_seed)
    np.random.seed(random_seed)
    random.seed(random_seed)
    torch.backends.cudnn.benchmark = False


def get_file_config(file_type: str) -> Dict:
    return {
        "type": file_type,
        "id": get_file_id(file_type),
        "ext": get_file_ext(file_type)
    }


def get_file_ext(file_type: str) -> str:
    """
    Determine file extension based on file type.

    :param file_type: The type of file.
    :return: The file extension corresponding to the file type.
    :raises ValueError: If the file type is not supported.
    """
    if file_type == "source":
        return ".sol"
    elif file_type == "runtime":
        return ".rt.hex"
    elif file_type == "bytecode":
        return ".hex"
    elif file_type == "ast":
        return ".ast.json"
    elif file_type == "cfg":
        return ".json"
    elif file_type == "opcode":
        return ".opcodes.txt"
    else:
        raise ValueError(f"File type '{file_type}' has no supported file extension!")


def get_file_id(file_type: str) -> str:
    """
    Determine file id based on file type.

    :param file_type: The type of file.
    :return: The file id corresponding to the file type.
    :raises ValueError: If the file type is not supported.
    """
    if file_type == "source":
        return "sol"
    elif file_type == "runtime":
        return "runtime"
    elif file_type == "bytecode":
        return "bytecode"
    elif file_type == "ast":
        return "ast"
    elif file_type == "cfg":
        return "cfg"
    elif file_type == "opcode":
        return "opcode"
    else:
        raise ValueError(f"File type '{file_type}' has no supported file ID!")


def init_arg_parser() -> ArgumentParser:
    """
    Initialize and return an argument parser.

    :return: The argument parser with configured arguments.
    """
    parser = argparse.ArgumentParser(description="Set configurations for the CGT dataset processing.")
    parser.add_argument("--subset", type=str, default=SUBSET, help="Subset dataset to consider within CGT")
    parser.add_argument("--file_type", type=str, default=FILE_TYPE, help="File type",
                        choices=["source", "runtime", "bytecode", "ast", "cfg", "opcode"])
    parser.add_argument("--random_seed", type=int, default=RANDOM_SEED, help="Random seed for reproducibility")
    parser.add_argument("--path_to_dataset", type=str, default=PATH_TO_DATASET, help="Path to dataset")
    parser.add_argument("--num_folds", type=int, default=NUM_FOLDS, help="Number of folds")
    parser.add_argument("--test_size", type=float, default=TEST_SIZE, help="Test size")
    return parser


def make_log_dir(experiment_id: str):
    """
    Create the log directory if it doesn't exist.

    :param experiment_id: The ID of the experiment.
    :return: The path to the log directory.
    """
    log_dir = os.path.join("log_{}".format(LABEL_TYPE), f"experiment_{experiment_id}")
    if not os.path.exists(log_dir):
        os.makedirs(log_dir)
        print(f"Log directory created at {log_dir}")
    else:
        print(f"Log directory already exists at {log_dir}")
    return log_dir
