from typing import Any
from PySide6.QtCore import QAbstractListModel, Qt, QByteArray, QModelIndex, Property
from dataclasses import dataclass, fields


@dataclass
class Keypoint:
    x: int
    y: int
    visible: bool = True


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

    def setData(self, index: QModelIndex, value: Any, role: int = Qt.EditRole) -> bool:
        self.keypointList[index.row()] = value
        return True


@dataclass
class Annotation:
    x: int
    y: int
    w: int
    h: int
    cls_id: int = None
    cls: str = None
    kpnt: KeypointList = None


class History:
    def __init__(self, stage):
        self.hist = []
        self.index = 0
        self.hist.append(stage)

    def add(self, stage):
        self.index += 1
        if self.index < len(self.index):
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
        return f"hist: {str(self.hist)}, idx: {self.index}"


class AnnotationList(QAbstractListModel):
    def __init__(self):
        super().__init__()
        self.annotationList = []
        self.config = None

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
                kpnt.dataChanged.connect(self.onKpntChanged)
            self.annotationList.append(Annotation(*annotation["bbox"], *cls, kpnt))
        self.hist = History(self.annotationList.copy())
        self.endInsertRows()

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
            self._update_state(now_stage.copy())

    def undo(self):
        last_stage = self.hist.undo()
        if last_stage:
            self._update_state(last_stage.copy())

    def redo(self):
        next_stage = self.hist.redo()
        if next_stage:
            self._update_state(next_stage.copy())

    def setData(self, index: QModelIndex, value: Any, role: int = Qt.EditRole) -> bool:
        self.annotationList[index.row()] = value
        self.hist.add(self.annotationList.copy())
        return True

    def onKpntChanged(self, index: QModelIndex):
        self.hist.add(self.annotationList.copy())

    def set_config(self, config):
        self.config = config
