import QtQuick 2.12
import QtQuick.Controls 2.4
import QtQuick.Controls.Material 2.3
import QtGraphicalEffects 1.0
import QtWebEngine 1.8
import Qt.labs.settings 1.0
import Qt.labs.platform 1.1
import QtQuick.Layouts 1.12

Pane {
    id: root

    // -------------------------------------------------------
    // Data
    // -------------------------------------------------------

    property var model: settings.model
    property int currentIndex: 0
    property bool ctrlPressed: false
    property var icons: []

    Settings {
        id: settings

//        property var model: [].concat(root.model)
        property var model: []
        property alias currentIndex: root.currentIndex
    }

    Component.onDestruction: {
        //settings.model = JSON.stringify([].concat(root.model))
        settings.model = [].concat(root.model)
    }

    // -------------------------------------------------------
    // View
    // -------------------------------------------------------

    padding: 0

    Pane {
        id: masterPane

        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: 200

        padding: 0

        Material.theme: Material.Dark
        Material.elevation: 10
        z: detailsPane.z + 10

        ListView {
            anchors.fill: parent

            model: root.model
            delegate: ItemDelegate {
                width: parent.width
//                text: "" + modelData.name
                highlighted: root.currentIndex == index

                onClicked: currentIndex = index

//                onHoveredChanged: {
//                    if (hovered) {
//                        stack.currentIndex = index
//                    }
//                    else {
//                        stack.currentIndex = Qt.binding(function(){ return root.currentIndex; })
//                    }

//                }

                contentItem: Row {
                    width: parent.width
                    height: 100
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 10

                    Rectangle {
                        height: parent.height * 0.6
                        width: height
                        anchors.verticalCenter: parent.verticalCenter
                        visible: root.ctrlPressed

                        color: Material.accent
                        radius: 1


                        Label {
                            anchors.centerIn: parent
                            text: "" + (index + 1)
                        }
                    }

                    Image {
                        height: parent.height * 0.6
                        width: height
                        anchors.verticalCenter: parent.verticalCenter

                        fillMode: Image.PreserveAspectFit
                        source: webviews.itemAt(index).icon
                        mipmap: true
                    }

                    Label {
                        anchors.verticalCenter: parent.verticalCenter
                        text: "" + modelData["name"]
                    }
                }

                Row {
                    visible: parent.hovered
//                    width: parent.width * 1/2
//                    height: parent.height
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter

                    RoundButton {
                        width: 40
                        height: 40

                        icon.source: "img/eye.svg"
                        visible: root.currentIndex !== index

                        onHoveredChanged: {
                            if (hovered) {
                                peekPage(index)
                            }
                            else {
                                stack.currentIndex = Qt.binding(function(){ return root.currentIndex; })
                            }
                        }
                    }

                    RoundButton {
                        width: 40
                        height: 40

                        text: ""
                        icon.source: "img/trash.svg"
                        font.family: "Consolas"

                        onClicked: root.removePanel(modelData["name"])
                    }
                }
            }
        }

        RoundButton {
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            anchors.bottomMargin: 5
            anchors.rightMargin: 5

            text: "+"
            ToolTip.visible: hovered
            ToolTip.text: "Add a new panel"

            onClicked: {
                panelCreationDialog.reset()
                panelCreationDialog.open()
            }
        }
    }

    Pane {
        id: detailsPane

        anchors.left: masterPane.right
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom

        padding: 0

        StackLayout {
            id: stack
            anchors.fill: parent

            currentIndex: root.currentIndex

            Repeater {
                id: webviews
                model: root.model

                WebEngineView {
                    anchors.fill: parent

                    url: root.model[index]["url"]
                    //settings.allowRunningInsecureContent: true
                    settings.allowRunningInsecureContent: true
                    settings.javascriptCanOpenWindows: true
                    settings.allowWindowActivationFromJavaScript: true
                    settings.dnsPrefetchEnabled: true
                    settings.errorPageEnabled: true
                    settings.javascriptCanAccessClipboard: true
                    settings.javascriptCanPaste: true
                    settings.localContentCanAccessRemoteUrls: true
                    settings.pluginsEnabled: true
                    settings.focusOnNavigationEnabled: true

                    onCertificateError: {
                        error.ignoreCertificateError()
                    }

                    onJavaScriptConsoleMessage: {
                        print(message)
                    }

                    onFeaturePermissionRequested: {
                        grantFeaturePermission(securityOrigin, feature)
                    }

                    onNewViewRequested: {
                        Qt.openUrlExternally(request.requestedUrl)
                    }

//                    onNavigationRequested: {
////                        Qt.openUrlExternally(request.url)
//                       print("requested", request.url, "\n", request.navigationType)
//                    }

                    profile: WebEngineProfile {

                        offTheRecord: false
                        storageName: "zozo"
                        httpCacheType: WebEngineProfile.DiskHttpCache
//                        cachePath: StandardPaths.writableLocation(StandardPaths.CacheLocation)
//                        persistentStoragePath: StandardPaths.writableLocation(StandardPaths.DataLocation)
                        persistentCookiesPolicy: WebEngineProfile.AllowPersistentCookies

                        // Chrome 70
                        httpUserAgent: "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/70.0.3538.77 Safari/537.36"

                        onDownloadRequested: {
                            root.onDownloadRequested(download)
                        }
                    }
//                    onFileDialogRequested: {
//                    }


//                    profile: WebEngineProfile {
//                        httpUserAgent: "Mozilla/5.0 (Windows NT 10.0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/42.0.2311.135 Safari/537.36 Edge/12.10136"
//                    }

//                    Shortcut {
//                        sequence: "Ctrl+" + (index + 1)
//                        onActivated: root.currentIndex = index
//                    }
                }
            }
        }
    }


    // -------------------------------------------------------
    // Other views
    // -------------------------------------------------------

    // Publish Dialog
    Popup {
        id: panelCreationDialog

        width: Math.max(parent.width * 0.5, 300)
        height: Math.max(parent.height * 0.33, 200)
        x: root.width / 2 - width / 2
        y: root.height / 2 - height / 2

        clip: true
        padding: 0

        modal: true
        focus: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

        Page {
            anchors.fill: parent
            padding: 0

            Component.onCompleted: panelNameTextField.forceActiveFocus()

            header: Pane {
                Material.theme: Material.Dark

                Label {
                    anchors.centerIn: parent
                    font.pointSize: 16
                    text: "Add a new panel"
                }
            }

            Column {
                width: parent.width
                anchors.centerIn: parent

                TextField {
                    id: panelNameTextField
                    width: parent.width * 0.66
                    anchors.horizontalCenter: parent.horizontalCenter
                    placeholderText: "Enter panel name..."
                    selectByMouse: true
                    onAccepted: onDialogAccepted()
                }
                TextField {
                    id: panelUrlTextField
                    width: parent.width * 0.66
                    anchors.horizontalCenter: parent.horizontalCenter
                    placeholderText: "Enter panel url..."
                    selectByMouse: true
                    onAccepted: onDialogAccepted()
                }

                Button {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "Create"

                    onClicked: onDialogAccepted()
                }
            }

        }

        function reset() {
            panelNameTextField.clear()
            panelUrlTextField.clear()
        }
    }

//    focus: true
//    Keys.onPressed: {
//        if (event.key == Qt.Key_Control) {
//             root.ctrlPressed = true
//         }
//    }
//    Keys.onReleased:  {
//        if (event.key == Qt.Key_Control) {
//             root.ctrlPressed = false
//         }
//    }

    Popup {
        id: downloadDialog

        property var downloadItem;

        width: Math.max(parent.width * 0.5, 300)
        height: Math.max(parent.height * 0.33, 200)
        x: root.width / 2 - width / 2
        y: root.height / 2 - height / 2

        clip: true
        padding: 0

        modal: true
        focus: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

        Page {
            anchors.fill: parent

            header: Pane {
                Material.theme: Material.Dark

                Label {
                    anchors.centerIn: parent
                    font.pointSize: 16
                    text: "Download"
                }
            }

            Column {
                anchors.centerIn: parent
//                spacing: 20

                Label {
                    height: 40
                    anchors.horizontalCenter: parent.horizontalCenter
                    //text: "Hello" + downloadDialog.downloadItem.state //+ "\n" + downloadDialog.downloadItem.path
                    text: downloadDialog.downloadItem.state == WebEngineDownloadItem.DownloadInProgress ? "Downloading" :
                          downloadDialog.downloadItem.state == WebEngineDownloadItem.DownloadCompleted  ? "Completed"   :
                                                                                                         "Unknown state";

                    verticalAlignment: Label.AlignVCenter

                    color: downloadDialog.downloadItem.state == WebEngineDownloadItem.DownloadCompleted ? "green": "black"
                }

                BusyIndicator {
                    width: 30
                    height: width
                    visible: running
                    running: downloadDialog.downloadItem.state == WebEngineDownloadItem.DownloadInProgress
                }

                RoundButton {
                    anchors.horizontalCenter: parent.horizontalCenter
                    visible: downloadDialog.downloadItem.state == WebEngineDownloadItem.DownloadCompleted

                    property string dlPath: {
                        var vPath = "" + Qt.resolvedUrl(downloadDialog.downloadItem.path)
                        var a = Math.max(vPath.lastIndexOf("/"), vPath.lastIndexOf("%5C"))
                        return vPath.substring(0, a)
                    }

                    ToolTip.visible: hovered
                    ToolTip.text: dlPath

                    icon.source: "img/folder.svg"
                    onClicked: {
                        Qt.openUrlExternally(dlPath)
                    }
                }
            }
        }
    }

    Shortcut {
        sequence: "Ctrl+Down"
        onActivated: changeCurrentIndex(root.currentIndex + 1)
    }
    Shortcut {
        sequence: "Ctrl+Up"
        onActivated: changeCurrentIndex(root.currentIndex - 1)
    }
    Shortcut {
        sequence: "F5"
        onActivated: root.modelChanged()
    }

    // -------------------------------------------------------
    // Logic
    // -------------------------------------------------------

    function createPanel(panelName, panelUrl) {
        var newObject = {
                            "name": panelName,
                            "url": panelUrl
                        }
        root.model.push(newObject)
        root.modelChanged()

        root.currentIndex = root.model.length - 1
    }

    function removePanel(panelName) {
        root.model = root.model.filter(function(panel) {
            return panel["name"] !== panelName;
        });
        root.modelChanged()
    }

    function onDialogAccepted() {
        if (panelNameTextField.text.length === 0) {
            panelNameTextField.forceActiveFocus()
            return;
        }
        if (panelUrlTextField.text.length === 0) {
            panelUrlTextField.forceActiveFocus()
            return;
        }
        createPanel(panelNameTextField.text, panelUrlTextField.text)
        panelCreationDialog.close()
    }

    function changeCurrentIndex(index) {
        var newIndex = index
        if (newIndex >= root.model.length)
            newIndex = 0
        else if (newIndex < 0)
            newIndex = root.model.length - 1
        root.currentIndex = newIndex
    }
    onCurrentIndexChanged: {
//        stack.focus = true
//        stack.forceActiveFocus()
        webviews.itemAt(root.currentIndex).focus = true
        webviews.itemAt(root.currentIndex).forceActiveFocus()
    }

    function peekPage(index) {
        stack.currentIndex = index
    }

    function onDownloadRequested(download) {
        downloadDialog.downloadItem = download
        downloadDialog.open()

        // Starts the download
        download.accept()
    }
}
