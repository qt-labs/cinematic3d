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
    property alias cameraPosition: transform.translation
    property int cubemapIndex: 0
    property TextureCubeMap cubemapTexture: skyboxTexture

    TextureCubeMap {
        id: skyboxTexture
        property var cubemaps: ["space", "miramar"]
        property string cubemap: cubemaps[cubemapIndex]
        property string path: "qrc:/qml/images/cubemaps/" + cubemap + "/" + cubemap
        property string extension: cubemap == "space" ? ".png" : ".webp"

        generateMipMaps: false
        magnificationFilter: Texture.Linear
        minificationFilter: Texture.Linear
        wrapMode {
            x: WrapMode.ClampToEdge
            y: WrapMode.ClampToEdge
        }
        TextureImage { face: Texture.CubeMapPositiveX; source: skyboxTexture.path + "_posx" + skyboxTexture.extension }
        TextureImage { face: Texture.CubeMapPositiveY; source: skyboxTexture.path + "_posy" + skyboxTexture.extension }
        TextureImage { face: Texture.CubeMapPositiveZ; source: skyboxTexture.path + "_posz" + skyboxTexture.extension }
        TextureImage { face: Texture.CubeMapNegativeX; source: skyboxTexture.path + "_negx" + skyboxTexture.extension }
        TextureImage { face: Texture.CubeMapNegativeY; source: skyboxTexture.path + "_negy" + skyboxTexture.extension }
        TextureImage { face: Texture.CubeMapNegativeZ; source: skyboxTexture.path + "_negz" + skyboxTexture.extension }
    }

    ShaderProgram {
        id: gles2SkyboxShader

        vertexShaderCode: "
        attribute vec3 vertexPosition;
        varying vec3 texCoord0;

        uniform mat4 mvp;

        void main()
        {
            texCoord0 = vertexPosition.xyz;
            gl_Position = vec4(mvp * vec4(vertexPosition, 1.0)).xyww; // Fail depth test always against any rendered pixel
        }
        "

        fragmentShaderCode: "
        varying highp vec3 texCoord0;
        uniform samplerCube skyboxTexture;

        void main()
        {
            gl_FragColor = textureCube(skyboxTexture, texCoord0);
        }
        "
    }

    CuboidMesh {
        id: cuboidMesh
        yzMeshResolution: Qt.size(2, 2)
        xzMeshResolution: Qt.size(2, 2)
        xyMeshResolution: Qt.size(2, 2)
    }

    Transform {
        id: transform
    }

    Material {
        id: skyboxMaterial

        parameters: [
            Parameter {name: "skyboxTexture"; value: cubemapTexture }
        ]

        effect: Effect {
            techniques: [
                Technique {
                    graphicsApiFilter {
                        api: GraphicsApiFilter.OpenGLES
                        profile: GraphicsApiFilter.NoProfile
                        majorVersion: 2
                        minorVersion: 0
                    }
                    renderPasses: RenderPass {
                        shaderProgram: gles2SkyboxShader
                        renderStates: [
                            CullFace { mode: CullFace.Front },
                            DepthTest { depthFunction: DepthTest.LessOrEqual }
                        ]
                    }
                },
                Technique {
                    graphicsApiFilter {
                        api: GraphicsApiFilter.OpenGL
                        profile: GraphicsApiFilter.NoProfile
                        majorVersion: 2
                        minorVersion: 0
                    }
                    renderPasses: RenderPass {
                        shaderProgram: gles2SkyboxShader
                        renderStates: [
                            CullFace { mode: CullFace.Front },
                            DepthTest { depthFunction: DepthTest.LessOrEqual }
                        ]
                    }
                }
            ]
        }
    }

    components: [cuboidMesh, skyboxMaterial, transform]
}

