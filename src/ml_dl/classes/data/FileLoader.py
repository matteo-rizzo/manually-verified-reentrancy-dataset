import json
import os
import re
from typing import List, Union, Optional, Dict

import pandas as pd
from torch_geometric.data import Data

from src.classes.data.graphs.GraphConverter import GraphConverter
from src.utility import get_file_config


class FileLoader:
    """
    Class to load and preprocess file contents from a dataset.

    :param path_to_dataset: Path to the dataset directory.
    :type path_to_dataset: str
    :param file_types: List of file types (e.g., ["sol", "bytecode", "runtime", "ast", "opcode", "cfg"]).
    :type file_types: List[str]
    """

    def __init__(self, path_to_dataset: str, file_types: List[str]):
        self.__path_to_dataset = path_to_dataset
        self.__file_configs = {file_type: get_file_config(file_type) for file_type in file_types}
        self.graph_converter = GraphConverter()

    @staticmethod
    def __preprocess_hex(hex_data: str) -> str:
        """
        Convert hex data to a readable ASCII string.

        :param hex_data: Hexadecimal data string.
        :type hex_data: str
        :return: Readable ASCII string.
        :rtype: str
        """
        byte_data = bytes.fromhex(hex_data.strip())
        return ' '.join(f'{byte:02x}' for byte in byte_data)

    @staticmethod
    def __preprocess_solidity_code(code: str) -> str:
        """
        Preprocess Solidity code by removing comments and blank lines.

        :param code: Solidity code string.
        :type code: str
        :return: Preprocessed Solidity code.
        :rtype: str
        """
        code = re.sub(r'//.*', '', code)
        code = re.sub(r'/\*.*?\*/', '', code, flags=re.DOTALL)
        lines = code.split('\n')
        return '\n'.join(line for line in lines if line.strip())

    def __preprocess_ast(self, ast_json: str, labels: List[int]) -> Data:
        """
        Preprocess AST JSON data and convert it to a PyTorch Geometric Data object.

        :param ast_json: AST JSON string.
        :type ast_json: str
        :param labels: List of labels associated with the AST.
        :type labels: List[int]
        :return: PyTorch Geometric Data object.
        :rtype: Data
        """
        ast_dict = json.loads(ast_json)
        data_graph = self.graph_converter.ast_to_graph(ast_dict)
        return data_graph

    @staticmethod
    def __preprocess_opcode(opcode_data: str) -> str:
        """
        Preprocess opcode by removing blank lines, unnecessary whitespace, and generalizing constants.

        :param opcode_data: Opcode string.
        :type opcode_data: str
        :return: Preprocessed opcode string.
        :rtype: str
        """
        # Remove any comments (assuming comments start with ';')
        opcode_data = re.sub(r';.*', '', opcode_data)

        # Split the opcode data into lines and remove blank lines
        lines = opcode_data.split('\n')
        cleaned_lines = [line.strip() for line in lines if line.strip()]

        # Join the cleaned lines into a single string
        opcode_str = ' '.join(cleaned_lines)

        # Replace PUSH instructions with constants with a placeholder
        opcode_str = re.sub(r'(PUSH\d+)\s+(0x[0-9a-fA-F]+|\d+)', r'\1 [CONST]', opcode_str)

        # Replace remaining hexadecimal constants with a placeholder
        opcode_str = re.sub(r'0x[0-9a-fA-F]+', '[CONST]', opcode_str)

        # Replace decimal numbers with a placeholder
        opcode_str = re.sub(r'\b\d+\b', '[CONST]', opcode_str)

        return opcode_str

    def __preprocess_cfg(self, cfg_json: str) -> Data:
        """
        Preprocess CFG JSON data and convert it to a PyTorch Geometric Data object.

        :param cfg_json: CFG JSON string.
        :type cfg_json: str
        :return: PyTorch Geometric Data object.
        :rtype: Data
        """
        cfg_dict = json.loads(cfg_json)
        # Assuming you have a CFG to Graph converter, which might be similar to the GraphConverter
        cfg_graph = self.graph_converter.cfg_to_graph(cfg_dict)
        return cfg_graph

    def preprocess(self, data: str, file_type: str, labels: List[int] = None) -> Union[str, Data]:
        """
        Preprocess data based on the file type.

        :param data: Data string to preprocess.
        :type data: str
        :param file_type: Type of the file.
        :type file_type: str
        :param labels: Optional list of labels for AST data.
        :type labels: List[int], optional
        :return: Preprocessed data.
        :rtype: Union[str, Data]
        """
        file_config = self.get_file_config(file_type)
        if file_config["type"] == "source":
            return self.__preprocess_solidity_code(data)
        elif file_config["type"] == "ast" and labels is not None:
            return self.__preprocess_ast(data, labels)
        elif file_type == "opcode":
            return self.__preprocess_opcode(data)
        elif file_type == "cfg":
            return self.__preprocess_cfg(data)
        return self.__preprocess_hex(data)

    def __load_file(self, file_id: str, file_type: str) -> str:
        """
        Load the content of a file given its ID and type, trying multiple encodings.

        :param file_id: Identifier of the file.
        :type file_id: str
        :param file_type: Type of the file.
        :type file_type: str
        :return: Content of the file.
        :rtype: str
        """
        file_config = self.get_file_config(file_type)
        path_to_file = os.path.join(self.__path_to_dataset, file_config["type"], f"{file_id}{file_config['ext']}")
        encodings_to_try = ["utf8", "utf-16", "latin1", "ascii"]

        if os.path.exists(path_to_file):
            for encoding in encodings_to_try:
                try:
                    with open(path_to_file, 'r', encoding=encoding) as file:
                        return file.read()
                except UnicodeDecodeError:
                    print(f"Failed to read {path_to_file} with encoding {encoding}. Trying next encoding.")
                except Exception as e:
                    print(f"Unexpected error while reading {path_to_file}: {e}")
            print(f"All encoding attempts failed for file {path_to_file}.")
        else:
            print(f"File not found: {path_to_file}")
        return ""

    def get_file_content(self, group: pd.DataFrame, file_type: str) -> Optional[str]:
        """
        Retrieve the file content for a specific file type from the group.

        :param group: DataFrame containing the group of files.
        :type group: pd.DataFrame
        :param file_type: Type of the file.
        :type file_type: str
        :return: Content of the file if it exists, None otherwise.
        :rtype: Optional[str]
        """
        file_col = f"fp_{self.get_file_config(file_type)['id']}"
        file_id = group.iloc[0][file_col]
        return self.__load_file(file_id, file_type)

    def get_file_config(self, file_type: str) -> Dict[str, Union[str, int]]:
        """
        Get the file configuration for a specific file type.

        :param file_type: Type of the file.
        :type file_type: str
        :return: Dictionary of the file configuration.
        :rtype: Dict[str, Union[str, int]]
        """
        return self.__file_configs[file_type]
