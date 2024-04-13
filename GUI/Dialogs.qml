import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Dialogs 6.3

QtObject {
    property Dialog modelErrorDialog
    property Dialog notFinishConfigDialog
    property Dialog alreadyFirstDialog
    property Dialog alreadyLastDialog
    property Dialog pleaseWaitDialog
    property Dialog confirmQuitDialog
    property Dialog usageDialog
    property FolderDialog datasetDialog
    property FileDialog modelDialog
    property FileDialog modelConfigDialog
    property FolderDialog savingDirDialog
    property Dialog labelDialog

    modelErrorDialog: Dialog {
        width: 200
        height: 100
        title: "模型文件加载失败"
        standardButtons: Dialog.Ok
        anchors.centerIn: parent

        Label {
            text: "模型文件加载失败"
            anchors.centerIn: parent
        }

    }

    notFinishConfigDialog: Dialog {
        width: 200
        height: 100
        title: "未完成配置"
        standardButtons: Dialog.Ok
        anchors.centerIn: parent

        Label {
            text: "请先完成配置"
            anchors.centerIn: parent
        }

    }

    alreadyFirstDialog: Dialog {
        width: 200
        height: 100
        title: "已经是第一张了"
        standardButtons: Dialog.Ok
        anchors.centerIn: parent

        Label {
            text: "已经是第一张了"
            anchors.centerIn: parent
        }

    }

    alreadyLastDialog: Dialog {
        width: 200
        height: 100
        title: "已经是最后一张了"
        standardButtons: Dialog.Ok
        anchors.centerIn: parent

        Label {
            text: "已经是最后一张了"
            anchors.centerIn: parent
        }

    }

    pleaseWaitDialog: Dialog {
        width: 200
        height: 100
        title: "请稍等"
        standardButtons: Dialog.Ok
        anchors.centerIn: parent

        Label {
            text: "正在加载模型，请稍等..."
            anchors.centerIn: parent
        }

    }

    confirmQuitDialog: Dialog {
        title: "确认退出"
        standardButtons: Dialog.Ok | Dialog.Cancel
        anchors.centerIn: parent
        onAccepted: {
            confimClose = true;
            Qt.quit();
        }

        Label {
            text: "尚未保存，是否放弃未保存的内容退出？"
            anchors.centerIn: parent
        }

    }

    usageDialog: Dialog {
        title: "说明"
        standardButtons: Dialog.Ok
        anchors.centerIn: parent

        Label {
            text: "使用方法：\n按提示指定好所需的路径即可开始标注\n
            点击关键点，显示高亮后可以拖动改变位置\n拖动标注框边框可以改变大小，拖动标注框可以移动其位置\n
            Ctrl+S或菜单保存或点击下一张均可保存当前标注\nCtrl+Z撤销，Ctrl+Y重做，Ctrl+`←`上一张，Ctrl+`→`下一张\n
            Ctrl+`+`放大，Ctrl+`-`缩小，或者使用鼠标滚轮也可放大缩小\n
            Ctrl+鼠标滚轮左右移动，Shift+鼠标滚轮上下移动\n
            请确保所选模型和数据集匹配，否则可能无法正常工作\n"
            anchors.centerIn: parent
        }

    }

    datasetDialog: FolderDialog {
        title: "请选择数据集图片文件夹"
        onAccepted: {
            chooseDataset(datasetDialog.selectedFolder);
        }
    }

    modelDialog: FileDialog {
        title: "请选择检测模型文件"
        fileMode: FileDialog.OpenFile
        nameFilters: ["*.pt"]
        onAccepted: {
            pleaseWaitDialog.open();
            pleaseWaitDialogCloseTimer.start();
            modelPreheatStartTimer.start();
        }
    }

    modelConfigDialog: FileDialog {
        title: "请选择模型配置文件"
        fileMode: FileDialog.OpenFile
        nameFilters: ["*.yaml"]
        onAccepted: {
            selectModelConfig(modelConfigDialog.selectedFile);
        }
    }

    savingDirDialog: FolderDialog {
        title: "请选择保存文件夹"
        onAccepted: {
            selectSavingDir(savingDirDialog.selectedFolder);
        }
    }

    labelDialog: Dialog {
        id: checkboxDialog

        property int bbox_index: -1

        signal labelChanged(int label)

        anchors.centerIn: parent
        title: "请选择"
        width: 300
        height: 400
        standardButtons: Dialog.Ok | Dialog.Cancel
        onAccepted: {
            if (buttonGroup.selected) {
                let labelIndex = buttonGroup.checkedButton.labelIndex;
                labelChanged(labelIndex);
            }
        }

        ButtonGroup {
            id: buttonGroup

            property bool selected: false
        }

        GridView {
            id: gridView

            anchors.fill: parent
            model: labelNames
            cellWidth: width / 2
            cellHeight: 20

            delegate: Item {
                width: gridView.cellWidth
                height: gridView.cellHeight

                RadioButton {
                    property int labelIndex: index

                    text: modelData
                    checked: buttonGroup.checkedButton === this
                    ButtonGroup.group: buttonGroup
                    onCheckedChanged: {
                        if (checked)
                            buttonGroup.selected = true;

                    }
                }

            }

        }

    }

}
