# Stage 1: Base image with common dependencies
FROM alexgenovese/base:0.0.1 AS base

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