from typing import Dict, List

import numpy as np
import pandas as pd
from iterstrat.ml_stratifiers import MultilabelStratifiedKFold
from sklearn.model_selection import StratifiedKFold
from sklearn.decomposition import PCA
from sklearn.base import ClassifierMixin
from sklearn.multiclass import OneVsRestClassifier

from src.classes.training.MetricsHandler import MetricsHandler


class ClassifiersPoolEvaluator:
    def __init__(self, inputs: np.ndarray, labels: np.ndarray, classifiers: Dict[str, ClassifierMixin], num_folds: int,
                 random_seed: int, pca_components: int = None, is_multilabel: bool = False):
        """
        Initialize the ClassifiersPoolEvaluator with inputs, labels, classifiers, number of folds,
        random seed, and optional PCA components.

        :param inputs: Feature matrix.
        :param labels: Labels array.
        :param classifiers: Dictionary of classifiers to evaluate.
        :param num_folds: Number of folds for cross-validation.
        :param random_seed: Random seed for reproducibility.
        :param pca_components: Number of PCA components for dimensionality reduction.
        :param is_multilabel: Boolean flag to indicate if the task is multilabel.
        """
        self.classifiers = classifiers
        self.num_folds = num_folds
        self.random_seed = random_seed
        self.inputs = inputs
        self.labels = labels
        self.pca_components = pca_components
        self.is_multilabel = is_multilabel

        if self.pca_components is not None:
            self._apply_pca()

    def _apply_pca(self) -> None:
        """
        Apply PCA to reduce the dimensionality of the input data.
        """
        print(f"Applying PCA to reduce dimensionality to {self.pca_components} components.")
        pca = PCA(n_components=self.pca_components, random_state=self.random_seed)
        self.inputs = pca.fit_transform(self.inputs)
        print(f"New shape of inputs after PCA: {self.inputs.shape}")

    def _evaluate_fold(self, classifier: ClassifierMixin, train_index: List[int], test_index: List[int],
                       fold_num: int) -> Dict[str, float]:
        """
        Evaluate a single fold during cross-validation.

        :param classifier: Classifier to evaluate.
        :param train_index: Training indices for the fold.
        :param test_index: Testing indices for the fold.
        :param fold_num: Current fold number.
        :return: Dictionary of evaluation metrics.
        """
        x_train, x_test = self.inputs[train_index], self.inputs[test_index]
        y_train, y_test = self.labels[train_index], self.labels[test_index]

        classifier.fit(x_train, y_train)
        predictions = classifier.predict(x_test)

        metrics = MetricsHandler.compute_metrics(y_test, predictions)
        print(f"Results for fold {fold_num} | ", end="")
        MetricsHandler.print_metrics(metrics)
        return metrics

    def _k_fold_cv(self, classifier: ClassifierMixin) -> pd.DataFrame:
        """
        Perform k-fold cross-validation on a given classifier.

        :param classifier: Classifier to evaluate.
        :return: DataFrame containing evaluation results for all folds.
        """
        if self.is_multilabel:
            splitter = MultilabelStratifiedKFold(n_splits=self.num_folds, shuffle=True, random_state=self.random_seed)
            split_method = splitter.split(self.inputs, self.labels)
        else:
            splitter = StratifiedKFold(n_splits=self.num_folds, shuffle=True, random_state=self.random_seed)
            split_method = splitter.split(self.inputs, np.argmax(self.labels, axis=1) if self.labels.ndim > 1 else self.labels)

        results = [self._evaluate_fold(classifier, train_index, test_index, fold_num)
                   for fold_num, (train_index, test_index) in enumerate(split_method, 1)]
        return pd.DataFrame(results)

    def pool_evaluation(self, log_dir: str = "") -> None:
        """
        Evaluate all classifiers in the pool and save the results.

        :param log_dir: Directory to save evaluation results.
        """
        for classifier_name, classifier in self.classifiers.items():
            print(f"\nTesting classifier: {classifier_name}\n")

            classifier_to_use = OneVsRestClassifier(classifier) if self.is_multilabel else classifier
            metrics_df = self._k_fold_cv(classifier_to_use)
            MetricsHandler.save_results(metrics_df, f"{classifier_name}.csv", log_dir=log_dir)

            average_metrics = metrics_df.mean().to_dict()
            print(f"\nAverage results for {classifier_name}:")
            MetricsHandler.print_metrics(average_metrics)
