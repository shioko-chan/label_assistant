import QtQuick.Controls 2.15
import QtQuick 2.15

QtObject {
    property Timer pleaseWaitDialogCloseTimer: Timer {
        interval: 300
        onTriggered: pleaseWaitDialog.close()
    }

    property Timer modelPreheatStartTimer: Timer {
        interval: 10
        repeat: false
        onTriggered: {
            selectModel(modelDialog.selectedFile);
            if (modelError) {
                modelErrorDialog.open();
                modelError = false;
            }
        }
    }
}
