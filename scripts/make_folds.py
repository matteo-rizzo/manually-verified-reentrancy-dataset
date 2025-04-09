import argparse
import os
import shutil

from sklearn.model_selection import KFold


def create_cv_split(split_index, dataset_folder, k):
    """
    Creates one cross-validation split using scikit-learn's KFold.

    For each class folder in dataset_folder:
      - List files and sort them (to ensure reproducibility).
      - Use KFold with k splits (with shuffling and a fixed random_state).
      - Select the train and test indices for the current split index.
      - Copy the files into the corresponding cv_split folder with subdirectories
        for 'train' and 'test', preserving the original class structure.

    Args:
        split_index (int): The current CV fold (0-indexed).
        dataset_folder (str): Path to the original dataset folder.
        k (int): Number of KFold splits.
    """
    cv_split_dir = f"logs/cv_split_{split_index + 1}"
    train_dir = os.path.join(cv_split_dir, "train")
    test_dir = os.path.join(cv_split_dir, "test")
    os.makedirs(train_dir, exist_ok=True)
    os.makedirs(test_dir, exist_ok=True)

    # Iterate over each class subfolder
    for class_name in os.listdir(dataset_folder):
        class_folder = os.path.join(dataset_folder, class_name)
        if os.path.isdir(class_folder):
            files = [f for f in os.listdir(class_folder)
                     if os.path.isfile(os.path.join(class_folder, f))]
            files.sort()  # Ensure a fixed order for reproducibility
            if len(files) < k:
                print(
                    f"Warning: Class '{class_name}' has fewer files ({len(files)}) than the number of folds ({k}). Skipping this class.")
                continue

            # Create the KFold splits for this class
            kf = KFold(n_splits=k, shuffle=True, random_state=42)
            splits = list(kf.split(files))
            train_indices, test_indices = splits[split_index]

            train_files = [files[i] for i in train_indices]
            test_files = [files[i] for i in test_indices]

            # Create the subdirectories for this class in train and test splits
            train_class_dir = os.path.join(train_dir, class_name)
            test_class_dir = os.path.join(test_dir, class_name)
            os.makedirs(train_class_dir, exist_ok=True)
            os.makedirs(test_class_dir, exist_ok=True)

            # Copy training files
            for filename in train_files:
                src = os.path.join(class_folder, filename)
                dst = os.path.join(train_class_dir, filename)
                shutil.copy2(src, dst)

            # Copy testing files
            for filename in test_files:
                src = os.path.join(class_folder, filename)
                dst = os.path.join(test_class_dir, filename)
                shutil.copy2(src, dst)


def main():
    parser = argparse.ArgumentParser(
        description="Create k cross-validation splits for a dataset using scikit-learn's KFold split. "
                    "The dataset folder should contain subfolders for each class."
    )
    parser.add_argument("--data_dir", type=str, required=True,
                        help="Path to the dataset folder (which contains class subfolders)")
    parser.add_argument("--cv_splits", type=int, default=5,
                        help="Number of cross-validation folds to create")
    args = parser.parse_args()

    data_dir = args.data_dir
    k = args.cv_splits

    # Create each CV split folder using the kth fold for each class.
    for split_index in range(k):
        print(f"Creating CV split {split_index + 1} of {k}")
        create_cv_split(split_index, data_dir, k)

    print("All CV splits have been created successfully.")


if __name__ == "__main__":
    main()
