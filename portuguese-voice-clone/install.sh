#!/bin/bash
# =============================================================================
# Voice Clone — Portuguese (BR) Setup Script
# Run from the root ComfyUI directory: /workspace/ComfyUI
# =============================================================================

export HF_XET_HIGH_PERFORMANCE=1
export HF_XET_NUM_CONCURRENT_RANGE_GETS=32

# =============================================================================
# STEP 1: Install Custom Nodes
# =============================================================================
echo "Installing Custom Nodes..."

# 1. VibeVoice-ComfyUI (TTS + Voice Cloning engine)
if [ ! -d "custom_nodes/VibeVoice-ComfyUI" ]; then
    git clone https://github.com/Enemyx-net/VibeVoice-ComfyUI.git \
        custom_nodes/VibeVoice-ComfyUI
else
    echo "VibeVoice-ComfyUI already cloned, pulling latest..."
    git -C custom_nodes/VibeVoice-ComfyUI pull
fi
pip install -r custom_nodes/VibeVoice-ComfyUI/requirements.txt

# 2. ComfyUI_MusicTools (EQ, Compressor, Reverb, Vocal Naturalizer, LUFS)
if [ ! -d "custom_nodes/ComfyUI_MusicTools" ]; then
    git clone https://github.com/jeankassio/ComfyUI_MusicTools.git \
        custom_nodes/ComfyUI_MusicTools
else
    echo "ComfyUI_MusicTools already cloned, pulling latest..."
    git -C custom_nodes/ComfyUI_MusicTools pull
fi
pip install -r custom_nodes/ComfyUI_MusicTools/requirements.txt

# 3. ComfyUI-Audio_Quality_Enhancer (SoX-based reverb, echo, room effects)
if [ ! -d "custom_nodes/ComfyUI-Audio_Quality_Enhancer" ]; then
    git clone https://github.com/ShmuelRonen/ComfyUI-Audio_Quality_Enhancer.git \
        custom_nodes/ComfyUI-Audio_Quality_Enhancer
else
    echo "ComfyUI-Audio_Quality_Enhancer already cloned, pulling latest..."
    git -C custom_nodes/ComfyUI-Audio_Quality_Enhancer pull
fi
pip install -r custom_nodes/ComfyUI-Audio_Quality_Enhancer/requirements.txt

echo "Custom Nodes installed."

# =============================================================================
# STEP 2: Install SoX (required by Audio_Quality_Enhancer for reverb/echo)
# =============================================================================
echo "Installing SoX..."

if command -v sox &> /dev/null; then
    echo "SoX already installed: $(sox --version 2>&1 | head -1)"
else
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        apt-get update -qq && apt-get install -y -qq sox libsox-fmt-all
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        brew install sox
    fi
    echo "SoX installed."
fi

# =============================================================================
# STEP 3: Download VibeVoice-Large + Qwen tokenizer
# =============================================================================
echo "Downloading VibeVoice-Large..."
mkdir -p models/vibevoice/VibeVoice-Large models/vibevoice/tokenizer

hf download aoi-ot/VibeVoice-Large \
    --local-dir models/vibevoice/VibeVoice-Large \
    --repo-type model
echo "VibeVoice-Large downloaded."

echo "Downloading Qwen2.5-1.5B tokenizer..."
hf download Qwen/Qwen2.5-1.5B \
    --local-dir models/vibevoice/tokenizer \
    --include "tokenizer.json" "tokenizer_config.json" "vocab.json" "merges.txt"
echo "Qwen tokenizer downloaded."

# =============================================================================
# STEP 4: Download workflow
# =============================================================================
echo "Downloading workflow..."
mkdir -p user/default/workflows
curl -L -o user/default/workflows/portuguese-voice-clone.json \
    https://raw.githubusercontent.com/RyanHolanda/comfy-workflows/refs/heads/main/portuguese-voice-clone/portuguese-voice-clone.json
echo "Workflow downloaded."

echo ""
echo "Setup complete. Restart ComfyUI and open portuguese-voice-clone.json."
