from typing import List

import pandas as pd

from src.settings import LABEL_TYPE


class LabelInitializer:
    """
    Class to initialize label mappings and generate labels for a given dataset.
    """

    def __init__(self):
        self._gt = {}

    def initialize_label_mapping(self, data: pd.DataFrame) -> int:
        """
        Initialize the label mapping for the properties.

        :param data: DataFrame containing the dataset with a 'property' column.
        :type data: pd.DataFrame
        :return: The number of unique properties.
        :rtype: int
        """
        unique_properties = data[LABEL_TYPE].dropna().unique()
        self._gt = {str(prop): idx for idx, prop in enumerate(unique_properties)}
        return len(self._gt)

    def initialize_labels(self, group: pd.DataFrame) -> List[int]:
        """
        Initialize labels for a given group of data.

        :param group: DataFrame containing a group of data.
        :type group: pd.DataFrame
        :return: List of initialized labels.
        :rtype: List[int]
        """
        num_labels = len(self._gt)
        labels = [0] * num_labels
        for _, row in group.iterrows():
            prop = str(row[LABEL_TYPE])
            if row['property_holds'] == 't':
                labels[self._gt[prop]] = 1
        return labels
