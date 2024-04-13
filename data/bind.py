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
        self.writer = Writer()
        self.save_dir = None

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
            "img_path": str(src),
            "label_path": str(dst),
            "model_path": str(model),
            "model_config": str(config),
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

    def save_label(self):
        self._save_label(self.annotations.save())
        
    def _save_label(self, stage):
        self.writer.save([annotation.inner_dict() for annotation in stage], self.images[self.index].stem)
        self.root.setProperty("allSaved", True)

    def _update_history(self, hist):
        if self.index < len(self.hist_stack):
            self.hist_stack[self.index] = hist
        else:
            self.hist_stack.append(hist)
                
    def prev_image(self):
        if self.index <= 0:
            return False
        hist = self.annotations.clear()
        self._update_history(hist)
        self._save_label(hist.now())
        self.index -= 1
        self.annotations.recover(self.hist_stack[self.index])
        self.root.setProperty("imageSource", self.images[self.index].as_uri())
        self.root.setProperty("completeCnt", self.index)
        return True

    def _initialize_image_list(self):
        self.images = [image for image in self.images if not self.writer.exists(image.stem)]
        self.root.setProperty("dataSetSize", len(self.images))
        if not self.images:
            self.root.setProperty("noDataSetTip", True)
            self.root.setProperty("nextButtonText", "开始")
        
    def next_image(self):
        if self.index != -1:
            hist = self.annotations.clear()
            self._update_history(hist)
            self._save_label(hist.now())
        else:
            self.root.setProperty("nextButtonText", "下一张")
            self._initialize_image_list()
        
        if self.index + 1 >= len(self.images):
            return False
        
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
                        self.predictor.predict(
                            Path("./resource/default.jpg")
                        )  # preheat
                    except:
                        self.root.setProperty("modelError", True)
                    else:
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
            self.root.setProperty("labelNames", list(self.model_config["names"].values()))
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
            self.writer.set_dst(self.save_dir)
        else:
            self.save_dir = None

    def save_config(self):
        config_dir = Path("./config")
        if not config_dir.exists():
            config_dir.mkdir()

        with open(config_dir / "config.yaml", "w") as f:
            yaml.dump(self.config, f)
