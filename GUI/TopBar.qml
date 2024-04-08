import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

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
                text: "选择模型配置文件"
                onTriggered: modelConfigDialog.open()
            }

            MenuItem {
                text: "选择标注保存位置"
                onTriggered: savingDirDialog.open()
            }

            MenuItem {
                text: "保存"
                onTriggered: saveLabels()
            }

            MenuItem {
                text: "退出"
                onTriggered: Qt.quit()
            }
        }

        Menu {
            title: "编辑"

            MenuItem {
                text: "撤销"
                onTriggered: undo
            }

            MenuItem {
                text: "重做"
                onTriggered: redo
            }
        }

        Menu {
            title: "帮助"

            MenuItem {
                text: "关于"
                onTriggered: usageDialog.open()
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
                if (noDataSetTip || noModelTip || noModelConfigTip || noSavingDirTip) {
                    notFinishConfigDialog.open();
                    return;
                }
                if (completeCnt <= 0.0) {
                    alreadyFirstDialog.open();
                } else
                    prevImage();
            }
        }

        Button {
            Layout.preferredWidth: 60
            Layout.preferredHeight: 25
            text: nextButtonText
            onClicked: {
                if (noDataSetTip || noModelTip || noModelConfigTip || noSavingDirTip) {
                    notFinishConfigDialog.open();
                    return;
                }
                if (completeCnt + 1 >= dataSetSize) {
                    alreadyLastDialog.open();
                } else
                    nextImage();
            }
        }
    }
}
