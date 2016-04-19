TEMPLATE = app

QT += qml quick
QT += multimedia

SOURCES += main.cpp

RESOURCES += \
    qml.qrc \
    images.qrc

VIDEO_FILES.files = \
    # Note: Enable these if videos are bundled locally
    #videos/Build_Your_World_With_Qt.mp4 \
    #videos/Bluescape_collaborative_workspace.mp4 \
    #videos/IoT_and_Qt.mp4 \
    #videos/Meet_Qt_Creator.mp4 \
    #videos/3D_Planets_Example.mp4

# On OSX videos are bundled, on android installed into assets
osx {
    VIDEO_FILES.path = Contents/MacOS
    QMAKE_BUNDLE_DATA += VIDEO_FILES
}
android {
    VIDEO_FILES.path = /assets/videos
    INSTALLS += VIDEO_FILES
}


# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Default rules for deployment.
include(deployment.pri)

DISTFILES += \
    android/AndroidManifest.xml \
    android/res/values/libs.xml \
    android/build.gradle

ANDROID_PACKAGE_SOURCE_DIR = $$PWD/android
