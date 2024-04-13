import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: labelWindow

    property list<color> colors: ["blue", "green", "red", "yellow", "gray", "orange", "pink", "purple", "#FFD700", "#ADFF2F", "#FF6347", "brown", "#40E0D0"]
    property real dotSize: 3

    signal zoomImage(real delta)
    signal transposeImage(real dx, real dy)
    Layout.fillHeight: true
    Layout.fillWidth: true
    focus: true
    Keys.enabled: true
    Keys.onPressed: function(event) {
        if (event.modifiers === Qt.ControlModifier) {
            switch (event.key) {
            case Qt.Key_S:
                saveLabels();
                break;
            case Qt.Key_Z:
                undo();
                break;
            case Qt.Key_Y:
                redo();
                break;
            case Qt.Key_Left:
                {
                    if (noDataSetTip || noModelTip || noModelConfigTip || noSavingDirTip) {
                        notFinishConfigDialog.open();
                        return ;
                    }
                    if (completeCnt <= 0) {
                        alreadyFirstDialog.open();
                    } else {
                        prevImage();
                        forceFocus();
                    }
                };
                break;
            case Qt.Key_Right:
                {
                    if (noDataSetTip || noModelTip || noModelConfigTip || noSavingDirTip) {
                        notFinishConfigDialog.open();
                        return ;
                    }
                    if (completeCnt + 1 >= dataSetSize) {
                        alreadyLastDialog.open();
                    } else {
                        nextImage();
                        forceFocus();
                    }
                };
                break;
            case Qt.Key_Plus:
            case Qt.Key_Equal:
                zoomImage(0.25);
                break;
            case Qt.Key_Minus:
                zoomImage(-0.25);
                break;
            }
        } else {
            switch (event.key) {
            case Qt.Key_Left:
                transposeImage(12, 0);
                break;
            case Qt.Key_Right:
                transposeImage(-12, 0);
                break;
            case Qt.Key_Up:
                transposeImage(0, 12);
                break;
            case Qt.Key_Down:
                transposeImage(0, -12);
                break;
            }
        }
    }

    Connections {
        function onForceFocus() {
            if (!focus)
                forceActiveFocus();

        }

        target: mainWindow
    }

    MouseArea {
        property real lastX: 0
        property real lastY: 0
        property bool isMoving: false
        // property real startX: 0
        // property real startY: 0
        anchors.fill: parent
        // acceptedButtons: Qt.LeftButton | Qt.RightButton
        // onPressed: function(mouse) {
        //     if (mouse.button === Qt.LeftButton) {
        //         lastX = mouseX;
        //         lastY = mouseY;
        //     }
        //     if (mouse.button === Qt.RightButton) {
        //         startX = mouseX;
        //         startY = mouseY;
        //     }
        // }
        onPressed: function(mouse) {
            lastX = mouseX;
            lastY = mouseY;
        }
        onReleased: function(mouse) {
            if (mouse.button == Qt.LeftButton && isMoving)
                isMoving = false;

        }
        onPositionChanged: function(mouse) {
            if (pressed) {
                transposeImage(mouseX - lastX, mouseY - lastY);
                isMoving = true;
            }
        }
        onWheel: function(event) {
            if (event.modifiers === Qt.ControlModifier) {
                if (event.angleDelta.y > 0)
                    transposeImage(10, 0);
                else if (event.angleDelta.y < 0)
                    transposeImage(-10, 0);
            } else if (event.modifiers === Qt.ShiftModifier) {
                if (event.angleDelta.y > 0)
                    transposeImage(0, 10);
                else if (event.angleDelta.y < 0)
                    transposeImage(0, -10);
            } else {
                if (event.angleDelta.y > 0)
                    zoomImage(0.2);
                else if (event.angleDelta.y < 0)
                    zoomImage(-0.2);
            }
        }
    }

    Text {
        visible: nextButtonText != "开始"
        text: "路径: " + imageSource + "\n总共" + dataSetSize + "张图片, 当前第" + (completeCnt + 1) + "张图片"
    }

    Image {
        id: labelImage

        property real image_top_left_x: (labelImage.width - labelImage.paintedWidth) / 2
        property real image_top_left_y: (labelImage.height - labelImage.paintedHeight) / 2

        x: 0
        y: 0
        scale: 1
        source: imageSource
        anchors.fill: parent
        fillMode: Image.PreserveAspectFit

        Connections {
            function onZoomImage(delta) {
                if (scale + delta >= 0.99)
                    scale += delta;

            }

            function onTransposeImage(dx, dy) {
                x += dx;
                y += dy;
            }

            target: labelWindow
        }

        Repeater {
            id: labelList

            anchors.fill: parent
            model: annotationList

            delegate: Item {
                property bool activated: false
                property int bbox_index: index

                anchors.fill: parent

                Rectangle {
                    id: bbox

                    property string cls: model.cls
                    property int cls_id: model.cls_id

                    color: "transparent"
                    border.color: activated ? "white" : colors[model.cls_id % colors.length]
                    border.width: 2
                    x: model.x * labelImage.paintedWidth - w * labelImage.paintedWidth / 2 + labelImage.image_top_left_x
                    y: model.y * labelImage.paintedHeight - h * labelImage.paintedHeight / 2 + labelImage.image_top_left_y
                    width: w * labelImage.paintedWidth
                    height: h * labelImage.paintedHeight

                    Rectangle {
                        color: "transparent"
                        height: 20
                        width: 20
                        anchors.bottom: parent.top
                        anchors.left: parent.left

                        Text {
                            color: activated ? "white" : colors[bbox.cls_id % colors.length]
                            text: bbox.cls
                            font.pixelSize: 20
                            font.bold: true
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: function(mouse) {
                                activated = !activated;
                                labelDialog.bbox_index = index;
                                labelDialog.open();
                            }

                            Connections {
                                function onLabelChanged(labelIndex) {
                                    if (labelDialog.bbox_index === index) {
                                        bbox.cls_id = labelIndex;
                                        bbox.cls = labelNames[labelIndex];
                                        setLabel(index, labelIndex);
                                    }
                                }

                                target: labelDialog
                            }

                        }

                    }

                    MouseArea {
                        property real bbox_width: parent.width
                        property real bbox_height: parent.height
                        property real lastX: 0
                        property real lastY: 0
                        property bool isMoving: false

                        anchors.centerIn: parent
                        acceptedButtons: Qt.LeftButton | Qt.RightButton
                        width: bbox_width + 4
                        height: bbox_height + 4
                        onClicked: function(mouse) {
                            if (mouse.button == Qt.RightButton)
                                deleteAnnotation(index);
                            else
                                activated = !activated;
                        }
                        onPressed: function(mouse) {
                            lastX = mouseX;
                            lastY = mouseY;
                        }
                        onReleased: function(mouse) {
                            if (mouse.button === Qt.LeftButton && isMoving) {
                                setBbox(index, (bbox.x - labelImage.image_top_left_x + bbox.width / 2) / labelImage.paintedWidth, (bbox.y - labelImage.image_top_left_y + bbox.height / 2) / labelImage.paintedHeight, bbox.width / labelImage.paintedWidth, bbox.height / labelImage.paintedHeight);
                                isMoving = false;
                            }
                        }
                        onPositionChanged: {
                            if (activated && pressed) {
                                bbox.height += mouseY - lastY;
                                bbox.width += mouseX - lastX;
                                lastX = mouseX;
                                lastY = mouseY;
                                isMoving = true;
                            }
                        }

                        MouseArea {
                            property real lastX: 0
                            property real lastY: 0
                            property bool isMoving: false

                            anchors.centerIn: parent
                            width: parent.bbox_width - 4
                            height: parent.bbox_height - 4
                            acceptedButtons: Qt.LeftButton | Qt.RightButton
                            onClicked: function(mouse) {
                                if (mouse.button == Qt.RightButton)
                                    deleteAnnotation(index);
                                else
                                    activated = !activated;
                            }
                            onPressed: function(mouse) {
                                lastX = mouseX;
                                lastY = mouseY;
                            }
                            onReleased: function(mouse) {
                                if (mouse.button == Qt.LeftButton && isMoving) {
                                    setBbox(index, (bbox.x - labelImage.image_top_left_x + bbox.width / 2) / labelImage.paintedWidth, (bbox.y - labelImage.image_top_left_y + bbox.height / 2) / labelImage.paintedHeight, bbox.width / labelImage.paintedWidth, bbox.height / labelImage.paintedHeight);
                                    isMoving = false;
                                }
                            }
                            onPositionChanged: {
                                if (activated && pressed) {
                                    bbox.x += mouseX - lastX;
                                    bbox.y += mouseY - lastY;
                                    isMoving = true;
                                }
                            }
                        }

                    }

                }

                Repeater {
                    id: keypointList

                    anchors.fill: parent
                    model: kpnt

                    delegate: Item {
                        property bool activated: false

                        anchors.fill: parent

                        Rectangle {
                            id: keypoint

                            color: activated ? "white" : colors[index % colors.length]
                            x: model.x * labelImage.paintedWidth + labelImage.image_top_left_x - dotSize / 2
                            y: model.y * labelImage.paintedHeight + labelImage.image_top_left_y - dotSize / 2
                            width: dotSize
                            height: dotSize
                            border.color: "black"
                            border.width: 0.1

                            MouseArea {
                                property real lastX: 0
                                property real lastY: 0
                                property bool isMoving: false

                                anchors.horizontalCenter: parent.horizontalCenter
                                anchors.verticalCenter: parent.verticalCenter
                                width: parent.width + 3
                                height: parent.height + 3
                                onClicked: function(mouse) {
                                    activated = !activated;
                                }
                                onPressed: function(mouse) {
                                    lastX = mouseX;
                                    lastY = mouseY;
                                }
                                onReleased: function(mouse) {
                                    if (mouse.button == Qt.LeftButton && isMoving) {
                                        setKpnt(bbox_index, index, (keypoint.x - labelImage.image_top_left_x + dotSize / 2) / labelImage.paintedWidth, (keypoint.y - labelImage.image_top_left_y + dotSize / 2) / labelImage.paintedHeight);
                                        isMoving = false;
                                    }
                                }
                                onPositionChanged: {
                                    if (activated && pressed) {
                                        keypoint.x += mouseX - lastX;
                                        keypoint.y += mouseY - lastY;
                                        isMoving = true;
                                    }
                                }
                            }

                            Text {
                                color: colors[index % colors.length]
                                anchors.bottom: parent.top
                                anchors.left: parent.left
                                text: index
                                font.pixelSize: 15
                                font.bold: true
                            }

                        }

                    }

                }

            }

        }

        Text {
            id: noDataSetTipText

            text: "尚未选择数据集或数据集已完成标注，点击文件选项卡选择数据集"
            color: "red"
            font.pixelSize: 20
            anchors.horizontalCenter: parent.horizontalCenter
            visible: noDataSetTip
        }

        Text {
            id: noModelTipText

            text: "尚未选择推理模型，点击文件选项卡选择推理模型"
            color: "red"
            font.pixelSize: 20
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: noDataSetTipText.bottom
            visible: noModelTip
        }

        Text {
            id: noModelConfigTipText

            text: "尚未选择推理模型配置文件，点击文件选项卡选择推理模型配置文件"
            color: "red"
            font.pixelSize: 20
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: noModelTipText.bottom
            visible: noModelConfigTip
        }

        Text {
            text: "尚未指定标注保存位置，点击文件选项卡指定标注保存位置"
            color: "red"
            font.pixelSize: 20
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: noModelConfigTipText.bottom
            visible: noSavingDirTip
        }

    }

}
