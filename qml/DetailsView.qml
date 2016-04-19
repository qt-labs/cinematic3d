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

    property string title
    property string description
    property string imageName

    signal backButtonClicked

    IconButton {
        id: backButton
        anchors.left: parent.left
        anchors.leftMargin: 20 * dp
        anchors.top: parent.top
        anchors.topMargin: 20 * dp
        icon: "images/icons/back.png"
        onClicked: {
            root.backButtonClicked()
        }
    }

    Text {
        id: labelTextItem
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 20 * dp
        font.pixelSize: 40 * dp
        color: "#ffffff"
        text: root.title
    }

    Item {
        anchors.fill: parent
        anchors.margins: 20 * dp
        anchors.leftMargin: parent.width/2 + 20 * dp
        anchors.topMargin: 80 * dp
        opacity: 2 * (parent.opacity - 0.5)

        Flickable {
            id: flickableArea
            anchors.fill: parent
            anchors.bottomMargin: 80 * dp
            contentHeight: textItem.paintedHeight
            contentWidth: width
            clip: true
            topMargin: 80 * dp
            bottomMargin: 80 * dp
            Text {
                id: textItem
                width: parent.width - 20 * dp
                anchors.horizontalCenter: parent.horizontalCenter
                wrapMode: Text.WordWrap
                font.pixelSize: 24 * dp
                style: Text.Outline
                color: "#e0e0e0"
                styleColor: "#202020"
                text: root.description
            }
        }

        ShaderEffectSource {
            id: flickableAreaSource
            sourceItem: flickableArea
            hideSource: true
            visible: false
        }
        ShaderEffect {
            property variant src: flickableAreaSource

            anchors.fill: flickableArea

            fragmentShader: "
                varying highp vec2 qt_TexCoord0;
                uniform lowp float qt_Opacity;
                uniform sampler2D src;
                void main() {
                    lowp vec4 tex = texture2D(src, qt_TexCoord0);
                    lowp float dist = abs(qt_TexCoord0.y-0.5)*4.0;
                    tex*= min(1.0, (2.0 - dist));
                    gl_FragColor = tex * qt_Opacity;
                }"
        }

        Text {
            anchors.horizontalCenter: playButton.horizontalCenter
            anchors.top: playButton.bottom
            font.pixelSize: 16 * dp
            color: "#ffffff"
            text: qsTr("PLAY")
        }
        IconButton {
            id: playButton
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 20 * dp
            icon: "images/icons/play.png"
            onClicked: {
                showVideo.start();
            }
        }
    }
}

