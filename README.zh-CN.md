# Label Assistant

[English](README.md) | [简体中文](README.zh-CN.md)


一个基于 PySide6/QML 与 YOLOv8 的桌面图像标注辅助工具。程序加载图片目录和姿态估计模型，提供可视化界面进行自动预测、检查与保存标注。

## 功能概览

- PySide6 + QML 桌面界面
- 加载图片目录并逐张浏览
- 使用 Ultralytics YOLOv8 姿态模型生成初始标注
- 在界面中检查和调整标注
- 将标注结果写入指定输出目录
- 支持命令行参数或 YAML 配置文件

## 项目结构

```text
label_assistant/
├── start.py           # 程序入口
├── GUI/               # QML 界面组件
├── data/              # 数据模型、预测器与标注写入逻辑
├── config/            # 默认配置
├── weights/           # 默认模型及模型配置
├── requirements.txt
└── start.spec         # PyInstaller 配置
```

## 安装

建议使用独立虚拟环境：

```bash
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

`requirements.txt` 当前包含若干重复且版本不同的依赖项，例如 Pillow、PySide6 和 PyYAML。若安装时发生冲突，可先安装一组一致版本：

```bash
pip install numpy Pillow PySide6 PyYAML ultralytics
```

## 运行

最简单的启动方式：

```bash
python start.py --path ./images --output ./output
```

指定模型：

```bash
python start.py \
  --path ./images \
  --output ./output \
  --model ./weights/model.pt
```

可用参数：

```text
-c, --config   YAML 配置文件路径
-p, --path     待标注图片目录
-o, --output   标注输出目录
-m, --model    YOLO 模型路径
```

未指定参数时，程序会尝试读取 `./config/config.yaml`，并使用仓库中的默认权重和输出目录。

## 配置示例

```yaml
img_path: ./images
label_path: ./output
model_path: ./weights/model.pt
model_config: ./weights/model.yaml
```

命令行参数的优先级高于配置文件。

## 打包

仓库包含 `start.spec`，可使用 PyInstaller 构建桌面程序：

```bash
pip install pyinstaller
pyinstaller start.spec
```

## 注意事项

- 默认权重名称面向特定姿态标注任务，换用其他数据集时需要同步调整模型配置和标注格式。
- 自动预测只应作为初始标注，训练前仍需人工检查。
- QML 文件通过本地路径加载，运行命令应在仓库根目录执行。
