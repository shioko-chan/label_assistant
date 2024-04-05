import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

ApplicationWindow {
    id: main_window
    width: 700
    height: 700
    visible: true

    property bool confimClose: false
    property string imageSource: "../resource/default.jpg"
    signal nextImage

    ColumnLayout {
        width: parent.width
        height: parent.height
        RowLayout {
            Layout.alignment: Qt.AlignTop
            width: parent.width
            MenuBar {
                Menu {
                    title: "文件"
                    MenuItem {
                        text: "选择数据集"
                        onTriggered: {
                            console.log("New triggered");
                        }
                    }
                    MenuItem {
                        text: "选择模型"
                    }
                    MenuItem {
                        text: "保存"
                    }
                    MenuItem {
                        text: "退出"
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

            RowLayout {
                Layout.alignment: Qt.AlignRight
                anchors.rightMargin: 3
                spacing: 5
                Button {
                    Layout.preferredWidth: 60
                    Layout.preferredHeight: 25
                    text: "上一张"
                    onClicked: {}
                }

                Button {
                    Layout.preferredWidth: 60
                    Layout.preferredHeight: 25
                    text: "下一张"
                    onClicked: {}
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
            }
        }
    }
    Dialog {
        id: confirmDialog
        title: "确认退出"
        standardButtons: Dialog.Ok | Dialog.Cancel

        anchors.centerIn: parent

        Label {
            text: "尚未保存，是否放弃未保存的内容退出？"
            anchors.centerIn: parent
        }

        onAccepted: {
            confimClose = true;
            quitTimer.start();
        }

        onRejected: {
            confirmDialog.close();
        }
    }

    onClosing: function (close) {
        if (!confimClose) {
            close.accepted = false;
            confirmDialog.open();
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
