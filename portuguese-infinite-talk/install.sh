#!/bin/bash
# =============================================================================
# Portuguese InfiniteTalk + LatentSync 1.6 — Full Linux Setup Script
# Run from the root ComfyUI directory: /workspace/ComfyUI
# =============================================================================

# Enable high-performance mode for faster HuggingFace downloads
export HF_XET_HIGH_PERFORMANCE=1
export HF_XET_NUM_CONCURRENT_RANGE_GETS=32

# =============================================================================
# STEP 1: Create all required model directories
# =============================================================================
echo "Creating model directories..."

# WanVideo / InfiniteTalk
mkdir -p models/diffusion_models/WanVideo
mkdir -p models/diffusion_models/WanVideo/InfiniteTalk
mkdir -p models/vae/wanvideo
mkdir -p models/text_encoders
mkdir -p models/clip_vision
mkdir -p models/diffusion_models/MelBandRoformer
mkdir -p models/loras/WanVideo/Lightx2v

# Wav2Vec2 (for MultiTalk / InfiniteTalk audio embeddings)
mkdir -p models/wav2vec2

echo "Directories created."

# =============================================================================
# STEP 2: Install Custom Nodes (Required for code structure)
# =============================================================================
echo "Installing Custom Nodes..."

# 1. ComfyUI-WanVideoWrapper (for InfiniteTalk nodes)
if [ ! -d "custom_nodes/ComfyUI-WanVideoWrapper" ]; then
    git clone https://github.com/kijai/ComfyUI-WanVideoWrapper.git \
        custom_nodes/ComfyUI-WanVideoWrapper
else
    echo "ComfyUI-WanVideoWrapper already cloned, pulling latest..."
    git -C custom_nodes/ComfyUI-WanVideoWrapper pull
fi
pip install -r custom_nodes/ComfyUI-WanVideoWrapper/requirements.txt

# 2. ComfyUI-LatentSyncWrapper
if [ ! -d "custom_nodes/ComfyUI-LatentSyncWrapper" ]; then
    git clone https://github.com/ShmuelRonen/ComfyUI-LatentSyncWrapper.git \
        custom_nodes/ComfyUI-LatentSyncWrapper
else
    echo "ComfyUI-LatentSyncWrapper already cloned, pulling latest..."
    git -C custom_nodes/ComfyUI-LatentSyncWrapper pull
fi

# 3. comfyui-kjnodes (for SetNode, GetNode, INTConstant, etc.)
if [ ! -d "custom_nodes/comfyui-kjnodes" ]; then
    git clone https://github.com/kijai/comfyui-kjnodes.git \
        custom_nodes/comfyui-kjnodes
else
    echo "comfyui-kjnodes already cloned, pulling latest..."
    git -C custom_nodes/comfyui-kjnodes pull
fi
pip install -r custom_nodes/comfyui-kjnodes/requirements.txt

# 4. ComfyUI-MelBandRoFormer (for audio separation)
if [ ! -d "custom_nodes/ComfyUI-MelBandRoFormer" ]; then
    git clone https://github.com/kijai/ComfyUI-MelBandRoFormer.git \
        custom_nodes/ComfyUI-MelBandRoFormer
else
    echo "ComfyUI-MelBandRoFormer already cloned, pulling latest..."
    git -C custom_nodes/ComfyUI-MelBandRoFormer pull
fi
pip install -r custom_nodes/ComfyUI-MelBandRoFormer/requirements.txt

# 5. ComfyUI-VideoHelperSuite (for VHS_VideoCombine)
if [ ! -d "custom_nodes/ComfyUI-VideoHelperSuite" ]; then
    git clone https://github.com/Kosinkadink/ComfyUI-VideoHelperSuite.git \
        custom_nodes/ComfyUI-VideoHelperSuite
else
    echo "ComfyUI-VideoHelperSuite already cloned, pulling latest..."
    git -C custom_nodes/ComfyUI-VideoHelperSuite pull
fi
pip install -r custom_nodes/ComfyUI-VideoHelperSuite/requirements.txt

# Set up checkpoints directory structure inside the node
LATENTSYNC_DIR="custom_nodes/ComfyUI-LatentSyncWrapper/checkpoints"
mkdir -p "$LATENTSYNC_DIR/whisper"
mkdir -p "$LATENTSYNC_DIR/auxiliary"
mkdir -p "$LATENTSYNC_DIR/vae"

echo "Custom nodes installed and directories prepared."

# =============================================================================
# STEP 3: WanVideo / InfiniteTalk models (same as original workflow)
# =============================================================================
echo "Downloading WanVideo / InfiniteTalk models..."

hf download city96/Wan2.1-I2V-14B-480P-gguf wan2.1-i2v-14b-480p-Q8_0.gguf \
    --local-dir models/diffusion_models/WanVideo

hf download Comfy-Org/Wan_2.1_ComfyUI_repackaged \
    split_files/diffusion_models/wan2.1_i2v_480p_14B_fp8_e4m3fn.safetensors \
    --local-dir models/diffusion_models/WanVideo

hf download Comfy-Org/Wan_2.1_ComfyUI_repackaged \
    split_files/diffusion_models/wan2.1_i2v_720p_14B_fp8_e4m3fn.safetensors \
    --local-dir models/diffusion_models/WanVideo

# Flatten WanVideo directory
if [ -d "models/diffusion_models/WanVideo/split_files/diffusion_models" ]; then
    mv models/diffusion_models/WanVideo/split_files/diffusion_models/*.safetensors models/diffusion_models/WanVideo/
    rm -rf models/diffusion_models/WanVideo/split_files
fi

# InfiniteTalk models
hf download Kijai/WanVideo_comfy_GGUF \
    InfiniteTalk/Wan2_1-InfiniteTalk_Single_Q8.gguf \
    --local-dir models/diffusion_models/WanVideo/InfiniteTalk

hf download Kijai/WanVideo_comfy_fp8_scaled \
    InfiniteTalk/Wan2_1-InfiniteTalk-Multi_fp8_e4m3fn_scaled_KJ.safetensors \
    --local-dir models/diffusion_models/WanVideo/InfiniteTalk

# Flatten InfiniteTalk directory
if [ -d "models/diffusion_models/WanVideo/InfiniteTalk/InfiniteTalk" ]; then
    mv models/diffusion_models/WanVideo/InfiniteTalk/InfiniteTalk/* models/diffusion_models/WanVideo/InfiniteTalk/
    rm -rf models/diffusion_models/WanVideo/InfiniteTalk/InfiniteTalk
fi

# VAE
hf download Kijai/WanVideo_comfy Wan2_1_VAE_bf16.safetensors \
    --local-dir models/vae/wanvideo

# Text Encoder
hf download Kijai/WanVideo_comfy umt5-xxl-enc-bf16.safetensors \
    --local-dir models/text_encoders

# Clip Vision
hf download Comfy-Org/Wan_2.1_ComfyUI_repackaged \
    split_files/clip_vision/clip_vision_h.safetensors \
    --local-dir models/clip_vision

# Flatten CLIP Vision directory
if [ -d "models/clip_vision/split_files/clip_vision" ]; then
    mv models/clip_vision/split_files/clip_vision/*.safetensors models/clip_vision/
    rm -rf models/clip_vision/split_files
fi

# Vocal Separator
hf download Kijai/MelBandRoFormer_comfy MelBandRoformer_fp16.safetensors \
    --local-dir models/diffusion_models/MelBandRoformer

# Lightning LoRA
hf download Kijai/WanVideo_comfy \
    Lightx2v/lightx2v_I2V_14B_480p_cfg_step_distill_rank64_bf16.safetensors \
    --local-dir models/loras/WanVideo/Lightx2v

# Flatten LoRA directory
if [ -d "models/loras/WanVideo/Lightx2v/Lightx2v" ]; then
    mv models/loras/WanVideo/Lightx2v/Lightx2v/*.safetensors models/loras/WanVideo/Lightx2v/
    rm -rf models/loras/WanVideo/Lightx2v/Lightx2v
fi

echo "WanVideo models downloaded."

# =============================================================================
# STEP 4: Wav2Vec2 model for MultiTalk / InfiniteTalk
# The workflow uses TencentGameMate/chinese-wav2vec2-base (required by MultiTalk)
# =============================================================================
echo "Downloading Wav2Vec2 model for MultiTalk..."

hf download TencentGameMate/chinese-wav2vec2-base \
    --local-dir models/wav2vec2/TencentGameMate/chinese-wav2vec2-base

echo "Wav2Vec2 model downloaded."

# =============================================================================
# STEP 5: LatentSync 1.6 models
# These go inside the custom node's checkpoints folder, NOT in ComfyUI/models
# =============================================================================
echo "Downloading LatentSync 1.6 models..."

# Main UNet model (~5 GB)
hf download ByteDance/LatentSync-1.6 latentsync_unet.pt \
    --local-dir "$LATENTSYNC_DIR"

# SyncNet model (~1.6 GB) — used for quality evaluation during inference
hf download ByteDance/LatentSync-1.6 stable_syncnet.pt \
    --local-dir "$LATENTSYNC_DIR"

# Config file
hf download ByteDance/LatentSync-1.6 config.json \
    --local-dir "$LATENTSYNC_DIR"

# Whisper tiny model (~75 MB) — used for audio transcription / lip sync
hf download ByteDance/LatentSync-1.6 whisper/tiny.pt \
    --local-dir "$LATENTSYNC_DIR"

# Auxiliary models (face detection, quality metrics, etc.)
hf download ByteDance/LatentSync-1.6 auxiliary/i3d_torchscript.pt \
    --local-dir "$LATENTSYNC_DIR"

hf download ByteDance/LatentSync-1.6 auxiliary/vgg16-397923af.pth \
    --local-dir "$LATENTSYNC_DIR"

hf download ByteDance/LatentSync-1.6 auxiliary/syncnet_v2.model \
    --local-dir "$LATENTSYNC_DIR"

hf download ByteDance/LatentSync-1.6 auxiliary/sfd_face.pth \
    --local-dir "$LATENTSYNC_DIR"

hf download ByteDance/LatentSync-1.6 auxiliary/koniq_pretrained.pkl \
    --local-dir "$LATENTSYNC_DIR"

hf download ByteDance/LatentSync-1.6 auxiliary/vit_g_hybrid_pt_1200e_ssv2_ft.pth \
    --local-dir "$LATENTSYNC_DIR"

# VAE model for LatentSync (stabilityai/sd-vae-ft-mse)
hf download stabilityai/sd-vae-ft-mse diffusion_pytorch_model.safetensors \
    --local-dir "$LATENTSYNC_DIR/vae"

hf download stabilityai/sd-vae-ft-mse config.json \
    --local-dir "$LATENTSYNC_DIR/vae"

echo "LatentSync 1.6 models downloaded."

# =============================================================================
# STEP 6: Final Dependency Check for LatentSync
# =============================================================================
echo "Checking LatentSync dependencies..."

# Fix strict mediapipe version if needed
sed -i 's/mediapipe==0.10.11/mediapipe>=0.10.11/g' custom_nodes/ComfyUI-LatentSyncWrapper/requirements.txt

pip install -r custom_nodes/ComfyUI-LatentSyncWrapper/requirements.txt

echo "Dependencies verified."

# =============================================================================
# STEP 7: Download the workflow JSON into ComfyUI's workflows folder
# =============================================================================
echo "Downloading Portuguese InfiniteTalk workflow..."

mkdir -p user/default/workflows

curl -L -o user/default/workflows/portuguese-infinite-talk.json \
    https://raw.githubusercontent.com/RyanHolanda/comfy-workflows/main/portuguese-infinite-talk/portuguese-infinite-talk.json

echo "Workflow downloaded."

# =============================================================================
# DONE
# =============================================================================
echo ""
echo "============================================================"
echo " Setup complete! Everything is ready."
echo ""
echo " The workflow has been pre-loaded into ComfyUI:"
echo "   user/default/workflows/portuguese-infinite-talk.json"
echo ""
echo " Just start ComfyUI and open the workflow from the menu!"
echo "============================================================"
