#!/bin/bash

# Check for CUDA availability
python -c "import torch; print(f'CUDA available: {torch.cuda.is_available()}')"

# Run the training (if needed)
python train.py

# Convert the model to ONNX
# python convert_pth_to_onnx.py

# Copy artifacts to a mounted volume
if [ -d "/workspace/pytorch-ocr/outputs" ]; then
    echo "Copying artifacts to mounted volume..."
    cp -r /workspace/pytorch-ocr/outputs /artifacts
    cp -r /workspace/pytorch-ocr/logs /artifacts
    cp /workspace/pytorch-ocr/crnn.onnx /artifacts/
else
    echo "No output directory found."
    echo "LS /workspace:" && ls
fi

echo "Copying complete!"
