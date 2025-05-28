#!/bin/bash

# Define paths
VENV_PATH=".venv"
PYTHON_SCRIPT="src/scripts/explainability.py"

# Ensure the virtual environment exists
if [ ! -d "$VENV_PATH" ]; then
    echo "[ERROR] Virtual environment not found at $VENV_PATH"
    exit 1
fi

# Ensure the Python script exists
if [ ! -f "$PYTHON_SCRIPT" ]; then
    echo "[ERROR] Python script not found at $PYTHON_SCRIPT"
    exit 1
fi

# Activate the virtual environment
source "$VENV_PATH/bin/activate"

# Add the 'src' directory to PYTHONPATH
export PYTHONPATH=$(pwd)/src:$PYTHONPATH

# OpenAI Model Names (modify these as needed)
MODELS=("gemini-2.5-flash-preview-05-20" "o4-mini" "gpt-4.1")

# Dataset path template
DATASET_PATH="cv_splits/cv_split_3/test"

# Loop through each OpenAI model
for MODEL in "${MODELS[@]}"; do
    echo "[INFO] Using model: $MODEL"

    # Run the Python script with model name argument
    python3 "$PYTHON_SCRIPT" \
        --dataset-path "$DATASET_PATH" \
        --model-name "$MODEL"

    echo "[INFO] Finished processing with model: $MODEL."
    echo "------------------------------------------------------"
done

echo "[INFO] All modes executed successfully!"
