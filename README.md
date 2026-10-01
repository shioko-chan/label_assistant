# Label Assistant

[English](README.md) | [简体中文](README.zh-CN.md)

A desktop image annotation assistant built with PySide6/QML and YOLOv8. It loads an image directory and a pose estimation model, providing a visual interface for automatic prediction, review, and annotation saving.

## Features

- PySide6 + QML desktop interface
- Load an image directory and browse images one by one
- Generate initial annotations with an Ultralytics YOLOv8 pose model
- Review and adjust annotations in the interface
- Write annotations to a specified output directory
- Support for command-line arguments or a YAML configuration file

## Project structure

```text
label_assistant/
├── start.py           # Application entry point
├── GUI/               # QML interface components
├── data/              # Data models, predictor, and annotation writing logic
├── config/            # Default configuration
├── weights/           # Default model and model configuration
├── requirements.txt
└── start.spec         # PyInstaller configuration
```

## Installation

A separate virtual environment is recommended:

```bash
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

`requirements.txt` currently contains several duplicate dependencies with different versions, including Pillow, PySide6, and PyYAML. If installation conflicts occur, you can first install a consistent set of versions:

```bash
pip install numpy Pillow PySide6 PyYAML ultralytics
```

## Running

The simplest way to start the application:

```bash
python start.py --path ./images --output ./output
```

Specify a model:

```bash
python start.py \
  --path ./images \
  --output ./output \
  --model ./weights/model.pt
```

Available arguments:

```text
-c, --config   Path to a YAML configuration file
-p, --path     Directory of images to annotate
-o, --output   Annotation output directory
-m, --model    Path to a YOLO model
```

When no arguments are specified, the application attempts to read `./config/config.yaml` and uses the repository's default weights and output directory.

## Configuration example

```yaml
img_path: ./images
label_path: ./output
model_path: ./weights/model.pt
model_config: ./weights/model.yaml
```

Command-line arguments take precedence over the configuration file.

## Packaging

The repository includes `start.spec`, which can be used to build the desktop application with PyInstaller:

```bash
pip install pyinstaller
pyinstaller start.spec
```

## Notes

- The default weights are named for a specific pose annotation task. When switching datasets, update the model configuration and annotation format accordingly.
- Automatic predictions should only serve as initial annotations and still require manual review before training.
- QML files are loaded from local paths, so run commands from the repository root.
