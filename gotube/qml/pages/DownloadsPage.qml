import QtQuick 1.1
import com.nokia.meego 1.0

Page {
    id: downloadsPage
    tools: commonTools

    Component.onCompleted: {
        youtubeClient.fetchLocalDownloads();
    }

    Connections {
        target: youtubeClient
        onLocalDownloadsLoaded: {
            downloadsList.model = downloads;
        }
    }

    Rectangle {
        id: headerBar
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: 64
        color: "#000000"

        Row {
            anchors.left: parent.left
            anchors.leftMargin: 16
            anchors.verticalCenter: parent.verticalCenter
            spacing: 8

            Text {
                text: "İndirilen Videolar"
                color: "#FFFFFF"
                font.pixelSize: 24
                font.family: "Nokia Pure Text"
                font.bold: true
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        ToolIcon {
            anchors.right: parent.right
            anchors.rightMargin: 8
            anchors.verticalCenter: parent.verticalCenter
            iconId: "toolbar-refresh"
            onClicked: youtubeClient.fetchLocalDownloads()
        }

        Rectangle {
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            height: 1
            color: "#252525"
        }
    }

    ListView {
        id: downloadsList
        anchors.top: headerBar.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        clip: true

        delegate: Item {
            id: downloadItem
            width: parent.width
            height: 80

            Rectangle {
                anchors.fill: parent
                color: itemMouseArea.pressed ? "#222222" : "transparent"
            }

            Rectangle {
                id: fileIconBox
                width: 50
                height: 50
                radius: 6
                color: "#1E1E1E"
                anchors.left: parent.left
                anchors.leftMargin: 16
                anchors.verticalCenter: parent.verticalCenter

                Text {
                    anchors.centerIn: parent
                    text: "🎬"
                    font.pixelSize: 22
                }
            }

            Column {
                anchors.left: fileIconBox.right
                anchors.leftMargin: 12
                anchors.right: deleteBtn.left
                anchors.rightMargin: 8
                anchors.verticalCenter: parent.verticalCenter
                spacing: 4

                Text {
                    text: modelData.title || modelData.fileName
                    width: parent.width
                    color: "#FFFFFF"
                    font.pixelSize: 17
                    font.bold: true
                    font.family: "Nokia Pure Text"
                    elide: Text.ElideRight
                }

                Text {
                    text: modelData.fileSize + " • " + modelData.modifiedDate
                    color: "#888888"
                    font.pixelSize: 13
                    font.family: "Nokia Pure Text"
                }
            }

            ToolIcon {
                id: deleteBtn
                anchors.right: parent.right
                anchors.rightMargin: 12
                anchors.verticalCenter: parent.verticalCenter
                iconId: "toolbar-delete"
                onClicked: {
                    youtubeClient.deleteLocalDownload(modelData.filePath);
                }
            }

            Rectangle {
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                height: 1
                color: "#181818"
            }

            MouseArea {
                id: itemMouseArea
                anchors.fill: parent
                anchors.rightMargin: 60
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("PlayerPage.qml"), {
                        currentStreamUrl: "file://" + modelData.filePath,
                        initialTitle: modelData.title,
                        initialAuthor: "Çevrimdışı Video"
                    });
                }
            }
        }
    }

    Text {
        anchors.centerIn: parent
        text: "Henüz indirilmiş video yok.\nVideoları çevrimdışı izlemek için indirme butonunu kullanın."
        color: "#666666"
        font.pixelSize: 16
        horizontalAlignment: Text.AlignHCenter
        visible: downloadsList.count === 0
    }
}