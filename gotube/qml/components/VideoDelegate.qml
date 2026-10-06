import QtQuick 1.1
import com.nokia.meego 1.0

Item {
    id: root
    width: parent.width
    height: 104

    property variant videoData

    signal clicked()

    Rectangle {
        id: bg
        anchors.fill: parent
        color: mouseArea.pressed ? "#222222" : "transparent"
    }

    // Video Thumbnail (16:9)
    Item {
        id: thumbContainer
        width: 140
        height: 79
        anchors.left: parent.left
        anchors.leftMargin: 16
        anchors.verticalCenter: parent.verticalCenter

        Rectangle {
            anchors.fill: parent
            color: "#181818"
            radius: 4
        }

        Image {
            id: thumbImage
            anchors.fill: parent
            source: {
                if (videoData.videoThumbnails && videoData.videoThumbnails.length > 0) {
                    return videoData.videoThumbnails[0].url;
                }
                return "";
            }
            fillMode: Image.PreserveAspectCrop
            clip: true
            smooth: true
        }

        // Duration badge
        Rectangle {
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.margins: 4
            width: durationText.width + 8
            height: 18
            color: "#CC000000"
            radius: 3
            visible: durationText.text.length > 0

            Text {
                id: durationText
                anchors.centerIn: parent
                text: {
                    var sec = videoData.lengthSeconds;
                    if (!sec) return "";
                    var m = Math.floor(sec / 60);
                    var s = sec % 60;
                    return m + ":" + (s < 10 ? "0" + s : s);
                }
                color: "#FFFFFF"
                font.pixelSize: 13
                font.family: "Nokia Pure Text"
            }
        }
    }

    // Video Information
    Column {
        anchors.left: thumbContainer.right
        anchors.leftMargin: 12
        anchors.right: parent.right
        anchors.rightMargin: 16
        anchors.verticalCenter: parent.verticalCenter
        spacing: 4

        Text {
            id: titleText
            text: videoData.title || ""
            width: parent.width
            color: "#FFFFFF"
            font.pixelSize: 18
            font.family: "Nokia Pure Text"
            font.bold: true
            elide: Text.ElideRight
            maximumLineCount: 2
            wrapMode: Text.Wrap
        }

        Text {
            text: videoData.author || ""
            width: parent.width
            color: "#AAAAAA"
            font.pixelSize: 15
            font.family: "Nokia Pure Text"
            elide: Text.ElideRight
        }

        Text {
            text: {
                var views = videoData.viewCount;
                var viewStr = views ? views.toLocaleString() + " görüntüleme" : "";
                var pubStr = videoData.publishedText || "";
                if (viewStr && pubStr) return viewStr + " • " + pubStr;
                return viewStr || pubStr;
            }
            width: parent.width
            color: "#777777"
            font.pixelSize: 13
            font.family: "Nokia Pure Text"
            elide: Text.ElideRight
        }
    }

    // Bottom Separator
    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: 1
        color: "#1A1A1A"
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        onClicked: root.clicked()
    }
}
