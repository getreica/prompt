import json

# Carica il file JSON
with open('./workflows/version_01.json') as file:
    data = json.load(file)

# Lista per memorizzare i link dei file da scaricare
files_to_download = []

# Estensioni di file da considerare
valid_extensions = {'.bin', '.safetensors', '.ckpt', '.sft', '.gguf', '.pt', '.pth', '.onnx'}

# Scansiona tutte le voci nel JSON
for key, value in data.items():
    inputs = value.get('inputs', {})
    for item_key, item_value in inputs.items():
        # Se il valore è una stringa e contiene un file con estensione valida
        if isinstance(item_value, str) and any(item_value.endswith(ext) for ext in valid_extensions):
            files_to_download.append(item_value)

# Genera i comandi aria2c
for file_name in files_to_download:
    # Costruzione del comando
    url = f'https://huggingface.co/alexgenovese/{file_name.split("/")[0]}/resolve/main/{file_name.split("/")[-1]}'
    output_path = f'comfyui/models/{file_name.split(".")[1]}/{file_name}'
    print(f'RUN aria2c --header="Authorization: Bearer $HUGGINGFACE_ACCESS_TOKEN" -o {output_path} {url}')
