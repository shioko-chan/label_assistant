import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Dialogs
import QtQuick.Layouts 1.15

ApplicationWindow {
    id: main_window

    property bool confimClose: false
    property string imageSource: "../resource/default.jpg"
    property bool noDataSetTip: true
    property bool noModelTip: true

    signal nextImage()
    signal chooseDataset(string path)
    signal selectModel(string path)
    signal saveLabels()

    // signal handleMouseClick(var rect, var point)
    width: 700
    height: 700
    visible: true
    onClosing: function(close) {
        if (!confimClose) {
            close.accepted = false;
            confirmQuitDialog.open();
        }
    }

    ColumnLayout {
        anchors.fill: parent

        RowLayout {
            width: parent.width
            Layout.fillWidth: true

            MenuBar {
                Menu {
                    title: "文件"

                    MenuItem {
                        text: "选择数据集"
                        onTriggered: datasetDialog.open()
                    }

                    MenuItem {
                        text: "选择模型"
                        onTriggered: modelDialog.open()
                    }

                    MenuItem {
                        text: "保存"
                        onTriggered: saveLabels()
                    }

                    MenuItem {
                        text: "退出"
                        onTriggered: {
                            if (!confimClose)
                                confirmQuitDialog.open();

                        }
                    }

                }

                Menu {
                    title: "编辑"

                    MenuItem {
                        text: "撤销"
                    }

                    MenuItem {
                        text: "重做"
                    }

                }

                Menu {
                    title: "帮助"

                    MenuItem {
                        text: "关于"
                    }

                }

            }

            Item {
                Layout.fillWidth: true
            }

            RowLayout {
                spacing: 5

                Button {
                    Layout.preferredWidth: 60
                    Layout.preferredHeight: 25
                    text: "上一张"
                    onClicked: {
                        if (noDataSetTip || noModelTip)
                            return;
                        nextImage();
                    }
                }

                Button {
                    Layout.preferredWidth: 60
                    Layout.preferredHeight: 25
                    text: "下一张"
                    onClicked: {
                        if (noDataSetTip || noModelTip)
                            return;
                        nextImage();
                    }
                }

            }

        }

        Rectangle {
            id: rect

            objectName: "rect"
            color: "lightblue"
            Layout.fillHeight: true
            Layout.fillWidth: true
            border.color: "black"
            border.width: 1

            MouseArea {
                id: mouseArea

                anchors.fill: parent
                onClicked: {
                    main_window.handleMouseClick(rect, mouseArea.mapToItem(rect, mouse.x, mouse.y));
                }
            }

            Image {
                id: image

                source: imageSource
                anchors.fill: parent
                fillMode: Image.PreserveAspectFit

                Text {
                    id: noDataSetTipText

                    text: "尚未选择数据集，点击文件选项卡选择数据集"
                    color: "black"
                    font.pixelSize: 20
                    anchors.horizontalCenter: parent.horizontalCenter
                    visible: noDataSetTip
                }

                Text {
                    text: "尚未选择推理模型，点击文件选项卡选择推理模型"
                    color: "black"
                    font.pixelSize: 20
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: noDataSetTipText.bottom
                    visible: noModelTip
                }

            }

        }

    }

    Dialog {
        id: confirmQuitDialog

        title: "确认退出"
        standardButtons: Dialog.Ok | Dialog.Cancel
        anchors.centerIn: parent
        onAccepted: {
            confimClose = true;
            quitTimer.start();
        }
        onRejected: {
            confirmQuitDialog.close();
        }

        Label {
            text: "尚未保存，是否放弃未保存的内容退出？"
            anchors.centerIn: parent
        }

    }

    FolderDialog {
        id: datasetDialog

        title: "请选择数据集图片文件夹"
        onAccepted: {
            chooseDataset(datasetDialog.selectedFolder);
            console.log("你选择的文件夹是：" + datasetDialog.selectedFolder);
        }
    }

    FileDialog {
        id: modelDialog

        title: "请选择检测模型文件"
        nameFilters: ["*.pt"]
        onAccepted: {
            selectModel(modelDialog.fileUrls);
            console.log("你选择的文件是：" + modelDialog.fileUrls);
        }
    }

    Timer {
        id: quitTimer

        interval: 10
        onTriggered: Qt.quit()
    }

    Text {
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        text: "Click inside the blue rectangle to draw a point."
    }

}
