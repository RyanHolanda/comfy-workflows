# Portuguese InfiniteTalk + LatentSync 1.6

This workflow generates videos optimized for Portuguese language with lip sync using InfiniteTalk and LatentSync 1.6. This workflow is a modified version of the original workflow from [MDMZ](https://www.youtube.com/watch?v=2yeo3D76a4s).

## Workflow

The json file for the workflow can be found at [portuguese-infinite-talk.json](portuguese-infinite-talk.json). Just import this workflow into your ComfyUI instance.

## Installation

In order to run the workflow, you'll need to install some custom nodes and configurations. The script [install.sh](install.sh) will install all the required custom nodes and configurations.

To run it in your custom comfy instance, just open your terminal and paste the following command:

```bash
cd /path/to/ComfyUI # Optional, if you are not in the ComfyUI directory. You should run this command from the root ComfyUI directory.
curl -O https://raw.githubusercontent.com/RyanHolanda/comfy-workflows/main/portuguese-infinite-talk/install.sh
chmod +x install.sh
bash install.sh
```

## Usage

Once the workflow is installed, just load the `portuguese-infinite-talk.json` in your ComfyUI instance. The script already copies the workflow to the designated repository that comfyUI reads from. So you can just load it from the UI.
