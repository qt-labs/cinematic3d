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

Entity {
    id: entity

    property bool visible: true
    property matrix4x4 cameraMatrix
    property real size: 10
    property TextureCubeMap cubemapTexture
    property url surface
    property vector3d cameraPosition
    property bool envMapping: true

    ShaderProgram {
        id: simpleShader

        vertexShaderCode: "
        attribute highp vec4 vertexPosition;
        attribute highp vec2 vertexTexCoord;

        varying highp vec2 texCoord;

        uniform highp mat4 mvp;

        void main()
        {
            texCoord = vertexTexCoord;
            gl_Position = mvp * vertexPosition;
        }
        "

        fragmentShaderCode: "
        varying highp vec2 texCoord;

        uniform sampler2D surfaceTexture;

        void main()
        {
            highp vec4 surface = texture2D(surfaceTexture, texCoord);
            gl_FragColor = vec4(surface.rgb * 0.8, 1.0);
        }
        "
    }

    ShaderProgram {
        id: envMappedShader

        vertexShaderCode: "
        attribute highp vec4 vertexPosition;
        attribute highp vec3 vertexNormal;
        attribute highp vec2 vertexTexCoord;

        varying highp vec2 texCoord;
        varying highp vec3 normal;
        varying highp vec3 viewDirection;

        uniform highp mat4 mvp;
        uniform highp mat4 modelMatrix;
        uniform highp vec3 cameraPosition;

        void main()
        {
            normal = (modelMatrix * vec4(vertexNormal, 0)).xyz;
            viewDirection = vec3(modelMatrix * vertexPosition) - cameraPosition;
            texCoord = vertexTexCoord;
            gl_Position = mvp * vertexPosition;
        }
        "

        fragmentShaderCode: "
        varying highp vec3 normal;
        varying highp vec3 viewDirection;
        varying highp vec2 texCoord;

        uniform samplerCube skyboxTexture;
        uniform sampler2D surfaceTexture;

        void main()
        {
            highp vec4 surface = texture2D(surfaceTexture, texCoord);
            highp vec3 reflectedDirection = reflect(viewDirection, normalize(normal));
            gl_FragColor = vec4(0.6 * textureCube(skyboxTexture, reflectedDirection).rgb + surface.rgb * 0.7, 1.0);
        }
        "
    }

    Material {
        id: material

        effect: Effect {
            id: fx

            Parameter { id: cubemapParam; name: "skyboxTexture"; value: cubemapTexture }
            Parameter { id: surfacetexParam; name: "surfaceTexture"; value: MipMappedTexture2D { source: surface } }
            Parameter { id: cameraPositionParam; name: "cameraPosition"; value: cameraPosition }

            parameters: [cubemapParam, surfacetexParam, cameraPositionParam]

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

                        shaderProgram: envMapping ? envMappedShader : simpleShader
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

                        shaderProgram: envMapping ? envMappedShader : simpleShader
                    }
                }
            ]
        }
    }

    Transform {
        id: modelTransform
        property real xShift: (105.5 + size) - 105 * showVideoTransitionState
        matrix: {
            var m = cameraMatrix.inverted();
            m.translate(Qt.vector3d(viewingVideo ? -xShift : xShift,
                                    0.0,
                                    viewingVideo ? 50 : -50));
            return m;
        }
    }

    SphereMesh {
        id: mesh
        radius: size
        slices: 32
        rings: 32
    }

    components: visible ? [modelTransform, mesh, material] : []
}
