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

    property bool isOpen: false

    anchors.fill: parent

    function show() {
        isOpen = true;
        hideAnimation.stop();
        showAnimation.restart();
    }
    function hide() {
        isOpen = false;
        showAnimation.stop();
        hideAnimation.restart();
    }

    ParallelAnimation {
        id: showAnimation
        NumberAnimation { target: backgroundItem; property: "opacity"; to: 1; duration: 250; easing.type: Easing.InOutQuad }
        NumberAnimation { target: backgroundItem; property: "scale"; to: 1; duration: 500; easing.type: Easing.OutBack }
    }
    ParallelAnimation {
        id: hideAnimation
        NumberAnimation { target: backgroundItem; property: "opacity"; to: 0; duration: 500; easing.type: Easing.InOutQuad }
        NumberAnimation { target: backgroundItem; property: "scale"; to: 0.6; duration: 500; easing.type: Easing.InOutQuad }
    }

    MouseArea {
        anchors.fill: parent
        enabled: root.isOpen
        onClicked: {
            root.hide();
        }
    }

    Item {
        id: toolbar
        anchors.right: parent.right
        width: 200 * dp
        height: 60 * dp

        Image {
            id: infoButton
            anchors.right: parent.right
            anchors.rightMargin: -10 * dp
            anchors.verticalCenter: parent.verticalCenter
            width: 86 * dp
            height: 86 * dp
            fillMode: Image.PreserveAspectFit
            smooth: true
            source: "images/icons/info.png"
            opacity: mouseArea.pressed || root.isOpen ? 1.0 : 0.5
            Behavior on opacity {
                NumberAnimation {
                    duration: 200
                    easing.type: Easing.InOutQuad
                }
            }
        }
        Image {
            id: qtLogo
            anchors.right: infoButton.left
            anchors.rightMargin: -10 * dp
            anchors.verticalCenter: parent.verticalCenter
            width: 40 * dp
            height:  40 * dp
            fillMode: Image.PreserveAspectFit
            smooth: true
            source: "images/qt_logo_small.png"
            opacity: 0.5
        }
        Image {
            id: quitLogo
            anchors.right: qtLogo.left
            anchors.verticalCenter: parent.verticalCenter
            width: 100 * dp
            height:  40 * dp
            fillMode: Image.PreserveAspectFit
            smooth: true
            source: "images/quit_logo_small.png"
            opacity: 0.5
        }

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            onClicked: {
                if (root.isOpen) {
                    root.hide();
                } else {
                    root.show();
                }
            }
        }
    }

    BorderImage {
        id: backgroundItem
        anchors.right: parent.right
        anchors.rightMargin: 25 * dp
        anchors.top: toolbar.verticalCenter
        anchors.topMargin: 10 * dp
        width: 440 * dp
        height: root.height - 80 * dp
        source: "images/panel2_bg.png"
        border.right : 22
        border.left : 10
        border.bottom : 5
        border.top : 26
        transformOrigin: Item.TopRight
        visible: opacity
        opacity: 0
        scale: 0.6

        Flickable {
            id: flickableArea
            anchors.fill: parent
            anchors.topMargin: backgroundItem.border.top
            anchors.bottomMargin:backgroundItem.border.bottom
            contentHeight: infoContentItem.height
            contentWidth: width
            clip: true
            Column {
                id: infoContentItem
                // Comes from BorderImage + margin
                width: parent.width - 20 - 20 * dp
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.horizontalCenterOffset: 2
                spacing: 30 * dp
                Item {
                    width: 1
                    height: 40 * dp
                }
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    font.pixelSize: 30 * dp
                    style: Text.Outline
                    font.bold: true
                    color: "#e0e0e0"
                    styleColor: "#202020"
                    text: qsTr("Cinematic 3D")
                }
                Text {
                    width: parent.width
                    wrapMode: Text.WordWrap
                    font.pixelSize: 24 * dp
                    style: Text.Outline
                    color: "#e0e0e0"
                    styleColor: "#202020"
                    textFormat: Text.StyledText
                    text: qsTr("This application is built using Qt - the cross-platform application and UI framework. It shows the 3D UI capabilities introduced with Qt 5.5.<br><br>The implementation highlights the new Qt 3D module, together with the Qt Quick and the Qt Multimedia modules.")
                }
                Image {
                    width: parent.width
                    height: width * 0.5
                    fillMode: Image.PreserveAspectCrop
                    source: "images/info_sc1.png"
                    smooth: true
                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: -1
                        z: -1
                        color: "#808080"
                    }
                }
                Text {
                    width: parent.width
                    wrapMode: Text.WordWrap
                    font.pixelSize: 24 * dp
                    style: Text.Outline
                    color: "#e0e0e0"
                    styleColor: "#202020"
                    textFormat: Text.StyledText
                    text: qsTr("<b>Qt 3D</b> is a new addition included as a technology preview in Qt 5.5 which allows binging true 3D elements into UIs built with Qt Quick. Qt 3D offers both QML and C++ APIs. In this demo Qt 3D is used for the skybox background and for some elements of video details view. Qt 3D also supports property animations which are used for implementing the transition effects.")
                }
                Image {
                    width: parent.width
                    height: width * 0.5
                    fillMode: Image.PreserveAspectCrop
                    source: "images/info_sc2.png"
                    smooth: true
                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: -1
                        z: -1
                        color: "#808080"
                    }
                }
                Text {
                    width: parent.width
                    wrapMode: Text.WordWrap
                    font.pixelSize: 24 * dp
                    style: Text.Outline
                    color: "#e0e0e0"
                    styleColor: "#202020"
                    textFormat: Text.StyledText
                    text: qsTr("<b>Qt Quick</b> is used to create the actual UI and all the interactions. The carousel is implemented with Qt Quick by blending it using a ShaderEffect with 3D elements. Qt Quick is powered by the Qt Quick Engine that has been optimized and improved with Qt 5.5. This demo has no custom C++ code, but everything has been implemented using QML and JavaScript.")
                }
                Image {
                    width: parent.width
                    height: width * 0.5
                    fillMode: Image.PreserveAspectCrop
                    source: "images/info_sc3.png"
                    smooth: true
                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: -1
                        z: -1
                        color: "#808080"
                    }
                }
                Text {
                    width: parent.width
                    wrapMode: Text.WordWrap
                    font.pixelSize: 24 * dp
                    style: Text.Outline
                    color: "#e0e0e0"
                    styleColor: "#202020"
                    textFormat: Text.StyledText
                    text: qsTr("<b>Qt Multimedia</b> handles the playback of the videos.")
                }
                Image {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: parent.width * 0.6
                    height: width * 0.3
                    fillMode: Image.PreserveAspectFit
                    source: "images/info_sc4.png"
                    smooth: true
                }
                Text {
                    width: parent.width
                    wrapMode: Text.WordWrap
                    font.pixelSize: 14 * dp
                    style: Text.Outline
                    color: "#e0e0e0"
                    styleColor: "#202020"
                    textFormat: Text.StyledText
                    horizontalAlignment: Text.AlignHCenter
                    text: qsTr("This demo is built in co-operation between<br><b>QUIt Coding</b> and <b>The Qt Company</b>.<br><br>Enjoy the power of Qt 5.5!<br><br>Try it out, or learn more, visit <i>http://www.qt.io</i>")
                }
                Item {
                    width: 1
                    height: 40 * dp
                }
            }
        }

        // Smoothly clip top & bottom of flickable content
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
    }
}

