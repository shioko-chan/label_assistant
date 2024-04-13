import argparse
import yaml
import os
from pathlib import Path
from data import DataModel
from typing import Optional
import sys
from PySide6.QtCore import QObject, Signal, Slot, QPointF
from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine
from PySide6.QtQuick import QQuickItem


os.environ["QML_XHR_ALLOW_FILE_READ"] = "1"

if __name__ == "__main__":

    parser = argparse.ArgumentParser()

    parser.add_argument("--config", "-c", help="path to config file")
    parser.add_argument("--path", "-p", help="path to images")
    parser.add_argument("--output", "-o", help="path to save labels")
    parser.add_argument("--model", "-m", help="path to model selected")

    args = parser.parse_args()

    config_path = Path(args.config if args.config else "./config/config.yaml")

    if config_path.exists():
        config = yaml.safe_load(config_path.open())
    else:
        config = None

    # commandline first, config file second
    def resolve_path(path: Optional[str], path_name: str) -> Optional[Path]:
        if not path and config and path_name in config:
            path = config[path_name]
        if not path:
            return None
        path = Path(path)

        return path.resolve()

    img_path = resolve_path(args.path, "img_path")
    label_path = resolve_path(args.output, "label_path")
    model_path = resolve_path(args.model, "model_path")
    model_config = resolve_path(None, "model_config")

    if not model_path:
        model_path = Path("./weights/yolov8n_pose_powerrune-armora.pt").resolve()
    if not model_config:
        model_config = Path("./weights/yolov8n_pose_powerrune-armor.yaml").resolve()
    if not label_path:
        label_path = Path("./output").resolve()

    app = QGuiApplication([])
    app.setApplicationDisplayName("Label Assistant - Auto Labeling Tool")
    app.setApplicationName("Label Assistant")
    # app.setWindowIcon(QIcon("./resource/icon.png"))
    engine = QQmlApplicationEngine()

    data_model = DataModel(engine)

    engine.load(Path("./GUI/main.qml").resolve())

    if not engine.rootObjects():
        sys.exit(-1)

    data_model.initialize(
        engine.rootObjects()[0], img_path, label_path, model_path, model_config
    )

    sys.exit(app.exec())
