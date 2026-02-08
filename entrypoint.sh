#!/bin/bash

# This script is the entrypoint for the Docker container.
# It either runs the training script or converts the model to ONNX format.
# After that it copies the artifacts (from the Docker container)
# to a mounted volume (your machine).

# Set up logging
LOG_FILE="/workspace/pytorch-ocr/conversion.log"
exec > >(tee -a "$LOG_FILE") 2>&1

echo "Starting script at $(date)"

# Check for CUDA availability
python -c "import torch; print(f'CUDA available: {torch.cuda.is_available()}')"

# Run the training (if needed)
python train.py

# Convert the model to ONNX
echo "Starting model conversion at $(date)"
python convert_pth_to_onnx.py
echo "Finished model conversion at $(date)"

# Function to list directory contents with limit
list_directory() {
    local dir=$1
    local limit=${2:-10}
    echo "Listing up to $limit files in $dir:"
    ls -1 "$dir" | head -n "$limit"
    local total=$(ls -1 "$dir" | wc -l)
    if [ $total -gt $limit ]; then
        echo "... and $((total - limit)) more files"
    fi
    echo "Total files in $dir: $total"
    echo
}

# List files in the workspace
echo "Listing files in /workspace/pytorch-ocr:"
list_directory "/workspace/pytorch-ocr"

# List contents of subdirectories
for subdir in /workspace/pytorch-ocr/*/; do
    if [ -d "$subdir" ]; then
        list_directory "$subdir"
    fi
done

# Copy artifacts to a mounted volume
echo "Copying artifacts and logs to mounted volume..."
# known issue - logs are in "outputs" directory
# while artifacts are in "logs" directory
if [ -d "/workspace/pytorch-ocr/logs" ]; then
    cp -rv /workspace/pytorch-ocr/logs /artifacts
else
    echo "No logs directory found."
fi
if [ -d "/workspace/pytorch-ocr/outputs" ]; then
    cp -rv /workspace/pytorch-ocr/outputs /artifacts
else
    echo "No output directory found."
fi

# Copy ONNX file if it exists
if [ -f "/workspace/pytorch-ocr/crnn.onnx" ]; then
    cp -v /workspace/pytorch-ocr/crnn.onnx /artifacts/
else
    echo "ONNX file not found."
fi

# Copy log file
cp -v "$LOG_FILE" /artifacts/

echo "Copying complete at $(date)"

# List files in the artifacts directory
echo "Listing files in /artifacts:"
list_directory "/artifacts"

# Test the inference
echo "Starting inference at $(date)"
INFERENCE_RESULT=$(python /workspace/pytorch-ocr/inference_with_onnx.py /workspace/pytorch-ocr/test-image-2.png)
echo "Finished inference at $(date)"

# Test the result
EXPECTED_RESULT="axkaah"
if [ "$INFERENCE_RESULT" = "$EXPECTED_RESULT" ]; then
    echo "Test PASSED: Inference result matches expected result"
else
    echo "Test FAILED: Inference result does not match expected result"
    echo "Expected: $EXPECTED_RESULT"
    echo "Got: $INFERENCE_RESULT"
    exit 1
fi

# Container will exit now
exit 0