import QtQuick 2.12
import QtQuick.Controls 2.12

Item {
    id: colorSlider

    height: 30

    property alias text: lbl.text
    property color color: "red"
    property int value: 0
    signal changed(var value)

    Label {
        id:lbl
        anchors{
            left: parent.left
            top: parent.top
            bottom: parent.bottom
        }
        text: "Red"

        background: Rectangle{
            border.color: "black"
            border.width: 1
        }

        verticalAlignment: Text.AlignVCenter
        padding: 5
        width: parent.width / 8
    }

    Slider{
        id:slider
        anchors{
            left: lbl.right
            right: sBox.left
            top: parent.top
            bottom: parent.bottom
        }

        from: 0
        to: 255
        value: colorSlider.value
        onValueChanged: {
            colorSlider.changed(parseInt(value))
        }

        background: Rectangle {
            x: slider.leftPadding
            y: slider.topPadding + slider.availableHeight / 2 - height / 2
            implicitWidth: 200
            implicitHeight: 4
            width: slider.availableWidth
            height: implicitHeight
            radius: 2
            color: "#bdbebf"

            Rectangle {
                width: slider.visualPosition * parent.width
                height: parent.height
                color: colorSlider.color
                radius: 2
            }
        }
    }

    SpinBox{
        id:sBox
        anchors{
            top: parent.top
            bottom: parent.bottom
            right: parent.right
        }
        width: parent.width / 5

        from: 0
        to: 255
        value: colorSlider.value
        onValueChanged: colorSlider.changed(value)

    }
}
