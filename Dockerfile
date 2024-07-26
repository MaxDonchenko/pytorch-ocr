#FROM python:3.8-slim
# https://docs.nvidia.com/deeplearning/frameworks/pytorch-release-notes/rel_22-01.html#rel_22-01
# This image is very large (14.8GB)
FROM nvcr.io/nvidia/pytorch:23.05-py3

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

RUN rm -rf /workspace/*
WORKDIR /workspace/pytorch-ocr

COPY ./requirements.txt ./


RUN apt-get update
RUN apt-get install ffmpeg libsm6 libxext6  -y

# RUN pip3 install --no-cache-dir --upgrade --pre pip
RUN pip3 install --no-cache-dir -r requirements.txt

COPY . .

# Copy the conversion script
COPY convert_pth_to_onnx.py /workspace/pytorch-ocr/

# Copy the trained model (if exists locally)
COPY docker-artifacts/logs/crnn.pth /workspace/pytorch-ocr/trained_model/crnn.pth

# Create an entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]