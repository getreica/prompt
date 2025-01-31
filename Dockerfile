# Stage 1: Base image with common dependencies
FROM nvidia/cuda:11.8.0-cudnn8-runtime-ubuntu22.04 AS base

# Prevents prompts from packages asking for user input during installation
ENV DEBIAN_FRONTEND=noninteractive
# Prefer binary wheels over source distributions for faster pip installations
ENV PIP_PREFER_BINARY=1
# Ensures output from python is printed immediately to the terminal without buffering
ENV PYTHONUNBUFFERED=1 
# Speed up some cmake builds
ENV CMAKE_BUILD_PARALLEL_LEVEL=8

# Install Python, git and other necessary tools
RUN apt-get update && apt-get install -y \
    python3.10 \
    python3-pip \
    && apt-get install -y --no-install-recommends git git-lfs wget curl zip unzip aria2 ffmpeg libxext6 libxrender1 \
    && apt-get install -y libgl1-mesa-glx libglib2.0-0 git wget libgl1 \
    && ln -sf /usr/bin/python3.10 /usr/bin/python \
    && ln -sf /usr/bin/pip3 /usr/bin/pip

# Clean up to reduce image size
RUN apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/*

# Install comfy-cli
RUN pip install comfy-cli

# Install ComfyUI
RUN /usr/bin/yes | comfy --workspace /comfyui install --cuda-version 11.8 --nvidia --version 0.3.13
# ONLY for local testing
# RUN /usr/bin/yes | comfy --workspace /comfyui install --version 0.3.13 --cpu

# Change working directory to ComfyUI
WORKDIR /comfyui

# Install runpod
RUN pip install runpod requests

# Support for the network volume
ADD src/extra_model_paths.yaml ./

# Go back to the root
WORKDIR /

# Add scripts
ADD src/start.sh src/restore_snapshot.sh src/rp_handler.py test_input.json ./
RUN chmod +x /start.sh /restore_snapshot.sh

# Optionally copy the snapshot file
RUN mkdir -p /snapshots/
ADD snapshots/*snapshot*.json /snapshots/

# Restore the snapshot to install custom nodes
RUN /restore_snapshot.sh

# Start container
CMD ["/start.sh"]

# Stage 2: Download models
FROM base AS downloader

ARG HUGGINGFACE_ACCESS_TOKEN

# Change working directory to ComfyUI
WORKDIR /
#
# Download weights - Da sostituire con i modelli che si vogliono scaricare
#
RUN aria2c --header="Authorization: Bearer $HUGGINGFACE_ACCESS_TOKEN" -o comfyui/models/vae/ae.sft https://huggingface.co/alexgenovese/vae/resolve/main/ae.sft
RUN aria2c --header="Authorization: Bearer $HUGGINGFACE_ACCESS_TOKEN" -o comfyui/models/unet/flux_dev_fp8_scaled_diffusion_model.safetensors https://huggingface.co/comfyanonymous/flux_dev_scaled_fp8_test/resolve/main/flux_dev_fp8_scaled_diffusion_model.safetensors
RUN aria2c --header="Authorization: Bearer $HUGGINGFACE_ACCESS_TOKEN" -o comfyui/models/clip/t5xxl_fp8_e4m3fn_scaled.safetensors https://huggingface.co/comfyanonymous/flux_text_encoders/resolve/main/t5xxl_fp8_e4m3fn_scaled.safetensors
RUN aria2c --header="Authorization: Bearer $HUGGINGFACE_ACCESS_TOKEN" -o comfyui/models/clip/ViT-L-14-TEXT-detail-improved-hiT-GmP-TE-only-HF.safetensors https://huggingface.co/zer0int/CLIP-GmP-ViT-L-14/resolve/main/ViT-L-14-TEXT-detail-improved-hiT-GmP-TE-only-HF.safetensors
RUN aria2c --header="Authorization: Bearer $HUGGINGFACE_ACCESS_TOKEN" -o comfyui/models/controlnet/depth_anything_v2_vitl.pth https://huggingface.co/depth-anything/Depth-Anything-V2-Large/resolve/main/depth_anything_v2_vitl.pth
RUN aria2c --header="Authorization: Bearer $HUGGINGFACE_ACCESS_TOKEN" -o comfyui/models/upscale_models/4x_NMKD-Siax_200k.pth https://huggingface.co/alexgenovese/upscalers/resolve/main/4x_NMKD-Siax_200k.pth

# Stage 3: Final image
FROM base as final

# Copy models from stage 2 to the final image
COPY --from=downloader /comfyui/models /comfyui/models

# Start container
CMD ["/start.sh"]