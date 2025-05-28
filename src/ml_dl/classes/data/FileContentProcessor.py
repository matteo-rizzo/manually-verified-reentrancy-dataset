from typing import List, Union, Dict

import pandas as pd
from torch_geometric.data import Data

from src.classes.data.FileLoader import FileLoader


class FileContentProcessor:
    """
    Class to process file contents based on file types and labels.

    :param file_loader: Instance of FileLoader to load and preprocess file content.
    :type file_loader: FileLoader
    """

    def __init__(self, file_loader: FileLoader):
        self.__file_loader = file_loader

    def process_file_contents(self, group: pd.DataFrame, file_types: List[str], labels: List[int]) -> Union[
        Dict[str, str], List[Data], bool]:
        """
        Processes the file contents based on the provided file types and labels.

        :param group: DataFrame containing the group of files to process.
        :type group: pd.DataFrame
        :param file_types: List of file types to process.
        :type file_types: List[str]
        :param labels: List of labels associated with the files.
        :type labels: List[int]
        :return: Processed file contents, AST data, CFG data, or False if processing fails.
        :rtype: Union[Dict[str, str], List[Data], bool]
        """
        file_contents = {}
        graph_data = []

        for file_type in file_types:
            file_content = self.__file_loader.get_file_content(group, file_type)
            if not file_content:
                return False

            processed_content = self.__file_loader.preprocess(file_content, file_type, labels)

            if file_type in ["ast", "cfg"]:
                graph_data.append(processed_content)
            else:
                file_contents[file_type] = processed_content

        return graph_data if graph_data else file_contents
