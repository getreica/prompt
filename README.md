# Serverless Runpod Template 

## How to
1. Creare nuovo comfy 
2. Caricare workflow 
3. Installare tutti i nodi e testarlo 
4. Creare snapshot 
5. Lanciare script per generare il codice di download dei modelli (possibilmente tutti sul mio account HF)

## Next step
- Duplicare questo repository 
- Inserire lo snapshot nella cartella 
- Copiare il codice per scaricare tutti i modelli nel Dockerfile
- Testare 

## Google Cloud Build
1. Creare repository su Docker Hub
2. Collegare il repository per il deploy
3. Setup con il tag per il deploy  
4. Modificare il cloudbuild.yaml con le informazioni corrette e aggiornare
5. Taggare per lanciare il build e il push 
6. Testare su Runpod

# General Overview 

---- STEP 1 --- 
Elencare tutti i workflow da caricare 

---- STEP 2 ---- 
Creare i comfy locali
installre 
testare 

----- STEP 3 ----- 
Snapshot 
Script per download models

---- STEP 4 ----- 
Creare Github repo da template 

---- STEP 5 ----- 
Testare il docker in locale 
Collegare il build e il push su GCP 

---- STEP 6 ----- 
Publish on runpod + testing 


# Credits
> [ComfyUI](https://github.com/comfyanonymous/ComfyUI) as a serverless API on [RunPod](https://www.runpod.io/)
> [Blibla](https://github.com/blib-la/runpod-worker-comfy)
