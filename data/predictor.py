from ultralytics import YOLO
from pathlib import Path
from PIL import Image
import numpy as np


# rewrite this class to adapt to your predict model
# construct your predict data in a list
# each element in the list is a dict with keys:
#     'cls': int, class index
#     'bbox': list, bounding box [x, y, w, h] (x, y is the center of the box, x, y, w, h should be normalized)
#     'kpnt': list, keypoints [[x1, y1], [x2, y2], ..., [xn, yn]]

class Predictor:
    def __init__(self, model: Path):
        self.model = YOLO(model)

    def predict(self, path: Path):
        img = Image.open(path)
        result = self.model.predict(img)[0]
        boxes = result.boxes.cpu()
        keypoints = result.keypoints.cpu()
        annotations = []
        for box, keypoint in zip(boxes, keypoints):
            cls, box, kpnt = (
                np.squeeze(box.cls.numpy()),
                np.squeeze(box.xywhn.numpy()),
                np.squeeze(keypoint.xyn.numpy()),
            )
            annotations.append(
                {"cls": int(cls), "bbox": box.tolist(), "kpnt": kpnt.tolist()}
            )
        return annotations
