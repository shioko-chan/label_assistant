import cv2
import os
import argparse
import yaml
from ultralytics import YOLO

parser = argparse.ArgumentParser()

parser.add_argument("--config", "-c", help="path to config file")
parser.add_argument("--path", "-p", help="path to images")
parser.add_argument("--output", "-o", help="path to save labels")

args = parser.parse_args()

config_path = args.config if args.config else "./config/config.yaml"

if os.path.exists(config_path):
    config = yaml.safe_load(open(config_path))
else:
    config = None

if args.path:
    imgs_path = args.path
elif config:
    imgs_path = config["img_path"]
else:
    print("Please provide path to images")
    exit(1)
    
if not os.path.exists(imgs_path):
    print(f"provided images path \"{args.path}\" not found")
    exit(1)
        
img_path = os.path.abspath(args.path)

imgs = [os.path.join(img_path, img) for img in os.listdir(img_path)]

model = YOLO(config['model'])

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

