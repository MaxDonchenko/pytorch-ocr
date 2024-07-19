#!/bin/bash

# Check for CUDA availability
python -c "import torch; print(f'CUDA available: {torch.cuda.is_available()}')"

# Run the training
python train.py

# After training, copy artifacts to a mounted volume
if [ -d "/workspace/pytorch-ocr/outputs" ]; then
    echo "Training complete! Copying artifacts to mounted volume..."
    cp -r /workspace/pytorch-ocr/outputs /artifacts
    cp -r /workspace/pytorch-ocr/logs /artifacts
fi

echo "Copying complete!"
