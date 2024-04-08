import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    // MouseArea {
    //     // onClicked: {
    //     //     main_window.handleMouseClick(rect, mouseArea.mapToItem(rect, mouse.x, mouse.y));
    //     // }
    //     id: mouseArea
    //     anchors.fill: parent
    // }
    id: labelWindow

    property list<color> colors: ["blue", "green", "red", "yellow", "gray", "orange", "pink", "purple", "#FFD700", "#ADFF2F", "#FF6347", "brown", "#40E0D0"]
    property real dotSize: 7

    Layout.fillHeight: true
    Layout.fillWidth: true

    Image {
        id: labelImage

        property real image_top_left_x: (labelImage.width - labelImage.paintedWidth) / 2
        property real image_top_left_y: (labelImage.height - labelImage.paintedHeight) / 2

        source: imageSource
        anchors.fill: parent
        fillMode: Image.PreserveAspectFit

        Text {
            visible: nextButtonText != "开始"
            text: "路径: " + imageSource + "\n总共" + dataSetSize + "张图片, 当前第" + (completeCnt + 1) + "张图片"
        }

        Repeater {
            id: labelList

            anchors.fill: parent
            model: annotationList

            // highlight: Rectangle {
            //     color: "lightsteelblue"
            //     radius: 5
            // }
            delegate: Item {
                property bool activated: false

                anchors.fill: parent

                Rectangle {
                    id: bbox

                    color: "transparent"
                    border.color: activated ? "white" : colors[model.cls_id % colors.length]
                    border.width: 2
                    x: model.x * labelImage.paintedWidth - w * labelImage.paintedWidth / 2 + labelImage.image_top_left_x
                    y: model.y * labelImage.paintedHeight - h * labelImage.paintedHeight / 2 + labelImage.image_top_left_y
                    width: w * labelImage.paintedWidth
                    height: h * labelImage.paintedHeight

                    Text {
                        color: colors[model.cls_id % colors.length]
                        anchors.bottom: parent.top
                        anchors.left: parent.left
                        text: cls
                        font.pixelSize: 25
                        font.bold: true
                    }

                    MouseArea {
                        property real lastX: 0
                        property real lastY: 0

                        anchors.fill: parent
                        onClicked: {
                            console.log(index);
                            activated = !activated;
                            lastX = mouseX;
                            lastY = mouseY;
                        }
                        onPositionChanged: {
                            if (activated && pressed) {
                                bbox.x += mouseX - lastX;
                                bbox.y += mouseY - lastY;
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
                            // MouseArea {
                            //     anchors.horizontalCenter: parent.horizontalCenter
                            //     anchors.verticalCenter: parent.verticalCenter
                            //     width: parent.width + 4
                            //     height: parent.height + 4
                            //     onClicked: {
                            //         console.log(index);
                            //         activated = !activated;
                            //     }
                            // }

                            id: keypoint

                            color: activated ? "white" : colors[index]
                            x: model.x * labelImage.paintedWidth + labelImage.image_top_left_x - dotSize / 2
                            y: model.y * labelImage.paintedHeight + labelImage.image_top_left_y - dotSize / 2
                            width: dotSize
                            height: dotSize
                            border.color: "black"
                            border.width: 1

                            MouseArea {
                                property real lastX: 0
                                property real lastY: 0

                                anchors.horizontalCenter: parent.horizontalCenter
                                anchors.verticalCenter: parent.verticalCenter
                                width: parent.width + 6
                                height: parent.height + 6
                                onClicked: {
                                    console.log(index);
                                    activated = !activated;
                                    lastX = mouseX;
                                    lastY = mouseY;
                                }
                                onPositionChanged: {
                                    if (activated && pressed) {
                                        keypoint.x += mouseX - lastX;
                                        keypoint.y += mouseY - lastY;
                                    }
                                }
                            }

                            Text {
                                color: colors[index]
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

            text: "尚未选择数据集，点击文件选项卡选择数据集"
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
