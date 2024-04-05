import sys
from PySide6.QtCore import QObject, Signal, Slot, QPointF
from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine
from PySide6.QtQuick import QQuickItem


class InteractionHandler(QObject):
    pointAdded = Signal(float, float)

    @Slot(float, float)
    def addPoint(self, x, y):
        self.pointAdded.emit(x, y)


class MainWindow(QObject):
    def __init__(self):
        super().__init__()

    @Slot(QQuickItem, QPointF)
    def handleMouseClick(self, item, pos):
        if item and item.objectName() == "rect":
            x = pos.x() - item.width() / 2
            y = pos.y() - item.height() / 2
            interaction_handler.addPoint(x, y)


if __name__ == "__main__":
    app = QGuiApplication(sys.argv)
    engine = QQmlApplicationEngine()

    interaction_handler = InteractionHandler()
    engine.rootContext().setContextProperty("interaction_handler", interaction_handler)

    main_window = MainWindow()
    engine.rootContext().setContextProperty("main_window", main_window)

    engine.load("main.qml")

    if not engine.rootObjects():
        sys.exit(-1)

    app.exec()
    sys.exit()
