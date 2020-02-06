import QtQuick 2.12
import QtQuick.Window 2.12

Window {
    visible: true
    width: 640
    height: 480
    title: qsTr("CustomColorPicker")

    ColorPicker{
        id: cPicker
        anchors.fill: parent

        selectedColor: "steelblue"
        onSelectedColorChanged: console.log("New Selected Color", selectedColor)
    }
}
