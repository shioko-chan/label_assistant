from PySide6.QtCore import QObject, Signal, Slot, QPointF
from PySide6.QtQml import QmlElement, QmlSingleton
from ultralytics import YOLO
from typing import Optional
from pathlib import Path
from urllib.parse import urlparse
import yaml 

# @QmlSingleton
# @QmlElement
class DataModel:

    def __init__(
        self,
        root: QObject,
        src: Optional[Path],
        dst: Optional[Path],
        model: Optional[Path],
    ):  
        self.root = root
        self.choose_dataset(src)
        self.predictor = Predictor(model) if (model and model.is_file()) else None
        self.save_dir = dst if (dst and dst.is_dir()) else None
        root.nextImage.connect(self.get_image)
        root.chooseDataset.connect(self.choose_dataset)
        root.selectModel.connect(self.set_predictor)
        self.hist_stack = []
        self.config = {
            "img_path": src,
            "label_path": dst,
            "model_path": model
        }

    def get_image(self):
        if self.index >= len(self.images):
            self.root.setProperty("imageSource", "../resource/default.jpg")
            self.root.setProperty("noDataSetTip", True)
        else:
            self.root.setProperty("imageSource", str(self.images[self.index]))
            self.root.setProperty("noDataSetTip", False)
            self.index += 1

    def prev_image(self):
        ...
    
    def next_image(self):
        ...
        
    def choose_dataset(self, src):
        if src:
            if not isinstance(src, Path):
                src = Path(urlparse(src).path).resolve()
            if src.is_dir():
                self.images = list(src.glob("*.jpg"))
            else:
                self.images = []
        else:
            self.images = []

        self.index = 0
        self.get_image()
    
    def set_predictor(self, src):
        if src and src.is_file():
            self.predictor = Predictor(src)
            self.root.setProperty("")
        else:
            self.predictor = None
    # def save_label(self, label):
    #     if self.save_dir:
    #         with open(self.save_dir / f"{self.index}.txt", "w") as f:
    #             f.write(label)
    #     else:
    #         print("No save directory selected")
    def save_config(self):
        with open(Path('../config/config.yaml'), 'w') as f:
            yaml.dump(self.config, f)


class Predictor:

    def __init__(self, model: Path):
        # self.model = YOLO("yolov8n.pt")
        self.model = YOLO(model)

    def predict(img):
        # label_path = os.path.join(
        #     args.output, os.path.basename(img).replace(".jpg", ".txt")
        # )
        # img = cv2.imread(img)
        # results = model.predict(img).numpy().cpu()
        labels = []
        for result in results:
            for x1, y1, x2, y2 in result.xyxy:
                ...
        #         cv2.rectangle(img, (x1, y1), (x2, y2), (0, 255, 0), 2)
        #     # for
        # cv2.imshow("preview", img)
        # cv2.waitKey(0)

        # with open(label_path, "w") as f:
        #     f.writelines(labels)
