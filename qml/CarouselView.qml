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

    property real itemHeight: itemWidth * 1.65
    property real itemWidth: width * 0.25

    property string selectedCoverImage
    property alias carouselMoving: pathView.moving
    property alias carouselInteractive: pathView.interactive

    width: parent.width
    height: parent.height

    CarouselPathView {
        id: pathView

        property real prevOffset: 0
        onOffsetChanged: {
            var delta = offset - prevOffset;
            if (delta > 1)
                delta -= pathView.count;
            else if (delta < -1)
                delta += pathView.count;
            window.carouselOffset += delta;
            prevOffset = offset;
        }
    }

    ShaderEffectSource {
        id: pathViewSource
        sourceItem: pathView
        hideSource: true
        visible: false
    }
    ShaderEffect {
        property variant src: pathViewSource
        property real highlightAnimation: highlightAnimation2 * highlightAnimation3
        property real highlightAnimation2: 1.0
        property real highlightAnimation3: 1.0
        property real showCarouselOpacity : settings.showCarouselOpacity
        Behavior on showCarouselOpacity {
            NumberAnimation {
                duration: 400
                easing.type: Easing.InOutQuad
            }
        }
        SequentialAnimation on highlightAnimation2 {
            loops: Animation.Infinite
            NumberAnimation {
                to: 1.1
                duration: 1800
                easing.type: Easing.InOutQuad
            }
            NumberAnimation {
                to: 1.0
                duration: 1100
                easing.type: Easing.InOutQuad
            }
        }
        SequentialAnimation on highlightAnimation3 {
            loops: Animation.Infinite
            NumberAnimation {
                to: 1.04
                duration: 1100
                easing.type: Easing.InElastic
            }
            NumberAnimation {
                to: 1.0
                duration: 2400
                easing.type: Easing.OutElastic
            }
        }

        anchors.fill: pathView
        mesh: GridMesh {
            resolution: Qt.size(32, 16)
        }
        vertexShader: "
            uniform highp mat4 qt_Matrix;
            attribute highp vec4 qt_Vertex;
            attribute highp vec2 qt_MultiTexCoord0;
            varying highp vec2 coord;
            uniform highp float highlightAnimation;
            void main() {
                lowp float PI = 3.14159265;
                highp float posy = 0.8 * qt_MultiTexCoord0.y + (0.2*qt_MultiTexCoord0.y) * sin(qt_MultiTexCoord0.x*PI);
                coord = vec2(qt_MultiTexCoord0.x, posy);
                gl_Position = qt_Matrix * qt_Vertex;
            }"
        fragmentShader: "
            varying highp vec2 coord;
            uniform sampler2D src;
            uniform lowp float qt_Opacity;
            uniform lowp float highlightAnimation;
            uniform lowp float showCarouselOpacity;
            void main() {
                lowp vec4 tex = texture2D(src, coord);
                lowp float dist = abs(coord.x-0.5)*2.0;
                // Opacity
                lowp vec4 gray = vec4((tex.r + tex.g + tex.b) / 3.0);
                tex = mix(tex, gray, dist*1.5*showCarouselOpacity);
                // Shadow
                tex.rgb *= (1.2*highlightAnimation - dist*1.2);
                gl_FragColor = tex * qt_Opacity;
            }"
    }
}

