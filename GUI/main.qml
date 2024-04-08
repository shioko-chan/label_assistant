import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Basic 2.15
import QtQuick.Layouts 1.15

ApplicationWindow {
    id: mainWindow

    property bool confimClose: false
    property string imageSource: "../resource/default.jpg"
    property bool noDataSetTip: true
    property bool noModelTip: true
    property bool noModelConfigTip: true
    property bool noSavingDirTip: true
    property string nextButtonText: "开始"
    property bool allSaved: true
    property real completeCnt: 0
    property real dataSetSize: 0
    property bool modelError: false
    property alias pleaseWaitDialog: dialogs.pleaseWaitDialog
    property alias datasetDialog: dialogs.datasetDialog
    property alias modelDialog: dialogs.modelDialog
    property alias modelConfigDialog: dialogs.modelConfigDialog
    property alias savingDirDialog: dialogs.savingDirDialog
    property alias confirmQuitDialog: dialogs.confirmQuitDialog
    property alias usageDialog: dialogs.usageDialog
    property alias alreadyFirstDialog: dialogs.alreadyFirstDialog
    property alias alreadyLastDialog: dialogs.alreadyLastDialog
    property alias notFinishConfigDialog: dialogs.notFinishConfigDialog
    property alias modelErrorDialog: dialogs.modelErrorDialog
    property alias pleaseWaitDialogCloseTimer: timers.pleaseWaitDialogCloseTimer
    property alias modelPreheatStartTimer: timers.modelPreheatStartTimer

    signal nextImage()
    signal prevImage()
    signal chooseDataset(string path)
    signal selectModel(string path)
    signal selectModelConfig(string path)
    signal selectSavingDir(string path)
    signal saveConfig()
    signal saveLabels()
    signal undo()
    signal redo()

    function appendKpnt(kpnt) {
        annotation;
    }

    function appendAnnotation(annotation) {
        annotationList.append(annotation);
    }

    function removeAnnotation(index) {
        annotationList.remove(index);
    }

    function clearAnnotation() {
        annotationList.clear();
    }

    width: 700
    height: 700
    minimumWidth: 300
    minimumHeight: 300
    visible: true
    onClosing: function(close) {
        if (!confimClose && !allSaved) {
            close.accepted = false;
            confirmQuitDialog.open();
        } else {
            saveConfig();
        }
    }
    Component.onCompleted: {
        pleaseWaitDialog.parent = mainWindow.contentItem;
        confirmQuitDialog.parent = mainWindow.contentItem;
        usageDialog.parent = mainWindow.contentItem;
        alreadyFirstDialog.parent = mainWindow.contentItem;
        alreadyLastDialog.parent = mainWindow.contentItem;
        notFinishConfigDialog.parent = notFinishConfigDialog.contentItem;
        modelErrorDialog.parent = mainWindow.contentItem;
    }

    Dialogs {
        id: dialogs
    }

    Timers {
        id: timers
    }

    ColumnLayout {
        anchors.fill: parent

        TopBar {
        }

        ProgressBar {
            id: progressBar

            Layout.fillWidth: true
            height: 3
            Layout.alignment: Qt.AlignHCenter
            value: completeCnt
            to: dataSetSize
            visible: !noDataSetTip

            background: Rectangle {
                width: progressBar.visualPosition * parent.width
                height: parent.height
                radius: 2
                color: "#17a81a"
            }

            contentItem: Item {
                height: parent.height
            }

        }

        ImageArea {
        }

        Text {
            Layout.alignment: Qt.AlignHCenter
            text: "ShioriAya@XMURCS 2024."
        }

    }

}
