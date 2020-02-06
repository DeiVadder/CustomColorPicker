import QtQuick 2.12
import QtQuick.Controls 2.12

Rectangle{
    id: root

    property int dotRadius: cv.size * 0.025

    property color selectedColor: "lightblue"
    property int sliderHeight: 30

    onSelectedColorChanged: if(selectedColor)calculatePosAndRGBA()

    Component.onCompleted: calculatePosAndRGBA()

    //Helper functions
    function calculatePosAndRGBA(){
        colorToRgbProperties(selectedColor)
        colorIndicator.rgbToPosition()
    }

    function colorToRgbProperties(color){
        //Assume color with alpha value (#AARRGGBB)
        var result = /^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i.exec(color);
        if(result)  {
            r = parseInt(result[2], 16)
            g = parseInt(result[3], 16)
            b = parseInt(result[4], 16)
            a = parseInt(result[1], 16)
          } else {
            //Assume no alpha value e.g: lightblue(#RRGGBB)
            result = /^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i.exec(color);
            if(result){
                r = parseInt(result[1], 16)
                g = parseInt(result[2], 16)
                b = parseInt(result[3], 16)
                a = parseInt(255)
              } else {
                //Default -> Black
                r = 255
                g = 255
                b = 255
                a = 255
            }
        }
    }

    function intToHex(value){
        var hex = Number(value).toString(16)
        if(hex.length < 2)
            return "0"+hex
        return hex
    }

    property int a: 0
    onAChanged: cv.requestPaint()
    property int r: 0
    property int g: 0
    property int b: 0

    Rectangle{
        id: selectedColorIndicator
        anchors{
            top: parent.top
            left: parent.left
            right: parent.right
        }
        height: 50
        z:1

        color: selectedColor
    }

    //Centered interactive ColorWheel
    Rectangle{
        id:centerPicker

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: selectedColorIndicator.bottom
        width: parent.width /*200*/
        height: root.height - (sliderHeight * 4 + 5) - selectedColorIndicator.height
        color: "white"

        Canvas{
            id: cv
            anchors.centerIn: parent
            readonly property int size: Math.min(parent.width, parent.height) * 3 / 4
            onSizeChanged: {
                colorIndicator.rgbToPosition()
            }

            width: size
            height: size

            property var context: undefined
            property int radius: Math.max(width / 2,1)

            onPaint:{
                if(size < 1)
                    return

                context = getContext("2d");
                context.reset()

                var x = width / 2;
                var y = height / 2;
                var counterClockwise = false;

                //Black Background for black selection & alpha indication
                context.fillStyle = "#"+ intToHex(a) + "000000"
                context.fillRect(0,0, width, height)

                //White Background circle for white balance
                context.moveTo(x, y);
                context.arc(x,y,cv.radius, 0, 2 *Math.PI,false)
                context.fillStyle = "white"
                context.fill();

                //Actual ColorWheel
                for(var angle=0; angle<=360; angle+=1){
                    var startAngle = (angle-2)*Math.PI/180;
                    var endAngle = angle * Math.PI/180;
                    context.beginPath();
                    context.moveTo(x, y);
                    context.arc(x, y, cv.radius, startAngle, endAngle, counterClockwise);
                    context.closePath();
                    var gradient = context.createRadialGradient(x, y, 0, x, y, cv.radius);
                    gradient.addColorStop(0,'hsl('+angle+', 10%, 100%)');
                    gradient.addColorStop(1,'hsl('+angle+', 100%, 50%)');
                    context.fillStyle = gradient;
                    context.fill();
                }

                //White CenterPoint
                context.beginPath()
                context.moveTo(x, y);
                context.arc(x,y,dotRadius, 0,2 *Math.PI)
                context.closePath()
                context.fillStyle = "white"
                context.fill();
            }

            Rectangle{
                id: colorIndicator
                /*Circular Dot on the ColorWheel that can be draged around for new color selection,
                  or simply indicates where the selected color is on the ColorWheel*/
                width: dotRadius * 2
                height: dotRadius * 2
                border.width: 1
                border.color: "black"
                radius: width/2
                color: "white"

                property int xDot: 0
                property int yDot: 0

                readonly property int calcX: xDot - width /2
                readonly property int calcY: yDot - height /2

                x:{
                    if(calcX < - width / 2)
                        return - width / 2
                    if(calcX > cv.width - width / 2)
                        return cv.width - width / 2
                    return calcX
                }

                y: {
                    if(calcY < - height / 2)
                        return - height / 2
                    if(calcY > cv.height - height / 2)
                        return cv.height - height / 2
                    return calcY
                }

                function mapToRange(value, x1, y1, x2, y2){
                    return (value - x1) * (y2 - x2) / (y1 - x1) + x2;
                }

                function rgbToPosition(){
                    var h = hue() * Math.PI / 180
                    var s = mapToRange(saturation(),0,1,0,cv.radius)

                    var X = (Math.cos(h) * s + cv.radius)
                    var Y = (Math.sin(h) * s + cv.radius)

                    colorIndicator.xDot = X
                    colorIndicator.yDot = Y
                }

                function hue (){
                    var G = mapToRange(g, 0, 255, 0, 1)
                    var B = mapToRange(b, 0, 255, 0, 1)
                    var R = mapToRange(r, 0, 255, 0, 1)

                    var value = mapToRange(Math.max(r,g, b), 0,255, 0, 1)
                    var min = mapToRange(Math.min(r,g,b), 0, 255, 0, 1)
                    var C = value - min

                    var max = Math.max(R,G,B)

                    if( r == g && b == r)
                        return 0

                    if(max == R)
                        return 60 * (0 + (G-B)/C)
                    if(max == G)
                        return 60 * (2 + (B-R)/C)
                    if(max == B)
                        return 60 * (4 + (R-G)/C)
                }

                function saturation(){
                    var value = mapToRange(Math.max(r,g, b), 0,255, 0, 1)
                    var min = mapToRange(Math.min(r,g,b), 0, 255, 0, 1)
                    var croma = value - min

                    if(value == min)
                        if(min == 0)
                            return 0

                    return croma / value
                }
            }

            MouseArea{
                id:mArea
                anchors.fill: parent

                function rgbToHex(r,g, b){
                    if(r > 255 || g > 255 || b > 255)
                        console.log("Invalid")
                    return ((r << 16) | (g << 8) | b).toString(16)
                }

                function newColorPos(){
                    var p = cv.context.getImageData(mouseX, mouseY, 1, 1).data
                    var hex = "#" + intToHex(a) + ("000000"+ rgbToHex(p[0], p[1], p[2])).slice(-6)
                    selectedColor = hex

                    colorIndicator.xDot = mouseX
                    colorIndicator.yDot = mouseY
                }

                onPressed: {
                    newColorPos()
                }
                onPositionChanged: {
                    if(pressed)
                        newColorPos()
                }
                onReleased: {
                    var blackColor = "#"+intToHex(a) + "000000"
                    if((selectedColorIndicator.color).toString().length == 7)
                        blackColor = "#000000"
                    if(selectedColorIndicator.color == blackColor){
                        colorIndicator.xDot = colorIndicator.width / 2
                        colorIndicator.yDot = colorIndicator.height / 2
                    }
                }
            }
        }
    }

    //For manual Adjustment via SpinBox or Slider
    ColorSlider {
        id: colorSliderRed
        anchors.top: centerPicker.bottom
        anchors.margins: 1
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width
        height: sliderHeight

        text: qsTr("RED")
        value: r
        onChanged: selectedColor = "#%1%2%3%4".arg(intToHex(a)).arg(intToHex(value)).arg(intToHex(g)).arg(intToHex(b))
    }

    ColorSlider {
        id: colorSliderGreen
        anchors.top: colorSliderRed.bottom
        anchors.margins: 1
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width
        height: sliderHeight

        text: qsTr("GREEN")

        color: "green"
        value: g
        onChanged: selectedColor = "#%1%2%3%4".arg(intToHex(a)).arg(intToHex(r)).arg(intToHex(value)).arg(intToHex(b))
    }

    ColorSlider {
        id: colorSliderBlue
        anchors.top: colorSliderGreen.bottom
        anchors.margins: 1
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width
        height: sliderHeight

        text: qsTr("BLUE")

        color: "blue"
        value: b
        onChanged:selectedColor = "#%1%2%3%4".arg(intToHex(a)).arg(intToHex(r)).arg(intToHex(g)).arg(intToHex(value))
    }

    ColorSlider {
        id: colorSliderAlpha
        anchors.top: colorSliderBlue.bottom
        anchors.margins: 1
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width
        height: sliderHeight

        text: "ALPHA"

        color: "grey"
        value: a
        onChanged: selectedColor = "#%1%2%3%4".arg(intToHex(value)).arg(intToHex(r)).arg(intToHex(g)).arg(intToHex(b))
    }

}
