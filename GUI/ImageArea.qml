import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: labelWindow
    Layout.fillHeight: true
    Layout.fillWidth: true

    MouseArea {
        id: mouseArea

        anchors.fill: parent
        // onClicked: {
        //     main_window.handleMouseClick(rect, mouseArea.mapToItem(rect, mouse.x, mouse.y));
        // }
    }

    property list<color> colors: ["blue", "green", "red", "yellow", "gray", "purple", "orange", "pink", "brown", "black", "white"]
    Image {
        id: labelImage
        source: imageSource
        anchors.fill: parent
        fillMode: Image.PreserveAspectFit

        Text {
            text: "Image content position: (" + ((labelImage.width - labelImage.paintedWidth) / 2) + ", " + ((labelImage.height - labelImage.paintedHeight) / 2) + ")"
        }

        property real image_top_left_x: (labelImage.width - labelImage.paintedWidth) / 2
        property real image_top_left_y: (labelImage.height - labelImage.paintedHeight) / 2

        ListView {
            id: labelList
            anchors.fill: parent
            model: annotationList
            highlight: Rectangle {
                color: "lightsteelblue"
                radius: 5
            }
            delegate: Rectangle {
                color: "blue"
                x: annotationList.bbox[0] * labelImage.width + labelImage.image_top_left_x
                y: annotationList.bbox[1] * labelImage.height + labelImage.image_top_left_y
                width: annotationList.bbox[2] * labelImage.width
                height: annotationList.bbox[3] * labelImage.height

                Text {
                    // anchors.bottom: parent.top
                    // anchors.left: parent.left
                    text: cls
                }
                Component.onCompleted: {
                    console.log("annotationList.bbox: ", annotationList.bbox[0], annotationList.bbox[1], annotationList.bbox[2], annotationList.bbox[3]);
                    console.log("x", x);
                    console.log("y", y);
                    console.log("x", annotationList.bbox[0] * labelImage.width + labelImage.image_top_left_x);
                }
                // MouseArea {
                //     anchors.fill: parent
                //     onClicked: {
                //         labelList.currentIndex = index;
                //     }
                // }
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
