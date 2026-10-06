TARGET = gotube
TEMPLATE = app

QT += core gui declarative network script

# Nokia N9 Harmattan Booster support
CONFIG += qdeclarative-boostable

SOURCES += src/main.cpp \
           src/youtubeclient.cpp

HEADERS += src/youtubeclient.h

OTHER_FILES += qml/main.qml \
               qml/pages/HomePage.qml \
               qml/pages/SearchPage.qml \
               qml/pages/PlayerPage.qml \
               qml/pages/DownloadsPage.qml \
               qml/pages/ChannelPage.qml \
               qml/components/VideoDelegate.qml \
               gotube.desktop

# Installation rules for MeeGo 1.2 Harmattan
target.path = /opt/gotube/bin

qml.files = qml/*
qml.path = /opt/gotube/qml

desktop.files = gotube.desktop
desktop.path = /usr/share/applications

INSTALLS += target qml desktop
