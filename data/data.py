from PySide6.QtCore import (
    QAbstractListModel,
    Qt,
    QByteArray,
    QModelIndex,
)
from PySide6.QtQml import QmlElement
from dataclasses import dataclass, fields


@dataclass
class Keypoint:
    x: int
    y: int
    visible: bool = True

    def copy(self):
        return Keypoint(self.x, self.y, self.visible)
    
    def inner_dict(self):
        return {"x": self.x, "y": self.y, "visible": self.visible}


class KeypointList(QAbstractListModel):
    def __init__(self, keypoints: list[Keypoint] = []):
        super().__init__()
        self.keypointList = keypoints

    def data(self, index: QModelIndex, role: int = Qt.DisplayRole):
        if 0 <= index.row() < len(self.keypointList):
            keypoint = self.keypointList[index.row()]
            name = self.roleNames().get(role)
            if name:
                return getattr(keypoint, name.decode())

    def roleNames(self) -> dict[int, QByteArray]:
        d = {}
        for i, field in enumerate(fields(Keypoint)):
            d[Qt.UserRole + i + 1] = field.name.encode()
        return d

    def rowCount(self, _: QModelIndex = QModelIndex()) -> int:
        return len(self.keypointList)

    def setData(self, index: QModelIndex, value, _: int = Qt.EditRole) -> bool:
        self.keypointList[index.row()] = value
        return True

    def set(self, idx, keypoint):
        self.keypointList[idx] = keypoint

    def copy(self):
        return KeypointList([keypoint.copy() for keypoint in self.keypointList])
    
    def inner_dict(self):
        return [keypoint.inner_dict() for keypoint in self.keypointList]


@dataclass
class Annotation:
    x: int
    y: int
    w: int
    h: int
    cls_id: int = None
    cls: str = None
    kpnt: KeypointList = None

    def set_bbox(self, x, y, w, h):
        self.x = x
        self.y = y
        self.w = w
        self.h = h

    def set_cls(self, cls_id, cls):
        self.cls_id = cls_id
        self.cls = cls

    def set_keypoint(self, idx, x, y):
        self.kpnt.set(idx, Keypoint(x, y))

    def copy(self):
        return Annotation(
            self.x, self.y, self.w, self.h, self.cls_id, self.cls, self.kpnt.copy()
        )

    def inner_dict(self):
        return {
            "x": self.x,
            "y": self.y,
            "w": self.w,
            "h": self.h,
            "cls_id": self.cls_id,
            "cls": self.cls,
            "kpnt": self.kpnt.inner_dict(),
        }


class History:
    def __init__(self, stage):
        self.index = 0
        self.hist = [stage]

    def add(self, stage):
        self.index += 1
        if self.index < len(self.hist):
            self.hist[self.index] = stage
            self.hist = self.hist[: self.index + 1]
        else:
            self.hist.append(stage)

    def undo(self):
        if self.index - 1 >= 0:
            self.index -= 1
            return self.hist[self.index]
        return None

    def redo(self):
        if self.index + 1 < len(self.hist):
            self.index += 1
            return self.hist[self.index]
        return None

    def now(self):
        return self.hist[self.index]

    def __str__(self) -> str:
        return f"History: {{hist: {str(self.hist)}, idx: {self.index}}}"


class AnnotationList(QAbstractListModel):
    def __init__(self):
        super().__init__()
        self.annotationList = []
        self.config = None

    def initialize(self, root):
        root.undo.connect(self.undo)
        root.redo.connect(self.redo)
        root.deleteAnnotation.connect(self.remove)
        root.setBbox.connect(self.setBbox)
        root.setKpnt.connect(self.setKpnt)
        root.setLabel.connect(self.setLabel)
        self.root = root

    def data(self, index: QModelIndex, role: int = Qt.DisplayRole):
        if 0 <= index.row() < len(self.annotationList):
            annotation = self.annotationList[index.row()]
            name = self.roleNames().get(role)
            if name:
                return getattr(annotation, name.decode())

    def roleNames(self) -> dict[int, QByteArray]:
        d = {}
        for i, field in enumerate(fields(Annotation)):
            d[Qt.UserRole + i + 1] = field.name.encode()
        return d

    def rowCount(self, _: QModelIndex = QModelIndex()) -> int:
        return len(self.annotationList)

    def set(self, annotations: list[dict]):
        self.beginInsertRows(QModelIndex(), 0, len(annotations) - 1)
        for annotation in annotations:
            cls, kpnt = None, None
            if "cls" in annotation:
                cls = (annotation["cls"], self.config["names"][annotation["cls"]])
            if "kpnt" in annotation:
                kpnt = KeypointList([Keypoint(*kp) for kp in annotation["kpnt"]])
            self.annotationList.append(Annotation(*annotation["bbox"], *cls, kpnt))
        self.endInsertRows()
        self.hist = History(self.copy())

    def clear(self):
        self.beginRemoveRows(QModelIndex(), 0, len(self.annotationList) - 1)
        self.annotationList.clear()
        self.endRemoveRows()
        return self.hist

    def _update_state(self, state: list[Annotation]):
        self.beginRemoveRows(QModelIndex(), 0, len(self.annotationList) - 1)
        self.annotationList = state
        self.endRemoveRows()
        self.beginInsertRows(QModelIndex(), 0, len(self.annotationList) - 1)
        self.endInsertRows()

    def recover(self, history: History):
        self.hist = history
        now_stage = self.hist.now()
        if now_stage:
            self._update_state([annotation.copy() for annotation in now_stage])

    def undo(self):
        last_stage = self.hist.undo()
        if last_stage != None:
            self._update_state([annotation.copy() for annotation in last_stage])

    def redo(self):
        next_stage = self.hist.redo()
        if next_stage != None:
            self._update_state([annotation.copy() for annotation in next_stage])

    def setData(self, index: QModelIndex, value, _: int = Qt.EditRole) -> bool:
        self.annotationList[index.row()] = value
        self.hist.add(self.copy())
        return True

    def set_config(self, config):
        self.config = config

    def remove(self, index):
        if 0 <= index < len(self.annotationList):
            self.beginRemoveRows(QModelIndex(), index, index)
            self.annotationList.pop(index)
            self.endRemoveRows()
            self.hist.add(self.copy())

    def setBbox(self, bbox_index, x, y, w, h):
        self.annotationList[bbox_index].set_bbox(x, y, w, h)
        self.hist.add(self.copy())
        self.root.setProperty("allSaved", False)

    def setLabel(self, bbox_index, cls_id):
        self.annotationList[bbox_index].set_cls(cls_id, self.config["names"][cls_id])
        self.hist.add(self.copy())
        self.root.setProperty("allSaved", False)
        
    def setKpnt(self, bbox_index, kpnt_index, x, y):
        self.annotationList[bbox_index].set_keypoint(kpnt_index, x, y)
        self.hist.add(self.copy())
        self.root.setProperty("allSaved", False)

    def copy(self):
        return [annotation.copy() for annotation in self.annotationList]

    def inner_dict(self):
        return [annotation.inner_dict() for annotation in self.annotationList]
    
    def save(self):
        return self.annotationList
