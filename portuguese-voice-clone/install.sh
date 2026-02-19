#!/bin/bash
# Voice Clone — Portuguese (BR) Setup Script
# Run from the root ComfyUI directory: /workspace/ComfyUI

set -e

export HF_XET_HIGH_PERFORMANCE=1
export HF_XET_NUM_CONCURRENT_RANGE_GETS=32

echo "📦 Installing custom nodes..."

if [ ! -d "custom_nodes/VibeVoice-ComfyUI" ]; then
    git clone https://github.com/Enemyx-net/VibeVoice-ComfyUI.git custom_nodes/VibeVoice-ComfyUI
else
    git -C custom_nodes/VibeVoice-ComfyUI pull
fi
pip install -q -r custom_nodes/VibeVoice-ComfyUI/requirements.txt

if [ ! -d "custom_nodes/ComfyUI_MusicTools" ]; then
    git clone https://github.com/jeankassio/ComfyUI_MusicTools.git custom_nodes/ComfyUI_MusicTools
else
    git -C custom_nodes/ComfyUI_MusicTools pull
fi
pip install -q -r custom_nodes/ComfyUI_MusicTools/requirements.txt

if [ ! -d "custom_nodes/ComfyUI-Audio_Quality_Enhancer" ]; then
    git clone https://github.com/ShmuelRonen/ComfyUI-Audio_Quality_Enhancer.git custom_nodes/ComfyUI-Audio_Quality_Enhancer
else
    git -C custom_nodes/ComfyUI-Audio_Quality_Enhancer pull
fi
pip install -q -r custom_nodes/ComfyUI-Audio_Quality_Enhancer/requirements.txt

echo "✅ Custom nodes installed."

echo "🔧 Installing SoX..."
if ! command -v sox &> /dev/null; then
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        apt-get update -qq && apt-get install -y -qq sox libsox-fmt-all
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        brew install sox
    fi
fi
echo "✅ SoX ready."

echo "📥 Downloading VibeVoice-Large..."
mkdir -p models/vibevoice/VibeVoice-Large models/vibevoice/tokenizer

hf download aoi-ot/VibeVoice-Large \
    --local-dir models/vibevoice/VibeVoice-Large \
    --repo-type model

hf download Qwen/Qwen2.5-1.5B \
    --local-dir models/vibevoice/tokenizer \
    --include "tokenizer.json" "tokenizer_config.json" "vocab.json" "merges.txt"

echo "✅ Models downloaded."

echo "📂 Downloading workflow..."
mkdir -p user/default/workflows
curl -L -o user/default/workflows/voice-clone-portuguese.json \
    https://raw.githubusercontent.com/RyanHolanda/comfy-workflows/refs/heads/main/portuguese-voice-clone/portuguese-voice-clone.json
echo "✅ Workflow ready."
