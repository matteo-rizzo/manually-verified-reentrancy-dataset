import os
from typing import List, Dict, Union, Tuple

import pandas as pd
from torch_geometric.data import Data
from tqdm import tqdm

from src.classes.data.DataHandler import DataHandler
from src.classes.data.FileContentProcessor import FileContentProcessor
from src.classes.data.FileLoader import FileLoader
from src.classes.data.LabelInitializer import LabelInitializer
from src.settings import LABEL_TYPE, DATASET_NAME


class DataPreprocessor:
    """
    Class to preprocess data by loading, filtering, and processing file contents and labels.

    :param path_to_dataset: Path to the dataset directory.
    :type path_to_dataset: str
    :param file_types: List of file types to process.
    :type file_types: List[str]
    :param subset: Subset of the dataset to process.
    :type subset: str
    """

    def __init__(self, path_to_dataset: str, file_types: List[str], subset: str):
        self.path_to_dataset = path_to_dataset
        self.file_types = file_types
        self.subset = subset
        self.file_loader = FileLoader(path_to_dataset, file_types)
        self.label_initializer = LabelInitializer()
        self.content_processor = FileContentProcessor(self.file_loader)
        self.data_handler = DataHandler(file_types)

    def _process_group(self, item_id: str, group: pd.DataFrame) -> bool:
        """
        Processes a group of files identified by an item ID.

        :param item_id: Unique identifier for the group of files.
        :type item_id: str
        :param group: DataFrame containing the group of files to process.
        :type group: pd.DataFrame
        :return: True if the group was processed successfully, False otherwise.
        :rtype: bool
        """
        labels = self.label_initializer.initialize_labels(group)
        file_contents_or_graph_data = self.content_processor.process_file_contents(group, self.file_types, labels)

        if not file_contents_or_graph_data:
            return False

        self.data_handler.add_data(item_id, file_contents_or_graph_data, labels)
        return True

    def _filter_and_preprocess_data(self, data: pd.DataFrame) -> Union[pd.DataFrame, List[Data]]:
        """
        Filters and preprocesses the data by removing rows with NA values and processing each group.

        :param data: DataFrame containing the dataset to preprocess.
        :type data: pd.DataFrame
        :return: Filtered and processed data or Graph data.
        :rtype: Union[pd.DataFrame, List[Data]]
        """
        data = self._drop_na_rows(data)
        self.label_initializer.initialize_label_mapping(data)
        grouped_data = data.groupby('id')
        valid_rows = []

        for item_id, group in tqdm(grouped_data, desc="Processing items"):
            try:
                if self._process_group(item_id, group):
                    valid_rows.append(group)
            except Exception as e:
                print(f"Error processing item_id {item_id}: {e}")
                raise

        if len(self.file_types) == 1 and self.file_types[0] in ["ast", "cfg"]:
            return self.data_handler.get_inputs()[self.file_types[0]]

        return pd.concat(valid_rows, ignore_index=True)

    def _drop_na_rows(self, data: pd.DataFrame) -> pd.DataFrame:
        """
        Drops rows with NA values for the specified file types.

        :param data: DataFrame containing the dataset to filter.
        :type data: pd.DataFrame
        :return: DataFrame with NA rows removed.
        :rtype: pd.DataFrame
        """
        for file_type in self.file_types:
            file_col = f"fp_{self.file_loader.get_file_config(file_type)['id']}"
            data = data.dropna(subset=[file_col]).dropna(subset=[LABEL_TYPE])
        return data

    def load_and_process_data(self) -> Union[None, Tuple[List[Data], List[List[int]]]]:
        """
        Loads and processes the dataset.

        :return: Processed data and labels if graph conversion is used, None otherwise.
        :rtype: Union[None, Tuple[List[Data], List[List[int]]]]
        """
        dataset = pd.read_csv(os.path.join(self.path_to_dataset, DATASET_NAME), sep=",")
        if self.subset != "":
            dataset = dataset[dataset["dataset"] == self.subset]
        processed_data = self._filter_and_preprocess_data(dataset)

        if self.file_loader.graph_converter:
            return processed_data, self.data_handler.get_labels()

        return None

    def get_inputs(self) -> Union[List[Union[str, Data]], Dict[str, List[Union[str, Data]]]]:
        """
        Retrieves the stored inputs.

        :return: Dictionary of stored inputs.
        :rtype: Union[List[Union[str, Data]], Dict[str, List[Union[str, Data]]]]
        """
        inputs = self.data_handler.get_inputs()

        if len(self.file_types) == 1:
            return inputs[self.file_types[0]]

        return inputs

    def get_labels(self) -> List[List[int]]:
        """
        Retrieves the stored labels.

        :return: List of stored labels.
        :rtype: List[List[int]]
        """
        return self.data_handler.get_labels()

    def get_num_labels(self) -> int:
        return len(self.get_labels()[0])
