#!/bin/bash

# exit script if any command fails (non-zero value)
set -e

# Scarica i modelli solo se non presenti, usa variabile d'ambiente per il token
echo "Verifica e download dei modelli se necessario..."

# Esempio di download in diverse cartelle
if [ ! -f "/all-models-downloaded.check" ]; then
    echo "Download dei modelli..."
    #
    # Download weights - Da sostituire con i modelli che si vogliono scaricare
    #
    aria2c --header="Authorization: Bearer $HUGGINGFACE_ACCESS_TOKEN" -o comfyui/models/sft/ae.sft https://huggingface.co/alexgenovese/vae/resolve/main/ae.sft
    aria2c --header="Authorization: Bearer $HUGGINGFACE_ACCESS_TOKEN" -o comfyui/models/gguf/flux1-dev-F16.gguf https://huggingface.co/city96/FLUX.1-dev-gguf/resolve/main/flux1-dev-F16.gguf
    aria2c --header="Authorization: Bearer $HUGGINGFACE_ACCESS_TOKEN" -o comfyui/models/gguf/t5-v1_1-xxl-encoder-f16.gguf https://huggingface.co/city96/t5-v1_1-xxl-encoder-gguf/resolve/main/t5-v1_1-xxl-encoder-f16.gguf
    aria2c --header="Authorization: Bearer $HUGGINGFACE_ACCESS_TOKEN" -o comfyui/models/safetensors/ViT-L-14-TEXT-detail-improved-hiT-GmP-TE-only-HF.safetensors https://huggingface.co/zer0int/CLIP-GmP-ViT-L-14/resolve/main/ViT-L-14-TEXT-detail-improved-hiT-GmP-TE-only-HF.safetensors
    
    # Crea il file di check
    touch /all-models-downloaded.check
    echo "Download completato!"

else 
    echo "Modelli già presenti, non è necessario scaricarli."
fi

# Avvia il comando principale del container
# will redirect input variables to the command
exec "$@"