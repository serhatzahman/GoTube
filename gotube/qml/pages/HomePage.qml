import QtQuick 1.1
import com.nokia.meego 1.0
import "../components"

Page {
    id: homePage
    tools: commonTools

    property variant videos: []

    Component.onCompleted: {
        youtubeClient.fetchTrending();
    }

    Connections {
        target: youtubeClient
        onTrendingLoaded: {
            homePage.videos = videos;
            videoList.model = videos;
        }
    }

    // Top Header Bar
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

            Rectangle {
                width: 28
                height: 20
                radius: 4
                color: "#E50914" // Accent Red
                anchors.verticalCenter: parent.verticalCenter

                Text {
                    anchors.centerIn: parent
                    text: "▶"
                    color: "#FFFFFF"
                    font.pixelSize: 11
                }
            }

            Text {
                text: "GoTube"
                color: "#FFFFFF"
                font.pixelSize: 26
                font.family: "Nokia Pure Text"
                font.bold: true
                anchors.verticalCenter: parent.verticalCenter
            }

            Text {
                text: "Trendler"
                color: "#888888"
                font.pixelSize: 18
                font.family: "Nokia Pure Text"
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        ToolIcon {
            anchors.right: parent.right
            anchors.rightMargin: 8
            anchors.verticalCenter: parent.verticalCenter
            iconId: "toolbar-refresh"
            onClicked: youtubeClient.fetchTrending()
        }

        Rectangle {
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            height: 1
            color: "#252525"
        }
    }

    // Video Feed
    ListView {
        id: videoList
        anchors.top: headerBar.bottom
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

    // Loading indicator
    BusyIndicator {
        anchors.centerIn: parent
        running: youtubeClient.isLoading && videoList.count === 0
        visible: running
        platformStyle: BusyIndicatorStyle { size: "large" }
    }

    // Empty state message
    Text {
        anchors.centerIn: parent
        text: "Video bulunamadı.\nBağlantınızı kontrol edin veya yenileyin."
        color: "#666666"
        font.pixelSize: 16
        horizontalAlignment: Text.AlignHCenter
        visible: !youtubeClient.isLoading && videoList.count === 0
    }
}
