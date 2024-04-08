import yaml
from typing import Optional
from pathlib import Path
from PySide6.QtCore import (
    QObject,
    QUrl,
)
from data.data import AnnotationList
from data.predictor import Predictor
from data.writer import Writer


class DataModel:

    def __init__(self, engine: QObject):
        self.annotations = AnnotationList()
        engine.rootContext().setContextProperty("annotationList", self.annotations)
        self.hist_stack = []

    def initialize(
        self,
        root: QObject,
        src: Optional[Path],
        dst: Optional[Path],
        model: Optional[Path],
        config: Optional[Path],
    ):
        self.annotations.initialize(root)
        self.root = root
        self.config = {
            "img_path": src,
            "label_path": dst,
            "model_path": model,
            "model_config": config,
        }
        self.choose_dataset(src)
        self.set_predictor(model)
        self.set_predictor(config)
        self.set_saving_dir(dst)
        root.nextImage.connect(self.next_image)
        root.prevImage.connect(self.prev_image)
        root.chooseDataset.connect(self.choose_dataset)
        root.selectModel.connect(self.set_predictor)
        root.selectModelConfig.connect(self.set_predictor)
        root.saveConfig.connect(self.save_config)
        root.selectSavingDir.connect(self.set_saving_dir)
        root.saveLabels.connect(self.save_label)

    def save_label(self): ...

    def _update_history(self, hist):
        if self.index < len(self.hist_stack):
            self.hist_stack[self.index] = hist
        else:
            self.hist_stack.append(hist)
                
    def prev_image(self):
        if self.index <= 0:
            return False
        self._update_history(self.annotations.clear())
        self.index -= 1
        self.annotations.recover(self.hist_stack[self.index])
        self.root.setProperty("imageSource", self.images[self.index].as_uri())
        self.root.setProperty("completeCnt", self.index)
        return True

    def next_image(self):
        if self.index + 1 >= len(self.images):
            return False
        if self.index != -1:
            self._update_history(self.annotations.clear())
        else:
            self.root.setProperty("nextButtonText", "下一张")
        self.index += 1
        if self.index < len(self.hist_stack):
            self.annotations.recover(self.hist_stack[self.index])
        else:
            self.annotations.set(self.predictor.predict(self.images[self.index]))
        self.root.setProperty("imageSource", self.images[self.index].as_uri())
        self.root.setProperty("completeCnt", self.index)
        return True

    def choose_dataset(self, src):
        if src:
            if not isinstance(src, Path):
                src = Path(QUrl(src).toLocalFile())
            src = src.resolve()
            if src.is_dir():
                self.images = list(src.glob("*.jpg"))
            else:
                self.images = []
        else:
            self.images = []

        if len(self.images) != 0:
            self.config["img_path"] = str(src)
            self.root.setProperty("noDataSetTip", False)
            self.root.setProperty("dataSetSize", len(self.images))
            self.index = -1

    def set_predictor(self, src):
        if src:
            if not isinstance(src, Path):
                src = Path(QUrl(src).toLocalFile())
            src = src.resolve()
            if src.is_file():
                if src.suffix == ".pt":
                    try:
                        self.predictor = Predictor(src)
                    except:
                        self.root.setProperty("modelError", True)
                    else:
                        self.predictor.predict(
                            Path("./resource/default.jpg")
                        )  # preheat
                        self.root.setProperty("noModelTip", False)
                        self.config["model_path"] = str(src)
                elif src.suffix == ".yaml":
                    if self._set_model_config(src):
                        self.root.setProperty("noModelConfigTip", False)
                        self.config["model_config"] = str(src)

    def _set_model_config(self, src: Path):
        self.model_config = yaml.safe_load(src.open())
        self.annotations.set_config(self.model_config)
        if "names" in self.model_config:
            return True
        else:
            self.model_config = None
            return False

    def set_saving_dir(self, dst):
        if dst:
            if not isinstance(dst, Path):
                dst = Path(QUrl(dst).toLocalFile())
            dst = dst.resolve()
            if not dst.exists():
                dst.mkdir(parents=True)
            elif not dst.is_dir():
                dst = dst.parent
            self.save_dir = dst
            self.config["label_path"] = str(dst)
            self.root.setProperty("noSavingDirTip", False)
        else:
            self.save_dir = None

    def save_config(self):
        config_dir = Path("./config")
        if not config_dir.exists():
            config_dir.mkdir()

        with open(config_dir / "config.yaml", "w") as f:
            yaml.dump(self.config, f)
