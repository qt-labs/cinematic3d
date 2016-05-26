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

import Qt3D.Render 2.0
import Qt3D.Extras 2.0

ShaderProgram {
    vertexShaderCode: "
    attribute highp vec4 vertexPosition;
    attribute highp vec3 vertexNormal;
    attribute highp vec2 vertexTexCoord;

    varying highp vec2 texCoord;
    varying highp vec3 normal;
    varying highp vec3 viewDirection;
    varying highp float w1;
    varying highp float w2;
    varying highp float w3;
    varying highp float w4;

    uniform highp mat4 mvp;
    uniform highp mat4 modelMatrix;
    uniform highp vec3 cameraPosition;

    void main()
    {
        normal = (modelMatrix * vec4(vertexNormal, 0)).xyz;
        viewDirection = vec3(modelMatrix * vertexPosition) - cameraPosition;
        texCoord = vec2(vertexTexCoord.s, 1. - vertexTexCoord.t);

        w1 = w2 = w3 = w4 = 0.;
        if (vertexNormal.x > 0.) {
            w1 = 1.;
            texCoord = vec2(texCoord.t, 1. - texCoord.s);
        } else if (vertexNormal.z > 0.) {
            w2 = 1.;
        } else if (vertexNormal.x < 0.) {
            w3 = 1.;
            texCoord = vec2(1. - texCoord.t, 1. - texCoord.s);
        } else if (vertexNormal.z < 0.) {
            w4 = 1.;
            texCoord = vec2(1. - texCoord.s, texCoord.t);
        }

        gl_Position = mvp * vertexPosition;
    }
    "

    fragmentShaderCode: "
    varying highp vec3 normal;
    varying highp vec3 viewDirection;
    varying highp vec2 texCoord;
    varying highp float w1;
    varying highp float w2;
    varying highp float w3;
    varying highp float w4;

    uniform samplerCube skyboxTexture;
    uniform sampler2D tex1;
    uniform sampler2D tex2;
    uniform sampler2D tex3;
    uniform sampler2D tex4;

    void main()
    {
        highp vec3 reflectedDirection = reflect(viewDirection, normalize(normal));
        highp vec4 color = w1 * texture2D(tex1, texCoord);
        color += w2 * texture2D(tex2, texCoord);
        color += w3 * texture2D(tex3, texCoord);
        color += w4 * texture2D(tex4, texCoord);
        highp float shininess = 0.6 - color.a * 0.5;
        color += (1.0 - color.a) * vec4(0.2, 0.2, 0.2, 1.0);
        gl_FragColor = vec4(mix(color.rgb, textureCube(skyboxTexture, reflectedDirection).rgb, shininess), 1.0);
    }
    "
}
