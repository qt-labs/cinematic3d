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
import QtQuick.Window 2.2
import QtQuick.Scene3D 2.0

Window {
    id: window

    // Scaling factor
    property real dp: width / 960
    // True when video player should be loaded
    property bool videoOn: false
    // True when playing video
    property bool viewingVideo: false
    // Filename of currently selected video
    property string videoFile: ""
    // Current carousel item offset
    property real carouselOffset: 0.0

    width: 960
    height: 600
    visible: true
    color: "#000000"

    // These are controlled from SettingsView
    QtObject {
        id: settings
        property bool showCarouselOpacity: true
        property bool show3DReflections: true
        property bool starsBackground: true
        property bool showFps: false
        property bool slowAnimations: false
    }

    // Qt3D view
    Scene3D {
        id: scene3D
        anchors.fill: parent
        opacity: 0
        Component.onCompleted: startupShowAnimation.start()
        Cinematic3DScene {
            id: cinematic3DScene
            coverImage: carouselView.selectedCoverImage.length > 0 ? carouselView.selectedCoverImage : "images/covers/Build_Your_World.jpg"
        }
    }

    // Video details view
    DetailsView {
        id: detailsView
        anchors.fill: parent
        opacity: cinematic3DScene.showDetailsTransitionState * (1 - cinematic3DScene.showVideoTransitionState * 2.0)
        // Set initial cover image
        imageName: "Build_Your_World"
        onBackButtonClicked: {
            if (cinematic3DScene.showCover) {
                showDetailsView.stop();
                hideDetailsView.start();
            }
        }
    }

    // Video carousel view
    CarouselView {
        id: carouselView
        anchors.verticalCenter: parent.verticalCenter
        carouselInteractive: !cinematic3DScene.showCover
        opacity: 0
        visible: opacity
    }

    // Top-left corner fps item
    FpsItem {
        anchors.left: parent.left
        anchors.top: parent.top
        visible: settings.showFps
    }

    // Top-right corner info view
    InfoView {
        id: infoView
        anchors.right: parent.right
        anchors.top: parent.top
    }

    // Bottom-left corner settings view
    SettingsView {
        id: settingsView
    }

    // Video playback loader view
    Loader {
        id: playerViewLoader
        anchors.fill: parent
        source: "PlayerView.qml"
        opacity: 0
        visible: opacity
        // Load video component only as needed
        active: videoOn
    }

    // Start -> CarouseView animation
    SequentialAnimation {
        id: startupShowAnimation
        PauseAnimation {
            duration: 1000
        }
        NumberAnimation {
            target: carouselView
            property: "opacity"
            to: 1
            duration: 500
            easing.type: Easing.InOutQuad
        }
        NumberAnimation {
            target: scene3D
            property: "opacity"
            to: 1
            duration: 500
            easing.type: Easing.InOutQuad
        }
    }

    // CarouseView <-> DetailsView animations
    SequentialAnimation {
        id: showDetailsView

        PropertyAction {
            target: cinematic3DScene
            property: "showCover"
            value: true
        }

        NumberAnimation {
            target: carouselView
            property: "opacity"
            to: 0
            duration: 300 + settings.slowAnimations*1000
            easing.type: Easing.InOutQuad
        }

        NumberAnimation {
            target: cinematic3DScene
            property: "showDetailsTransitionState"
            to: 1.0
            duration: 500 + settings.slowAnimations*1000
            easing.type: Easing.InOutQuad
        }
    }

    SequentialAnimation {
        id: hideDetailsView

        NumberAnimation {
            target: cinematic3DScene
            property: "showDetailsTransitionState"
            to: 0.0
            duration: 300 + settings.slowAnimations*1000
            easing.type: Easing.InOutQuad
        }

        NumberAnimation {
            target: carouselView
            property: "opacity"
            to: 1.0
            duration: 500 + settings.slowAnimations*1000
            easing.type: Easing.InOutQuad
        }

        PropertyAction {
            target: cinematic3DScene
            property: "showCover"
            value: false
        }
    }

    // DetailsView <-> Video animations
    SequentialAnimation {
        id: showVideo

        NumberAnimation {
            target: cinematic3DScene
            property: "showVideoTransitionState"
            to: 1.0
            duration: 1000 + settings.slowAnimations*3000
            easing.type: Easing.InOutQuad
        }

        PropertyAction {
            target: window
            property: "videoOn"
            value: true
        }

        NumberAnimation {
            target: playerViewLoader
            property: "opacity"
            to: 1.0
            duration: 1000 + settings.slowAnimations*1500
            easing.type: Easing.InOutQuad
        }

        PropertyAction {
            target: window
            property: "viewingVideo"
            value: true
        }
    }

    SequentialAnimation {
        id: hideVideo

        NumberAnimation {
            target: playerViewLoader
            property: "opacity"
            to: 0.0
            duration: 1000 + settings.slowAnimations*1000
            easing.type: Easing.InOutQuad
        }

        PropertyAction {
            target: window
            property: "videoOn"
            value: false
        }

        NumberAnimation {
            target: cinematic3DScene
            property: "showVideoTransitionState"
            to: 0.0
            duration: 1200 + settings.slowAnimations*3000
            easing.type: Easing.InOutQuad
        }

        PropertyAction {
            target: window
            property: "viewingVideo"
            value: false
        }
    }
}
