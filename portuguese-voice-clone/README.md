# Portuguese Voice Clone

This workflow is a voice clone workflow for Portuguese language. It uses VibeVoice custom node to clone a voice with high quality

## Workflow

The json file for the workflow can be found at [portuguese-voice-clone.json](./portuguese-voice-clone.json). Just import this workflow into your ComfyUI instance.

## Installation

In order to run the workflow, you'll need to install some custom nodes and configurations. The script [install.sh](install.sh) will install all the required custom nodes and configurations.

To run it in your custom comfy instance, just open your terminal and paste the following command:

```bash
cd /path/to/ComfyUI # Optional, if you are not in the ComfyUI directory. You should run this command from the root ComfyUI directory.
curl -sSL https://raw.githubusercontent.com/RyanHolanda/comfy-workflows/main/portuguese-voice-clone/install.sh | bash
```

## Usage

Once the workflow is installed, just load the `portuguese-voice-clone.json` in your ComfyUI instance. The script already copies the workflow to the designated repository that comfyUI reads from. So you can just load it from the UI.
