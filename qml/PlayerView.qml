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
import QtMultimedia 5.5

Rectangle {
    id: root

    // The directory of videos
    // Note: videoPath is defined in main.cpp
    property string videosDir: videoPath
    // The video which is currently loaded
    property string playingVideo: videosDir + videoFile
    // TODO: Will provided videos require zoomed mode or not to fit the screen?
    property bool videoZoomed: false
    // How long (in ms) the controls are visible
    property int controlsHideTime: 4000
    // How much (in ms) the forward & rewind buttons seek
    property int seekAmount: 2500

    function restartHideTimer() {
        root.state = "controlsVisible";
        hideControlsTimer.restart();
    }

    function mediaStatusToString(status) {
        switch (status) {
        case MediaPlayer.NoMedia:
            return "NoMedia";
        case MediaPlayer.Loading:
            return "Loading";
        case MediaPlayer.Loaded:
            return "Loaded";
        case MediaPlayer.Buffering:
            return "Buffering";
        case MediaPlayer.Stalled:
            return "Stalled";
        case MediaPlayer.Buffered:
            return "Buffered";
        case MediaPlayer.EndOfMedia:
            return "EndOfMedia";
        case MediaPlayer.InvalidMedia:
            return "InvalidMedia";
        case MediaPlayer.UnknownStatus:
            return "UnknownStatus";
        default:
            return "???"
        }
    }

    function msToTimeString(ms) {
        var totalSec = Math.floor(ms / 1000);
        var min = Math.floor(totalSec / 60);
        var sec = totalSec - min*60;
        if (min <= 9) min = "0" + min;
        if (sec <= 9) sec = "0" + sec;
        return min + ":" + sec;
    }

    onVisibleChanged: {
        if (visible) {
            state = "controlsVisible";
            hideControlsTimer.restart();
            video.play();
        } else {
            if (videoFile != "") {
                video.stop();
            }
        }
    }

    anchors.fill: parent
    color: "#000000"

    states: [
        State {
            name: "controlsVisible"
            PropertyChanges { target: topBar; opacity: 0.8 }
            PropertyChanges { target: bottomBar; anchors.bottomMargin: 0; opacity: 0.8 }
        }
    ]

    transitions: [
        Transition {
            PropertyAnimation {
                targets: [topBar, bottomBar]
                properties: "anchors.topMargin, anchors.bottomMargin, opacity"
                easing.type: Easing.InOutQuad
                duration: 500
            }
        }
    ]

    Timer {
        id: hideControlsTimer
        interval: root.controlsHideTime
        running: true
        onTriggered: {
            root.state = "";
        }
    }

    Video {
        id: video
        property string statusString
        property string playbackStateString

        anchors.fill: parent
        fillMode: videoZoomed ? VideoOutput.PreserveAspectCrop : VideoOutput.PreserveAspectFit
        source: playingVideo != videosDir ? playingVideo : ""
        autoPlay: true
        onStatusChanged: {
            console.debug("playingVideo: " + playingVideo);
            playbackStateString = mediaStatusToString(status);
            console.debug("video status: " + playbackStateString);
            if (status == MediaPlayer.EndOfMedia) {
                hideVideo.start();
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            restartHideTimer();
        }
    }

    Item {
        id: topBar
        width: parent.width
        height: parent.height * 0.15
        anchors.top: parent.top
        opacity: 0
        visible: opacity
        // top-left back button
        IconButton {
            id: backButton
            anchors.left: parent.left
            anchors.leftMargin: 20 * dp
            anchors.top: parent.top
            anchors.topMargin: 20 * dp
            icon: "images/icons/back.png"
            onClicked: {
                video.pause();
                hideVideo.start();
            }
        }
    }

    Rectangle {
        id: bottomBar
        width: parent.width * 0.6
        height: parent.height * 0.24
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: -height
        color: "#202020"
        opacity: 0
        visible: opacity
        // Control buttons row
        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: 10 * dp
            height: 80 * dp
            spacing: 30
            IconButton {
                anchors.verticalCenter: parent.verticalCenter
                icon: "images/icons/rewind.png"
                onClicked: {
                    restartHideTimer();
                    video.seek(video.position - seekAmount);
                }
            }
            IconButton {
                anchors.verticalCenter: parent.verticalCenter
                icon: video.playbackState ===  MediaPlayer.PlayingState ? "images/icons/pause.png" : "images/icons/play.png"
                onClicked: {
                    restartHideTimer();
                    if (video.playbackState ===  MediaPlayer.PlayingState) {
                        video.pause();
                    } else {
                        video.play();
                    }
                }
            }
            IconButton {
                anchors.verticalCenter: parent.verticalCenter
                icon: "images/icons/fastforward.png"
                onClicked: {
                    restartHideTimer();
                    video.seek(Math.min(video.duration, video.position + seekAmount));
                }
            }
        }

        // Video duration bar
        Rectangle {
            anchors.top: parent.top
            width: parent.width
            height: 2
            color: "#606060"
            Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                width:  (parent.width) * (video.position / video.duration)
                height: 8 * dp
                color: "#909090"
                Rectangle {
                    anchors.left: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    width: 2 * dp
                    height: parent.height
                    color: "#ffffff"
                }
            }
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: 10 * dp
            font.pixelSize: 20 * dp
            color: "#d0d0d0"
            text: msToTimeString(video.position) + " / " + msToTimeString(video.duration)
        }
    }
}
