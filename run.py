import cv2
import os
import argparse
from ultralytics import YOLO

parser = argparse.ArgumentParser()

parser.add_argument("--path", "-p", help="path to images")
parser.add_argument("--output", "-o", help="path to save labels")

args = parser.parse_args()

imgpath = os.path.abspath(args.path)
imgs = [os.path.join(imgpath, img) for img in os.listdir(imgpath)]

model = YOLO("pt")

for img in imgs:
    label_path = os.path.join(
        args.output, os.path.basename(img).replace(".jpg", ".txt")
    )
    img = cv2.imread(img)
    results = model.predict(img).numpy().cpu()
    labels = []
    for result in results:
        for x1, y1, x2, y2 in result.xyxy:
            cv2.rectangle(img, (x1, y1), (x2, y2), (0, 255, 0), 2)
        # for
    cv2.imshow("preview", img)
    cv2.waitKey(0)
    with open(label_path, "w") as f:
        f.writelines(labels)
