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

#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QUrl>
#include <QStringList>
#include <QStandardPaths>
#include <QQmlContext>
#include <QNetworkConfigurationManager>
#include <QDebug>

static bool FORCE_LOCAL_VIDEOS = false;

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    QQmlApplicationEngine engine;

    QNetworkConfigurationManager mgr;

    // Export movies path
    // On Android use assets, on OS X (bundle) application path, otherwise application path + "/videos"


    // If we have network connections, use empty videoPath
    if (!FORCE_LOCAL_VIDEOS && mgr.isOnline()) {
        qDebug() << "Loading videos from Internet";
        engine.rootContext()->setContextProperty("videoPath", "https://s3-eu-west-1.amazonaws.com/qt-files/examples/Videos/");
    } else {
        qDebug() << "Loading videos locally";
#if defined(Q_OS_ANDROID)
    engine.rootContext()->setContextProperty("videoPath", "assets:/videos/");
#else
    const QUrl appPath(QUrl::fromLocalFile(app.applicationDirPath()));
#if defined(Q_OS_OSX)
    engine.rootContext()->setContextProperty("videoPath", appPath.toString() + "/");
#else
    engine.rootContext()->setContextProperty("videoPath", appPath.toString() + "/videos/");
#endif
#endif
    }
    engine.load(QUrl(QStringLiteral("qrc:/qml/main.qml")));

    return app.exec();
}

