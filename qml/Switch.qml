/****************************************************************************
**
** Copyright (C) 2015 QUIt Coding Ltd.
** Contact: info@quitcoding.com
**
** This file is part of Cinematic 3D, a Qt3D demo application.
**
** $QT_BEGIN_LICENSE:BSD$
** You may use this file under the terms of the BSD license as follows:
**
** "Redistribution and use in source and binary forms, with or without
** modification, are permitted provided that the following conditions are
** met:
**   * Redistributions of source code must retain the above copyright
**     notice, this list of conditions and the following disclaimer.
**   * Redistributions in binary form must reproduce the above copyright
**     notice, this list of conditions and the following disclaimer in
**     the documentation and/or other materials provided with the
**     distribution.
**   * Neither the name of The Qt Company Ltd nor the names of its
**     contributors may be used to endorse or promote products derived
**     from this software without specific prior written permission.
**
**
** THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
** "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
** LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
** A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
** OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
** SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
** LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
** DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
** THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
** (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
** OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE."
**
** $QT_END_LICENSE$
**
****************************************************************************/

import QtQuick 2.4

Item {
    id: root

    property alias text: textItem.text
    property bool checked: false
    property string textOn: qsTr("ON")
    property string textOff: qsTr("OFF")

    QtObject {
        id: priv
        property real switchWidth: 86 * dp
        property real barHeight: 25 * dp
        property real knobMovement: switchWidth - knobSize + 2
        property real knobSize: 32 * dp
        property real knobState: knob.x / knobMovement

        function releaseSwitch() {
            // Don't switch if we are already in that side
            if ((knob.x == -2 && !checked) || (knob.x == priv.knobMovement && checked)) {
                return;
            }
            checked = !checked;
        }
    }

    width: parent ? parent.width : 200 * dp
    height: 64 * dp

    MouseArea {
        width: parent.width
        height: parent.height
        onClicked: {
            root.checked = !root.checked;
        }
    }

    Text {
        id: textItem
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: 22 * dp
        anchors.right: switchBackgroundImage.left
        anchors.rightMargin: 8 * dp
        wrapMode: Text.WordWrap
        font.pixelSize: 20 * dp
        color: "#ffffff"
    }

    Rectangle {
        id: switchBackgroundImage
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        anchors.rightMargin: 32 * dp
        height: priv.barHeight
        width: priv.switchWidth
        radius: height/2
        color: "#404040"
    }
    Rectangle {
        id: switchFrameImage
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        anchors.rightMargin: 32 * dp
        height: priv.barHeight
        width: priv.switchWidth
        radius: height/2
        color: "transparent"
        border.width: 1 * dp
        border.color: "#808080"
        z: 2
    }

    Item {
        id: switchItem
        anchors.fill: switchBackgroundImage

        Text {
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: knob.left
            anchors.rightMargin: (priv.switchWidth - priv.knobSize - paintedWidth) / 2
            color: "#ffffff"
            font.pixelSize: 12 * dp
            text: textOn
        }
        Text {
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: knob.right
            anchors.leftMargin: (priv.switchWidth - priv.knobSize - paintedWidth - 6*dp) / 2
            color: "#808080"
            font.pixelSize: 12 * dp
            text: textOff
        }

        Item {
            id: knob
            anchors.verticalCenter: parent.verticalCenter
            height: priv.knobSize
            width: height
            x: checked ? priv.knobMovement : -2
            MouseArea {
                anchors.fill: parent
                drag.target: knob; drag.axis: Drag.XAxis; drag.minimumX: -2; drag.maximumX: priv.knobMovement
                onClicked: checked = !checked;
                onReleased: priv.releaseSwitch();
            }
            Behavior on x {
                NumberAnimation { duration: 250; easing.type: Easing.InOutQuad }
            }
        }
    }

    Rectangle {
        id: knobVisual
        property real colorValue: 0.6 + priv.knobState*0.4
        anchors.verticalCenter: parent.verticalCenter
        height: priv.knobSize
        width: height
        x: switchBackgroundImage.x + knob.x
        z: 10
        radius: height/2
        color: Qt.rgba(colorValue, colorValue, colorValue, 1.0)
        border.width: 1 * dp
        border.color: "#404040"
    }

    // Mask out switch parts which should be hidden
    ShaderEffect {
        id: shaderItem
        property variant source: ShaderEffectSource { sourceItem: switchItem; hideSource: true }
        property variant maskSource: ShaderEffectSource { sourceItem: switchBackgroundImage; hideSource: false }

        anchors.fill: switchBackgroundImage

        fragmentShader: "
            varying highp vec2 qt_TexCoord0;
            uniform highp float qt_Opacity;
            uniform sampler2D source;
            uniform sampler2D maskSource;
            void main(void) {
                gl_FragColor = texture2D(source, qt_TexCoord0.st) * (texture2D(maskSource, qt_TexCoord0.st).a) * qt_Opacity;
            }
        "
    }
}
