import QtQuick 1.1
import com.nokia.meego 1.0
import "../components"

Page {
    id: searchPage
    tools: commonTools

    Connections {
        target: youtubeClient
        onSearchCompleted: {
            searchResultsList.model = videos;
        }
    }

    // Top Search Bar
    Rectangle {
        id: searchHeader
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: 64
        color: "#000000"

        Row {
            anchors.fill: parent
            anchors.margins: 8
            spacing: 8

            Rectangle {
                id: inputContainer
                width: parent.width - searchBtn.width - 8
                height: 48
                radius: 24
                color: "#1C1C1C"
                border.color: searchInput.activeFocus ? "#E50914" : "#333333"
                border.width: 1

                TextInput {
                    id: searchInput
                    anchors.left: parent.left
                    anchors.leftMargin: 16
                    anchors.right: clearBtn.left
                    anchors.rightMargin: 8
                    anchors.verticalCenter: parent.verticalCenter
                    color: "#FFFFFF"
                    font.pixelSize: 18
                    font.family: "Nokia Pure Text"
                    selectByMouse: true
                    inputMethodHints: Qt.ImhNoPredictiveText

                    // Placeholder text
                    Text {
                        anchors.fill: parent
                        text: "YouTube'da Ara..."
                        color: "#666666"
                        font.pixelSize: 18
                        font.family: "Nokia Pure Text"
                        visible: !searchInput.text && !searchInput.activeFocus
                    }

                    onAccepted: {
                        if (searchInput.text.trim().length > 0) {
                            youtubeClient.searchVideos(searchInput.text.trim());
                        }
                    }
                }

                // Clear button
                ToolIcon {
                    id: clearBtn
                    anchors.right: parent.right
                    anchors.rightMargin: 4
                    anchors.verticalCenter: parent.verticalCenter
                    iconId: "toolbar-dismiss"
                    visible: searchInput.text.length > 0
                    onClicked: {
                        searchInput.text = "";
                    }
                }
            }

            Button {
                id: searchBtn
                text: "Ara"
                width: 72
                height: 48
                anchors.verticalCenter: parent.verticalCenter
                onClicked: {
                    if (searchInput.text.trim().length > 0) {
                        youtubeClient.searchVideos(searchInput.text.trim());
                    }
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

    // Results List
    ListView {
        id: searchResultsList
        anchors.top: searchHeader.bottom
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
        running: youtubeClient.isLoading && searchResultsList.count === 0
        visible: running
        platformStyle: BusyIndicatorStyle { size: "large" }
    }
}
