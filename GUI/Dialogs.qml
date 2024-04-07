import QtQuick.Dialogs 6.3
import QtQuick.Controls 2.15
import QtQuick 2.15

QtObject {
    property Dialog modelErrorDialog: Dialog {
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

    property Dialog notFinishConfigDialog: Dialog {
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

    property Dialog alreadyFirstDialog: Dialog {
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

    property Dialog alreadyLastDialog: Dialog {
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

    property Dialog pleaseWaitDialog: Dialog {
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

    property Dialog confirmQuitDialog: Dialog {
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

    property Dialog usageDialog: Dialog {
        title: "说明"
        standardButtons: Dialog.Ok
        anchors.centerIn: parent

        Label {
            text: "使用方法：\n按提示指定好所需的路径即可开始自动标注\n
            点击关键点，显示高亮后可以拖动改变位置\n拖动标注框边框可以改变大小，拖动标注框可以移动其位置\n
            Ctrl+S或菜单保存或点击下一张均可保存当前标注\nCtrl+Z撤销，Ctrl+Y重做，Ctrl+`←`上一张，Ctrl+`→`下一张\n
            选中图片后，Ctrl+`+`放大，Ctrl+`-`缩小，或者Ctrl+鼠标滚轮也可\n
            请确保所选模型和数据集匹配，否则可能无法正常工作\n"
            anchors.centerIn: parent
        }
    }

    property FolderDialog datasetDialog: FolderDialog {
        title: "请选择数据集图片文件夹"
        onAccepted: {
            chooseDataset(datasetDialog.selectedFolder);
        }
    }

    property FileDialog modelDialog: FileDialog {
        title: "请选择检测模型文件"
        fileMode: FileDialog.OpenFile
        nameFilters: ["*.pt"]
        onAccepted: {
            pleaseWaitDialog.open();
            pleaseWaitDialogCloseTimer.start();
            modelPreheatStartTimer.start();
        }
    }

    property FileDialog modelConfigDialog: FileDialog {
        title: "请选择模型配置文件"
        fileMode: FileDialog.OpenFile
        nameFilters: ["*.yaml"]
        onAccepted: {
            selectModelConfig(modelConfigDialog.selectedFile);
        }
    }

    property FolderDialog savingDirDialog: FolderDialog {
        title: "请选择保存文件夹"
        onAccepted: {
            selectSavingDir(savingDirDialog.selectedFolder);
        }
    }
}
