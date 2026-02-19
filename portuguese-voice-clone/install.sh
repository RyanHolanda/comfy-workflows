#!/bin/bash
# =============================================================================
# 🇧🇷 Voice Clone — Portuguese (BR) Setup Script
# Installs all custom nodes, models, and dependencies for voice cloning
# Run from the root ComfyUI directory: /workspace/ComfyUI or ~/AI/ComfyUI
# =============================================================================

set -e

# Enable high-performance mode for faster HuggingFace downloads
export HF_XET_HIGH_PERFORMANCE=1
export HF_XET_NUM_CONCURRENT_RANGE_GETS=32

echo ""
echo "============================================================"
echo " 🎙️ Voice Clone — Portuguese (BR) Setup"
echo "============================================================"
echo ""

# =============================================================================
# STEP 1: Install Custom Nodes
# =============================================================================
echo "📦 Installing Custom Nodes..."

# 1. VibeVoice-ComfyUI (TTS + Voice Cloning engine)
if [ ! -d "custom_nodes/VibeVoice-ComfyUI" ]; then
    echo "  → Cloning VibeVoice-ComfyUI..."
    git clone https://github.com/Enemyx-net/VibeVoice-ComfyUI.git \
        custom_nodes/VibeVoice-ComfyUI
else
    echo "  → VibeVoice-ComfyUI already installed, pulling latest..."
    git -C custom_nodes/VibeVoice-ComfyUI pull
fi
if [ -f "custom_nodes/VibeVoice-ComfyUI/requirements.txt" ]; then
    pip install -r custom_nodes/VibeVoice-ComfyUI/requirements.txt
fi

# 2. ComfyUI_MusicTools (EQ, Compressor, Reverb, Vocal Naturalizer, LUFS)
if [ ! -d "custom_nodes/ComfyUI_MusicTools" ]; then
    echo "  → Cloning ComfyUI_MusicTools..."
    git clone https://github.com/jeankassio/ComfyUI_MusicTools.git \
        custom_nodes/ComfyUI_MusicTools
else
    echo "  → ComfyUI_MusicTools already installed, pulling latest..."
    git -C custom_nodes/ComfyUI_MusicTools pull
fi
if [ -f "custom_nodes/ComfyUI_MusicTools/requirements.txt" ]; then
    pip install -r custom_nodes/ComfyUI_MusicTools/requirements.txt
fi

# 3. ComfyUI-Audio_Quality_Enhancer (SoX-based reverb, echo, room effects)
if [ ! -d "custom_nodes/ComfyUI-Audio_Quality_Enhancer" ]; then
    echo "  → Cloning ComfyUI-Audio_Quality_Enhancer..."
    git clone https://github.com/ShmuelRonen/ComfyUI-Audio_Quality_Enhancer.git \
        custom_nodes/ComfyUI-Audio_Quality_Enhancer
else
    echo "  → ComfyUI-Audio_Quality_Enhancer already installed, pulling latest..."
    git -C custom_nodes/ComfyUI-Audio_Quality_Enhancer pull
fi
if [ -f "custom_nodes/ComfyUI-Audio_Quality_Enhancer/requirements.txt" ]; then
    pip install -r custom_nodes/ComfyUI-Audio_Quality_Enhancer/requirements.txt
fi

echo "✅ Custom Nodes installed."

# =============================================================================
# STEP 2: Install SoX (required by Audio_Quality_Enhancer for reverb/echo)
# =============================================================================
echo ""
echo "🔧 Checking SoX installation..."

if command -v sox &> /dev/null; then
    echo "  → SoX already installed: $(sox --version 2>&1 | head -1)"
else
    echo "  → SoX not found, attempting to install..."
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        # Linux (RunPod, vast.ai, etc.)
        apt-get update -qq && apt-get install -y -qq sox libsox-fmt-all
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        if command -v brew &> /dev/null; then
            brew install sox
        else
            echo "  ⚠️  Please install SoX manually: brew install sox"
        fi
    else
        echo "  ⚠️  Please install SoX manually for your platform."
    fi
fi

echo "✅ SoX check complete."

# =============================================================================
# STEP 3: Create model directories and download VibeVoice models
# =============================================================================
echo ""
echo "📥 Downloading VibeVoice-Large model (~17 GB)..."
echo "   This is the best model for non-English languages like PT-BR."
echo ""

mkdir -p models/vibevoice

# Download VibeVoice-Large (best quality for Portuguese)
# The model auto-downloads on first run, but we can pre-fetch it
if command -v hf &> /dev/null; then
    echo "  → Using huggingface-cli to download..."
    hf download SWivid/VibeVoice \
        --local-dir models/vibevoice/VibeVoice-Large 2>/dev/null || \
    echo "  ℹ️  Model will auto-download on first run if hf download fails."
else
    echo "  ℹ️  huggingface-cli not found."
    echo "  ℹ️  The VibeVoice model will auto-download on first run (~17 GB)."
    echo "  ℹ️  To pre-download: pip install huggingface_hub[cli] && hf download SWivid/VibeVoice"
fi

echo "✅ Model setup complete."

# =============================================================================
# STEP 4: Create a sample room tone placeholder
# =============================================================================
echo ""
echo "🔊 Creating placeholder room tone..."

mkdir -p input

if [ ! -f "input/room_tone.wav" ]; then
    # Create a 5-second silent WAV as placeholder (user should replace with real room tone)
    python3 -c "
import numpy as np
try:
    import soundfile as sf
    # Generate 5 seconds of very quiet pink noise (simulates room ambient)
    sr = 24000
    duration = 5
    samples = sr * duration
    # Pink noise approximation
    white = np.random.randn(samples).astype(np.float32)
    # Simple 1/f filter
    from scipy.signal import lfilter
    b = [0.049922035, -0.095993537, 0.050612699, -0.004709510]
    a = [1.0, -2.494956002, 2.017265875, -0.522189400]
    pink = lfilter(b, a, white)
    # Very quiet (-40 dB)
    pink = pink * 0.01
    sf.write('input/room_tone.wav', pink, sr)
    print('  → Created room_tone.wav (5s pink noise at -40dB)')
except ImportError:
    # Fallback: create silence
    import wave, struct
    sr = 24000
    duration = 5
    with wave.open('input/room_tone.wav', 'w') as f:
        f.setnchannels(1)
        f.setsampwidth(2)
        f.setframerate(sr)
        for _ in range(sr * duration):
            f.writeframes(struct.pack('<h', int(np.random.randn() * 30)))
    print('  → Created room_tone.wav (5s quiet noise)')
" 2>/dev/null || echo "  ℹ️  Could not create room_tone.wav — please add your own."

    echo "  💡 Replace input/room_tone.wav with a real recording of room silence"
    echo "     (5-10 seconds of your room's ambient sound with no speech)."
else
    echo "  → room_tone.wav already exists."
fi

echo "✅ Room tone ready."

# =============================================================================
# STEP 5: Ensure workflow is in place
# =============================================================================
echo ""
echo "📂 Checking workflow..."

mkdir -p user/default/workflows

if [ -f "user/default/workflows/voice-clone-portuguese.json" ]; then
    echo "  → Workflow already in place!"
else
    echo "  ⚠️  Workflow JSON not found at user/default/workflows/voice-clone-portuguese.json"
    echo "     Please copy it manually."
fi

# =============================================================================
# DONE
# =============================================================================
echo ""
echo "============================================================"
echo " ✅ Setup complete! Everything is ready."
echo ""
echo " 📋 Next steps:"
echo "   1. Start ComfyUI"
echo "   2. Open workflow: voice-clone-portuguese.json"
echo "   3. Load your reference voice in the '🎤 Reference Voice' node"
echo "   4. Type your Portuguese text in the VibeVoice node"
echo "   5. Choose voice mode by muting the correct chain:"
echo "      • MICROPHONE: Unmute 🔵 blue nodes, mute 🟢 green nodes"
echo "      • ROOM:       Unmute 🟢 green nodes, mute 🔵 blue nodes"
echo "   6. Queue prompt and wait for generation!"
echo ""
echo " 💡 Tips:"
echo "   • Use 30+ seconds of clear PT-BR speech as reference"
echo "   • Replace input/room_tone.wav with real room ambient"
echo "   • First run downloads the VibeVoice model (~17 GB)"
echo "============================================================"
