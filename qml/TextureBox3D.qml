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
    property url coverImage1
    property url coverImage2
    property url coverImage3
    property url coverImage4
    property bool visible: true
    property matrix4x4 cameraMatrix
    property TextureCubeMap cubemapTexture
    property real size: 1
    property vector3d cameraPosition
    property bool envMapping: true

    EnvMappedBoxGLES2ShaderProgram {
        id: envMappedBoxShaderProgram
    }

    TexturedBoxGLES2ShaderProgram {
        id: texturedBoxShaderProgram
    }

    Material {
        id: material

        effect: Effect {
            id: fx

            Parameter { id: p1; name: "skyboxTexture"; value: cubemapTexture }
            Parameter { id: ptex1; name: "tex1"; value: MipMappedTexture2D { source: coverImage1 } }
            Parameter { id: ptex2; name: "tex2"; value: MipMappedTexture2D { source: coverImage2 } }
            Parameter { id: ptex3; name: "tex3"; value: MipMappedTexture2D { source: coverImage3 } }
            Parameter { id: ptex4; name: "tex4"; value: MipMappedTexture2D { source: coverImage4 } }
            Parameter { id: cameraPositionParam; name: "cameraPosition"; value: cameraPosition }

            parameters: [p1, ptex1, ptex2, ptex3, ptex4, cameraPositionParam]

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

                        shaderProgram: envMapping ? envMappedBoxShaderProgram : texturedBoxShaderProgram
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

                        shaderProgram: envMapping ? envMappedBoxShaderProgram : texturedBoxShaderProgram
                    }
                }
            ]
        }
    }

    Transform {
        id: modelTransform

        property real angle: 0
        QQ2.NumberAnimation on angle {
            from: 0
            to: 360
            loops: QQ2.Animation.Infinite
            duration: 8000
            running: true
        }
        matrix: {
            var m = cameraMatrix.inverted();
            m.translate(Qt.vector3d(6,
                                    -4 - (1.0 - showDetailsTransitionState) * 10,
                                    -20 * showDetailsTransitionState));
            m.rotate(modelTransform.angle, Qt.vector3d(0, 1, 0));
            m.rotate(15, Qt.vector3d(0, 0, 1));
            return m;
        }
    }

    CuboidMesh {
        id: mesh
        xExtent: size
        yExtent: 0.5625 * size
        zExtent: size
        yzMeshResolution: Qt.size(2, 2)
        xzMeshResolution: Qt.size(2, 2)
        xyMeshResolution: Qt.size(2, 2)
    }

    components: visible ? [modelTransform, mesh, material] : []
}
