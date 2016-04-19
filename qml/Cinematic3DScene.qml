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

import Qt3D.Core 2.0
import Qt3D.Render 2.0
import QtQuick 2.4 as QQ2

Entity {
    id: root

    property alias coverImage: cover.coverImage
    property real showDetailsTransitionState: 0.0
    property real showVideoTransitionState: 0.0
    property bool showCover: false
    property vector3d cameraPosition: fullCameraTransform.matrix.inverted().times(Qt.vector3d(0,0,0))

    RenderSettings {
        activeFrameGraph: ForwardRenderer {
            camera: mainCamera
            clearColor: "black"
        }
    }

    Camera {
        id: mainCamera
        projectionType: CameraLens.PerspectiveProjection
        // Scale the 3D view exactly as the carousel view
        fieldOfView: 2 * Math.atan(0.5 * 1.5 * window.height / window.width) * 180 / Math.PI
        aspectRatio: window.width / window.height
        nearPlane:   0.01
        farPlane:    1000.0

        // Animate camera roll and yaw
        property real roll: 0
        QQ2.SequentialAnimation on roll {
            loops: QQ2.Animation.Infinite
            QQ2.NumberAnimation {
                from: -1
                to: 1
                duration: 4000
                easing.type: Easing.InOutSine
            }
            QQ2.NumberAnimation {
                from: 1
                to: -1
                duration: 4000
                easing.type: Easing.InOutSine
            }
        }

        property real yaw: 0
        QQ2.NumberAnimation on yaw {
            from: 0
            to: -2 * Math.PI
            duration: 60000
            loops: QQ2.Animation.Infinite
        }

        Transform {
            id: cameraRotationTransform
            matrix: {
                var m = Qt.matrix4x4();
                m.rotate(-19 * window.carouselOffset, Qt.vector3d(0.0, 1.0, 0.0));
                m.rotate(5 * mainCamera.roll, Qt.vector3d(0.0, 0.0, 1.0));
                m.lookAt(Qt.vector3d( 0.0, 0.0, 0.0 ),
                         Qt.vector3d(-40 * Math.sin(mainCamera.yaw), mainCamera.roll * 3, -40 * Math.cos(mainCamera.yaw) ),
                         Qt.vector3d( 0.0, 1.0, 0.0 ));
                return m;
            }
        }

        components: [
            Transform {
                id: fullCameraTransform
                matrix: {
                    // Rotates the camera together with the objects
                    var m = Qt.matrix4x4();
                    m.rotate(90 * showVideoTransitionState * (viewingVideo ? -1 : 1), Qt.vector3d(0.0, 1.0, 0.0));
                    // Moving the camera relative to the objects
                    // Used in the video view transitions
                    m.translate(Qt.vector3d(0, 0, 50 * showVideoTransitionState * (viewingVideo ? -1 : 1)));
                    m = m.times(cameraRotationTransform.matrix);
                    return m;
                }

            }
        ]
    }

    BackgroundCubeMap {
        id: sky
        // Keep the camera always in the center of the skybox
        cameraPosition: root.cameraPosition
        cubemapIndex: settings.starsBackground ? 0 : 1
    }

    Cover3D {
        id: cover
        showDetailsTransitionState: root.showDetailsTransitionState
        cameraMatrix: cameraRotationTransform.matrix
        cameraPosition: root.cameraPosition
        visible: showCover
        envMapping: settings.show3DReflections
        cubemapTexture: sky.cubemapTexture
    }

    TextureBox3D {
        id: screenshotBox

        property string imagePath: "/qml/images/shots/"

        coverImage1: imagePath + detailsView.imageName + "_1.jpg"
        coverImage2: imagePath + detailsView.imageName + "_2.jpg"
        coverImage3: imagePath + detailsView.imageName + "_3.jpg"
        coverImage4: imagePath + detailsView.imageName + "_4.jpg"
        cameraMatrix: cameraRotationTransform.matrix
        showDetailsTransitionState: root.showDetailsTransitionState
        visible: showCover
        cubemapTexture: sky.cubemapTexture
        size: 9
        envMapping: settings.show3DReflections
    }

    Sphere3D {
        id: videoSphere
        cameraMatrix: cameraRotationTransform.matrix
        cameraPosition: root.cameraPosition
        surface: "images/planet.png"
        envMapping: settings.show3DReflections
        size: 14
    }
}

