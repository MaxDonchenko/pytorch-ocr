#!/bin/bash

# Check for CUDA availability
python -c "import torch; print(f'CUDA available: {torch.cuda.is_available()}')"

# If you want to run the training automatically
python train.py

# Or, to get an interactive shell
exec "$@"