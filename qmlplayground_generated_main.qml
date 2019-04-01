import QtQuick 2.12
import QtQuick.Window 2.2

Window {
    visible: true
    width: 1920
    height: 1080
    title: qsTr("MasterChat")

    Loader {
        anchors.fill: parent
        asynchronous: true; // apparently essential for animations
        source: "qrc:///main.qml"
    }
}