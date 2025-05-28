from typing import Union, List, Dict

import numpy as np
from scipy.sparse import hstack
from sklearn.feature_extraction.text import TfidfVectorizer


class MultimodalVectorizer:
    def __init__(self, max_features: int, multimodal: bool):
        """
        Initializes the vectorizers based on the configuration.

        :param max_features: Maximum number of features for the TF-IDF vectorizer.
        :param multimodal: Boolean indicating if multiple modalities are being used.
        """
        self.__multimodal = multimodal
        if multimodal:
            self.__vectorizers = {
                "source": TfidfVectorizer(max_features=max_features),
                "bytecode": TfidfVectorizer(max_features=max_features),
                "runtime": TfidfVectorizer(max_features=max_features),
                "opcode": TfidfVectorizer(max_features=max_features)
            }
        else:
            self.__vectorizer = TfidfVectorizer(max_features=max_features)

    def transform_inputs(self, inputs: Union[List[str], Dict[str, List[str]]]) -> np.ndarray:
        """
        Transform the input documents into TF-IDF features for each modality and concatenate them.

        :param inputs: List of input documents or dictionary of input documents for each modality.
        :return: Combined TF-IDF feature matrix.
        :raises ValueError: If the input type does not match the vectorizer configuration.
        """
        if isinstance(inputs, dict):
            if not self.__multimodal:
                raise ValueError("When inputs is a dictionary, vectorizer must also be configured for multimodal.")

            modality_features = [self.__vectorizers[modality].fit_transform(data) for modality, data in inputs.items()]
            return hstack(modality_features).toarray()

        if self.__multimodal:
            raise ValueError("When inputs is a list, vectorizer must not be configured for multimodal.")

        return self.__vectorizer.fit_transform(inputs).toarray()
