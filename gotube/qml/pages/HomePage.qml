import QtQuick 1.1
import com.nokia.meego 1.0
import "../components"

Page {
    id: homePage
    tools: commonTools

    property variant videos: []
    property string currentCategory: "music"

    Component.onCompleted: {
        switchCategory("music");
    }

    Connections {
        target: youtubeClient
        onTrendingLoaded: {
            homePage.videos = videos;
            videoList.model = videos;
        }
    }

    function switchCategory(cat) {
        currentCategory = cat;
        categoryIndicator.running = true;
        var xhr = new XMLHttpRequest();
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                categoryIndicator.running = false;
                if (xhr.status === 200) {
                    try {
                        var data = JSON.parse(xhr.responseText);
                        homePage.videos = data;
                        videoList.model = data;
                    } catch (e) {
                        console.log("Category parse hatasi:", e);
                    }
                }
            }
        };
        xhr.open("GET", "http://192.168.8.137:8888/api/v1/trending?type=" + cat);
        xhr.send();
    }

    // Ust Header
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
                color: "#E50914"
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
                font.verticalCenter: parent.verticalCenter
            }
        }

        ToolIcon {
            anchors.right: parent.right
            anchors.rightMargin: 8
            anchors.verticalCenter: parent.verticalCenter
            iconId: "toolbar-refresh"
            onClicked: {
                switchCategory(currentCategory);
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

    // Kategori Filtre Cubugu (Muzik, Oyun, Haberler, Tumu)
    Rectangle {
        id: categoryBar
        anchors.top: headerBar.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: 48
        color: "#050505"

        Row {
            anchors.centerIn: parent
            spacing: 8

            // Muzik
            Rectangle {
                width: 78
                height: 32
                radius: 16
                color: (currentCategory == "music" ? "#E50914" : "#1C1C1C")
                border.color: (currentCategory == "music" ? "#E50914" : "#333333")
                border.width: 1

                Text {
                    anchors.centerIn: parent
                    text: "Müzik"
                    color: "#FFFFFF"
                    font.pixelSize: 13
                    font.bold: true
                    font.family: "Nokia Pure Text"
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: switchCategory("music")
                }
            }

            // Oyun
            Rectangle {
                width: 78
                height: 32
                radius: 16
                color: (currentCategory == "gaming" ? "#E50914" : "#1C1C1C")
                border.color: (currentCategory == "gaming" ? "#E50914" : "#333333")
                border.width: 1

                Text {
                    anchors.centerIn: parent
                    text: "Oyun"
                    color: "#FFFFFF"
                    font.pixelSize: 13
                    font.bold: true
                    font.family: "Nokia Pure Text"
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: switchCategory("gaming")
                }
            }

            // Haberler
            Rectangle {
                width: 84
                height: 32
                radius: 16
                color: (currentCategory == "news" ? "#E50914" : "#1C1C1C")
                border.color: (currentCategory == "news" ? "#E50914" : "#333333")
                border.width: 1

                Text {
                    anchors.centerIn: parent
                    text: "Haberler"
                    color: "#FFFFFF"
                    font.pixelSize: 13
                    font.bold: true
                    font.family: "Nokia Pure Text"
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: switchCategory("news")
                }
            }

            // Tumu
            Rectangle {
                width: 76
                height: 32
                radius: 16
                color: (currentCategory == "all" ? "#E50914" : "#1C1C1C")
                border.color: (currentCategory == "all" ? "#E50914" : "#333333")
                border.width: 1

                Text {
                    anchors.centerIn: parent
                    text: "Tümü"
                    color: "#FFFFFF"
                    font.pixelSize: 13
                    font.bold: true
                    font.family: "Nokia Pure Text"
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: switchCategory("all")
                }
            }
        }

        Rectangle {
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            height: 1
            color: "#181818"
        }
    }

    // Video Feed
    ListView {
        id: videoList
        anchors.top: categoryBar.bottom
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

    // Yukleniyor Spinner
    BusyIndicator {
        id: categoryIndicator
        anchors.centerIn: parent
        running: (homePage.videos.length === 0)
        visible: running
        platformStyle: BusyIndicatorStyle { size: "large" }
    }

    // Bos Durum Mesaji
    Text {
        anchors.centerIn: parent
        text: "Video bulunamadi.\nBaglantinizi kontrol edin veya yenileyin."
        color: "#666666"
        font.pixelSize: 16
        horizontalAlignment: Text.AlignHCenter
        visible: (homePage.videos.length === 0 && categoryIndicator.running == false)
    }
}
