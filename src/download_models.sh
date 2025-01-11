#!/bin/bash

# exit script if any command fails (non-zero value)
set -e

echo "Startup..."

# Cancellazione dei modelli
if [[ $DELETE_MODELS ]]; then
    echo "Eliminazione dei modelli..."
    rm -rf comfyui/models
    mkdir -p comfyui/models
    rm -f /all-models-downloaded.check
    echo "Eliminazione completata!"
fi

#
# Download weights - Da sostituire con i modelli che si vogliono scaricare
#
if [[ $DOWNLOAD_MODELS ]]; then
    if [ ! -f "/all-models-downloaded.check" ]; then
        echo "Download dei modelli..."
        # Scarica i modelli
        if [ ! -f "comfyui/models/sft/ae.sft" ]; then
            aria2c --header="Authorization: Bearer $HUGGINGFACE_ACCESS_TOKEN" -o comfyui/models/sft/ae.sft https://huggingface.co/alexgenovese/vae/resolve/main/ae.sft
        fi
        if [ ! -f "comfyui/models/gguf/flux1-dev-F16.gguf" ]; then
            aria2c --header="Authorization: Bearer $HUGGINGFACE_ACCESS_TOKEN" -o comfyui/models/gguf/flux1-dev-F16.gguf https://huggingface.co/city96/FLUX.1-dev-gguf/resolve/main/flux1-dev-F16.gguf
        fi
        if [ ! -f "comfyui/models/gguf/t5-v1_1-xxl-encoder-f16.gguf" ]; then
            aria2c --header="Authorization: Bearer $HUGGINGFACE_ACCESS_TOKEN" -o comfyui/models/gguf/t5-v1_1-xxl-encoder-f16.gguf https://huggingface.co/city96/t5-v1_1-xxl-encoder-gguf/resolve/main/t5-v1_1-xxl-encoder-f16.gguf
        fi
        if [ ! -f "comfyui/models/safetensors/ViT-L-14-TEXT-detail-improved-hiT-GmP-TE-only-HF.safetensors" ]; then
            aria2c --header="Authorization: Bearer $HUGGINGFACE_ACCESS_TOKEN" -o comfyui/models/safetensors/ViT-L-14-TEXT-detail-improved-hiT-GmP-TE-only-HF.safetensors https://huggingface.co/zer0int/CLIP-GmP-ViT-L-14/resolve/main/ViT-L-14-TEXT-detail-improved-hiT-GmP-TE-only-HF.safetensors
        fi

        # Crea il file di check
        touch /all-models-downloaded.check
        echo "Download completato!"
    else
        echo "I modelli sono già stati scaricati perchè c'è il lock file."
    fi
fi
    
echo "End startup."    

if [[ $KEEP_OPEN ]]; then
    echo "Il container è stato avviato con l'opzione --keep-open"

    sleep infinity
else
    echo "Il container è stato avviato senza l'opzione --keep-open."
fi

# Avvia il comando principale del container
# will redirect input variables to the command
exec "$@"