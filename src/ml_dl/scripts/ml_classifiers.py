from typing import Dict

import nltk
import numpy as np
from sklearn.ensemble import RandomForestClassifier, GradientBoostingClassifier
from sklearn.linear_model import LogisticRegression
from sklearn.naive_bayes import GaussianNB
from sklearn.neighbors import KNeighborsClassifier
from sklearn.svm import SVC
from xgboost import XGBClassifier

from src.classes.classifiers.ClassifiersPoolEvaluator import ClassifiersPoolEvaluator
from src.classes.classifiers.GraphClassifiersPoolEvaluator import GraphClassifiersPoolEvaluator
from src.classes.data.DataPreprocessor import DataPreprocessor
from src.classes.data.MultimodalVectorizer import MultimodalVectorizer
from src.settings import MAX_FEATURES, DEVICE, PCA_COMPONENTS
from src.utility import make_reproducible, init_arg_parser, make_log_dir

nltk.download('punkt_tab')
nltk.download('averaged_perceptron_tagger_eng')

MULTIMODAL = False
MULTIMODAL_FILE_TYPES = ["source", "bytecode", "runtime"]


def initialize_classifiers(random_seed: int) -> Dict[str, object]:
    """
    Initializes classifiers with the given random seed, optimized for speed,
    and uses GPU if available for models like XGBoost.

    :param random_seed: The random seed for reproducibility.
    :return: A dictionary of classifier instances.
    """
    # Check if GPU is available for XGBoost
    use_gpu = str(DEVICE) != "cpu"

    if use_gpu:
        print("GPU detected. Using GPU for applicable models.")

    return {
        "svm": SVC(kernel='linear', probability=False, C=0.1, random_state=random_seed),
        "gnb": GaussianNB(),
        "logistic_regression": LogisticRegression(
            C=0.1, solver='liblinear', max_iter=100, random_state=random_seed
        ),
        "knn": KNeighborsClassifier(
            n_neighbors=10, weights='distance', metric='minkowski', n_jobs=-1
        ),
        "random_forest": RandomForestClassifier(
            n_estimators=100, max_depth=8, min_samples_split=5,
            min_samples_leaf=2, max_features='sqrt', n_jobs=-1,
            random_state=random_seed
        ),
        "gradient_boosting": GradientBoostingClassifier(
            n_estimators=100, learning_rate=0.05, max_depth=4,
            min_samples_split=2, min_samples_leaf=1, random_state=random_seed
        ),
        "xgboost": XGBClassifier(
            eval_metric='mlogloss', use_label_encoder=False, n_estimators=100,
            max_depth=5, learning_rate=0.1, colsample_bytree=0.8,
            subsample=0.8, random_state=random_seed, n_jobs=-1,
            tree_method='gpu_hist' if use_gpu else 'hist',
            predictor='gpu_predictor' if use_gpu else 'cpu_predictor'
        )
    }


def main(config: Dict):
    # Initialize the DataPreprocessor
    print("Initializing DataPreprocessor...")
    preprocessor = DataPreprocessor(
        path_to_dataset=config['path_to_dataset'],
        file_types=MULTIMODAL_FILE_TYPES if config["multimodal"] else [config['file_type']],
        subset=config['subset']
    )

    print("Loading and processing data...")
    preprocessor.load_and_process_data()
    x, y = preprocessor.get_inputs(), preprocessor.get_labels()

    if config['file_type'] in ["ast", "cfg"]:
        evaluator = GraphClassifiersPoolEvaluator(
            inputs=x, labels=y,
            classifiers=initialize_classifiers(config['random_seed']),
            num_folds=config['num_folds'],
            random_seed=config['random_seed'],
            pca_components=config.get('pca_components')  # Pass PCA components
        )
    else:
        vectorizer = MultimodalVectorizer(max_features=config["max_features"], multimodal=config["multimodal"])

        print("Transforming input documents into TF-IDF features...")
        x = vectorizer.transform_inputs(x)
        print(f"TF-IDF feature matrix shape: {x.shape}")

        print("Converting labels to numpy array...")
        y = np.array(y)
        print(f"Labels shape: {y.shape}")

        evaluator = ClassifiersPoolEvaluator(
            inputs=x, labels=y,
            classifiers=initialize_classifiers(config['random_seed']),
            num_folds=config['num_folds'],
            random_seed=config['random_seed'],
            pca_components=config.get('pca_components')  # Pass PCA components
        )

    print("Starting pool evaluation...")
    evaluator.pool_evaluation(log_dir=config['log_dir'])


if __name__ == '__main__':
    parser = init_arg_parser()
    parser.add_argument("--max_features", type=int, default=MAX_FEATURES, help="Maximum features for TF-IDF vectorizer")
    parser.add_argument("--multimodal", type=bool, default=MULTIMODAL, help="Process multiple modalities at once")
    parser.add_argument("--pca_components", type=int, default=PCA_COMPONENTS,
                        help="Number of PCA components for dimensionality reduction")  # Add PCA argument

    args = parser.parse_args()
    config = vars(args)

    make_reproducible(config["random_seed"])

    experiment_id = f"{config['subset']}_{'multimodal' if config['multimodal'] else config['file_type']}"
    config["log_dir"] = make_log_dir(experiment_id)

    print("Configuration:")
    for arg, value in config.items():
        print(f"{arg}: {value}")

    print("Classifiers initialized:")
    classifiers = initialize_classifiers(config["random_seed"])
    for name, clf in classifiers.items():
        print(f" - {name}: {clf}")

    main(config)
