from typing import Any
from PySide6.QtCore import (
    QAbstractListModel,
    QPersistentModelIndex,
    Qt,
    QByteArray,
    QModelIndex,
)
from dataclasses import dataclass, fields


@dataclass
class Keypoint:
    x: int
    y: int
    visible: bool = None


class KeypointList(QAbstractListModel):
    def __init__(self, keypoints: list[Keypoint] = []):
        super().__init__()
        self.keypoints = keypoints

    def rowCount(self, _):
        return len(self.keypoints)

    def data(self, index: QModelIndex, role: int = Qt.DisplayRole):
        if 0 <= index.row() < self.rowCount():
            keypoint = self.keypoints[index.row()]
            name = self.roleNames().get(role)
            if name:
                return getattr(keypoint, name.decode())

    def roleNames(self) -> dict[int, QByteArray]:
        d = {}
        for i, field in enumerate(fields(Keypoint)):
            d[Qt.UserRole + i + 1] = field.name.encode()
        return d

    def rowCount(self, index: QModelIndex = QModelIndex()) -> int:
        return len(self.keypoints)


@dataclass
class Annotation:
    x: int
    y: int
    w: int
    h: int
    cls: str = None
    kpnt: KeypointList = None


class History:
    hist: list[list[Annotation]] = []
    index: int = 0

    def __init__(self, stage):
        self.hist.append(stage)

    def add(self, stage):
        self.hist.append(stage)
        self.index += 1

    def undo(self):
        if self.index:
            self.index -= 1
            return self.hist[self.index]
        return None

    def redo(self):
        if self.index < len(self.hist) - 1:
            self.index += 1
            return self.hist[self.index]
        return None


class AnnotationList(QAbstractListModel):
    def __init__(self, config):
        super().__init__()
        self.annotationList = []
        self.config = config

    def rowCount(self, _):
        return len(self.annotation)

    def data(self, index: QModelIndex, role: int = Qt.DisplayRole):
        if 0 <= index.row() < self.rowCount():
            annotation = self.annotationList[index.row()]
            name = self.roleNames().get(role)
            if name:
                return getattr(annotation, name.decode())

    def roleNames(self) -> dict[int, QByteArray]:
        d = {}
        for i, field in enumerate(fields(Annotation)):
            d[Qt.UserRole + i + 1] = field.name.encode()
        return d

    def rowCount(self, index: QModelIndex = QModelIndex()) -> int:
        return len(self.annotationList)

    def set(self, annotations: list[dict]):
        self.beginInsertRows(QModelIndex(), 0, len(annotations) - 1)
        for annotation in annotations:
            cls, kpnt = None, None
            if "cls" in annotation:
                cls = self.config["names"][annotation["cls"]]
            if "kpnt" in annotation:
                kpnt = KeypointList([Keypoint(*kp) for kp in annotation["kpnt"]])
                kpnt.dataChanged.connect(self.onKpntChanged)
            self.annotationList.append(Annotation(*annotation["bbox"], cls, kpnt))
        self.hist = History(self.annotationList.copy())
        self.endInsertRows()

    def clear(self):
        self.beginRemoveRows(QModelIndex(), 0, len(self.annotationList) - 1)
        self.annotationList.clear()
        self.endRemoveRows()
        return self.hist

    def undo(self):
        if self.hist:
            self.beginRemoveRows(QModelIndex(), 0, len(self.annotationList) - 1)
            self.annotationList = self.hist.pop()
            self.endRemoveRows()
            self.beginInsertRows(QModelIndex(), 0, len(self.annotationList) - 1)
            self.endInsertRows()

    def setData(self, index: QModelIndex, value: Any, role: int = Qt.EditRole) -> bool:

        return super().setData(index, value, role)

    def onKpntChanged(self, index: QModelIndex):
        self.dataChanged.emit(index, index, [Qt.DisplayRole])
