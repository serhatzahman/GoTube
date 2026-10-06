import QtQuick 1.1
import com.nokia.meego 1.0
import "../components"

Page {
    id: channelPage
    tools: channelTools

    property string authorId: ""
    property string initialAuthorName: ""
    property variant channelData: null

    Component.onCompleted: {
        if (authorId.length > 0) {
            youtubeClient.fetchChannel(authorId);
        }
    }

    Connections {
        target: youtubeClient
        onChannelLoaded: {
            channelPage.channelData = channelData;
            if (channelData.latestVideos) {
                channelVideosList.model = channelData.latestVideos;
            }
        }
    }

    Rectangle {
        id: channelHeader
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: 100
        color: "#121212"

        Row {
            anchors.left: parent.left
            anchors.leftMargin: 16
            anchors.right: parent.right
            anchors.rightMargin: 16
            anchors.verticalCenter: parent.verticalCenter
            spacing: 14

            Rectangle {
                width: 64
                height: 64
                radius: 32
                color: "#282828"
                clip: true

                Image {
                    anchors.fill: parent
                    source: {
                        if (channelData && channelData.authorThumbnails && channelData.authorThumbnails.length > 0) {
                            return channelData.authorThumbnails[channelData.authorThumbnails.length - 1].url;
                        }
                        return "";
                    }
                    fillMode: Image.PreserveAspectCrop
                }

                Text {
                    anchors.centerIn: parent
                    text: (channelData ? channelData.author[0] : (initialAuthorName ? initialAuthorName[0] : "C"))
                    color: "#FFFFFF"
                    font.pixelSize: 26
                    font.bold: true
                    visible: (parent.children[0].source == "")
                }
            }

            Column {
                anchors.verticalCenter: parent.verticalCenter
                spacing: 4
                width: (parent.width - 90)

                Text {
                    text: channelData ? channelData.author : initialAuthorName
                    color: "#FFFFFF"
                    font.pixelSize: 20
                    font.bold: true
                    font.family: "Nokia Pure Text"
                    elide: Text.ElideRight
                    width: parent.width
                }

                Text {
                    text: {
                        if (channelData == null) return "";
                        var subs = channelData.subCount ? channelData.subCount.toLocaleString() + " abone" : "";
                        var count = channelData.totalVideos ? " • " + channelData.totalVideos + " video" : "";
                        return subs + count;
                    }
                    color: "#888888"
                    font.pixelSize: 14
                    font.family: "Nokia Pure Text"
                }
            }
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
        id: channelVideosList
        anchors.top: channelHeader.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        clip: true

        delegate: VideoDelegate {
            videoData: modelData
            onClicked: {
                pageStack.push(Qt.resolvedUrl("PlayerPage.qml"), {
                    videoId: modelData.videoId,
                    initialTitle: modelData.title,
                    initialAuthor: modelData.author
                });
            }
        }
    }

    BusyIndicator {
        anchors.centerIn: parent
        running: youtubeClient.isLoading && channelVideosList.count === 0
        visible: running
        platformStyle: BusyIndicatorStyle { size: "large" }
    }

    ToolBarLayout {
        id: channelTools
        ToolIcon {
            iconId: "toolbar-back"
            onClicked: pageStack.pop()
        }
    }
}
