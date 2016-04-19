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
    id: entity

    property real showDetailsTransitionState: 0.0
    property real waviness: showDetailsTransitionState * 0.5
    property url coverImage
    property bool visible: true
    property matrix4x4 cameraMatrix
    property TextureCubeMap cubemapTexture
    property vector3d cameraPosition
    property bool envMapping: true

    EnvMappedWavyGLES2ShaderProgram {
        id: envMappedWavyShaderProgram
    }

    TexturedWavyShaderProgram {
        id: texturedWavyShaderProgram
    }

    Material {
        id: material

        effect: Effect {
            id: fx

            property real wave: 0
            QQ2.NumberAnimation on wave {
                from: 0
                to: 2 * Math.PI
                loops: QQ2.Animation.Infinite
                duration: 3500
            }

            Parameter { id: cubemapParam; name: "skyboxTexture"; value: cubemapTexture }
            Parameter { id: waveParam; name: "wave"; value: fx.wave }
            Parameter { id: wavinessParam; name: "waviness"; value: entity.waviness }
            Parameter { id: coverTextureParam; name: "coverTexture"; value: MipMappedTexture2D { source: coverImage } }
            Parameter { id: cameraPositionParam; name: "cameraPosition"; value: cameraPosition }

            parameters: [cubemapParam, waveParam, wavinessParam, coverTextureParam, cameraPositionParam];

            techniques: [
                Technique {
                    graphicsApiFilter {
                        api: GraphicsApiFilter.OpenGL
                        profile: GraphicsApiFilter.NoProfile
                        majorVersion: 2
                        minorVersion: 0
                    }

                    renderPasses: RenderPass {
                        renderStates: [
                            CullFace { mode: CullFace.Back },
                            DepthTest { depthFunction: DepthTest.LessOrEqual }
                        ]

                        shaderProgram: envMapping ? envMappedWavyShaderProgram : texturedWavyShaderProgram
                    }
                },
                Technique {
                    graphicsApiFilter {
                        api: GraphicsApiFilter.OpenGLES
                        profile: GraphicsApiFilter.NoProfile
                        majorVersion: 2
                        minorVersion: 0
                    }

                    renderPasses: RenderPass {
                        renderStates: [
                            CullFace { mode: CullFace.Back },
                            DepthTest { depthFunction: DepthTest.LessOrEqual }
                        ]

                        shaderProgram: envMapping ? envMappedWavyShaderProgram : texturedWavyShaderProgram
                    }
                }
            ]
        }
    }

    Transform {
        id: modelTransform
        matrix: {
            var m = cameraMatrix.inverted();
            m.translate(Qt.vector3d(0.0,
                                    -1.5 + (1.5 * showDetailsTransitionState),
                                    -40));
            m.rotate(40 * Math.min(1.0, showDetailsTransitionState * 1.5), Qt.vector3d(0, 1, 0));
            m.translate(Qt.vector3d(-25 * Math.max(0, showDetailsTransitionState - 0.4),
                                    0.0,
                                    0.0));
            return m;
        }
    }

    CuboidMesh {
        id: mesh
        property real multiplier: 0.0256
        xExtent: 512 * multiplier
        yExtent: 768 * multiplier
        zExtent: 2.0
        yzMeshResolution: Qt.size(20, 20)
        xzMeshResolution: Qt.size(20, 20)
        xyMeshResolution: Qt.size(20, 20)
    }

    components: visible ? [modelTransform, mesh, material] : []
}
