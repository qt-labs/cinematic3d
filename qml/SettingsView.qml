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

    anchors.fill: parent

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

    IconButton {
        id: settingsIcon
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        icon: "images/icons/settings.png"
        opacity: 0.5
        onClicked: {
            if (root.isOpen) {
                root.hide();
            } else {
                root.show();
            }
        }
    }

    BorderImage {
        id: backgroundItem
        anchors.left: settingsIcon.horizontalCenter
        anchors.bottom: settingsIcon.verticalCenter
        width: 340 * dp
        height: settingsContentColumn.height + 36
        source: "images/panel_bg.png"
        border.left : 22
        border.right : 10
        border.top : 5
        border.bottom : 26

        transformOrigin: Item.BottomLeft
        visible: opacity
        opacity: 0
        scale: 0.6

        Column {
            id: settingsContentColumn
            width: parent.width
            y: 8
            Switch {
                text: qsTr("Carousel Transparency")
                checked: settings.showCarouselOpacity
                onCheckedChanged: {
                    settings.showCarouselOpacity = checked;
                }
            }
            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width - 48 * dp
                height: 1
                color: "#808080"
            }
            Switch {
                text: qsTr("3D Reflections")
                checked: settings.show3DReflections
                onCheckedChanged: {
                    settings.show3DReflections = checked;
                }
            }
            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width - 48 * dp
                height: 1
                color: "#808080"
            }
            Switch {
                text: qsTr("3D Background")
                textOff: qsTr("SKY")
                textOn: qsTr("STARS")
                checked: settings.starsBackground
                onCheckedChanged: {
                    settings.starsBackground = checked;
                }
            }
            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width - 48 * dp
                height: 1
                color: "#808080"
            }
            Switch {
                text: qsTr("Slow Transitions")
                checked: settings.slowAnimations
                onCheckedChanged: {
                    settings.slowAnimations = checked;
                }
            }
            Switch {
                text: qsTr("Show fps")
                checked: settings.showFps
                onCheckedChanged: {
                    settings.showFps = checked;
                }
            }
        }
    }
}
