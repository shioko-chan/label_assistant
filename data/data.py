from PySide6.QtCore import QObject, Signal, Slot, QPointF
from PySide6.QtQml import QmlElement, QmlSingleton
from ultralytics import YOLO
from typing import Optional
from pathlib import Path
from PIL import Image


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
        self.predictor = Predictor(model) if (model and model.is_file()) else None
        self.images = list(src.glob("*.jpg")) if (src and src.is_dir()) else None
        self.save_dir = dst if (dst and dst.is_dir()) else None
        self.index = 0
        self.root = root

    def get_image(self):
        if self.index >= len(self.images):
            self.root.setProperty("imageSource", "../resource/default.jpg")
        else:
            self.root.setProperty("imageSource", str(self.images[self.index]))


class Predictor:

    def __init__(self, model: Path):
        self.model = YOLO("yolov8n.pt")
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
