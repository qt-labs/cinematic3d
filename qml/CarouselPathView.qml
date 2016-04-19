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
import QtQuick.XmlListModel 2.0

PathView {
    id: pathView

    property string name: currentItem ? currentItem.name : ""
    property string description: currentItem ? currentItem.description : ""

    anchors.fill: parent
    anchors.leftMargin: -itemWidth * 0.5
    anchors.rightMargin: -itemWidth * 0.5
    highlightRangeMode: ListView.StrictlyEnforceRange
    preferredHighlightBegin: 0.5
    preferredHighlightEnd: 0.5
    snapMode: PathView.SnapToItem
    maximumFlickVelocity: 3000 * dp
    pathItemCount: 5
    model: moviesModel
    path: Path {
        startX: 0
        startY: pathView.height / 2
        PathLine {
            relativeX: pathView.width
            relativeY: 0
        }
    }
    delegate: Item {
        property string name: model.name
        property string description: model.description
        property bool selected: pathView.currentIndex == index
        property real fadeAnimationState:  selected ? 0 : (1 - carouselView.opacity)

        onSelectedChanged: {
            if (selected)
                root.selectedCoverImage = coverImage.source;
        }
        transform: Translate {
            y: fadeAnimationState * carouselView.height
        }

        width: itemWidth
        height: itemHeight
        Rectangle {
            anchors.fill: parent
            anchors.margins: 2
            color: selected ? "#ffffff" : "#000000"
            opacity: selected ? 0.8 : 0.4
            radius: width * 0.05
            Behavior on opacity {
                NumberAnimation {
                    duration: 400
                    easing.type: Easing.InOutQuad
                }
            }
            Behavior on color {
                ColorAnimation {
                    duration: 400
                }
            }
        }
        Rectangle {
            anchors.fill: coverImage
            anchors.margins: -1 * dp
            opacity: 0.6
            color: "#606060"
        }

        Image {
            id: coverImage
            width: parent.width * 0.9
            height: width * 3/2
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: parent.width * 0.05
            source: "images/covers/" + model.image + ".jpg"
        }
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: parent.height * 0.08 - paintedHeight * 0.4
            width: parent.width * 0.9
            horizontalAlignment: Text.AlignHCenter
            fontSizeMode: Text.HorizontalFit
            minimumPixelSize: 18*dp
            font.pixelSize: 24*dp
            elide: Text.ElideRight
            color: selected ? "#606060" : "#808080"
            text: model.name
        }
        MouseArea {
            anchors.fill: parent
            enabled: carouselInteractive
            onClicked: {
                if (pathView.currentIndex === index) {
                    // Setup and open details view
                    videoFile = model.video;
                    detailsView.title = model.name;
                    detailsView.description = model.description;
                    detailsView.imageName = model.image;
                    hideDetailsView.stop();
                    showDetailsView.start();
                } else {
                    // Select the clicked item
                    pathView.currentIndex = index;
                }
            }
        }
    }

    XmlListModel {
        id: moviesModel
        source: "Cinematic3D_videos.xml"
        query: "/videolist/item"
        XmlRole  { name: "image"; query: "thumbnail/string()" }
        XmlRole { name: "name"; query: "title/string()" }
        XmlRole { name: "description"; query: "description/string()" }
        XmlRole { name: "video"; query: "link/string()" }

        onStatusChanged: {
            if (status == XmlListModel.Ready) {
                // TODO: Show carousel only once loaded?
            } else if (status == XmlListModel.Error) {
                console.debug("Error loading XML model");
            }
        }
    }
}
