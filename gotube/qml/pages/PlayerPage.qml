import QtQuick 1.1
import com.nokia.meego 1.0
import QtMultimediaKit 1.1

Page {
    id: playerPage
    tools: (isFullscreen ? null : playerTools)
    orientationLock: (isFullscreen ? PageOrientation.LockLandscape : PageOrientation.LockPortrait)

    ToolBarLayout {
        id: playerTools
        ToolIcon {
            iconId: "toolbar-back"
            onClicked: {
                videoPlayer.stop();
                pageStack.pop();
            }
        }
    }

    property string videoId: ""
    property string initialTitle: ""
    property string initialAuthor: ""
    property string currentStreamUrl: ""
    property bool audioOnlyMode: false
    property bool isFullscreen: false
    property bool controlsVisible: true
    property bool isPlaying: (videoPlayer.playing == true && videoPlayer.paused == false)

    Component.onCompleted: {
        console.log(">>> [PlayerPage] Video acildi: " + videoId);
        if (videoId.length > 0) {
            currentStreamUrl = "http://192.168.8.137:8888/stream/" + videoId + ".mp4";
            videoPlayer.source = currentStreamUrl;
            videoPlayer.play();
        }
    }

    function togglePlay() {
        if (videoPlayer.playing && videoPlayer.paused == false) {
            console.log(">>> [PlayerPage] Duraklatiliyor");
            videoPlayer.pause();
        } else {
            console.log(">>> [PlayerPage] Oynatiliyor");
            if (videoPlayer.paused) {
                videoPlayer.paused = false;
            }
            if (videoPlayer.source != currentStreamUrl) {
                videoPlayer.source = currentStreamUrl;
            }
            videoPlayer.play();
        }
        autoHideTimer.restart();
    }

    Timer {
        id: autoHideTimer
        interval: 4000
        running: (controlsVisible && isPlaying)
        repeat: false
        onTriggered: {
            controlsVisible = false;
        }
    }

    function toggleControls() {
        controlsVisible = (controlsVisible ? false : true);
        if (controlsVisible && isPlaying) {
            autoHideTimer.restart();
        }
    }

    function formatTime(ms) {
        if (ms == undefined || ms <= 0) {
            return "0:00";
        }
        var sec = Math.floor(ms / 1000);
        var min = Math.floor(sec / 60);
        var remSec = sec % 60;
        if (remSec < 10) {
            return min + ":0" + remSec;
        }
        return min + ":" + remSec;
    }

    // Video Alani
    Item {
        id: videoBox
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: (isFullscreen ? parent.height : 270)
        z: 10

        Rectangle {
            anchors.fill: parent
            color: "#000000"
        }

        Video {
            id: videoPlayer
            anchors.fill: parent
            fillMode: Video.PreserveAspectFit
            visible: (audioOnlyMode == false)

            onPositionChanged: {
                if (seekSlider.pressed == false) {
                    seekSlider.value = position;
                }
            }
        }

        // Sadece Ses Modu
        Rectangle {
            anchors.fill: parent
            color: "#080808"
            visible: audioOnlyMode

            Column {
                anchors.centerIn: parent
                spacing: 12

                Rectangle {
                    width: 60
                    height: 60
                    radius: 30
                    color: "#1A1A1A"
                    border.color: "#E50914"
                    border.width: 2
                    anchors.horizontalCenter: parent.horizontalCenter

                    Text {
                        anchors.centerIn: parent
                        text: "♪"
                        color: "#E50914"
                        font.pixelSize: 32
                    }
                }

                Text {
                    text: "Sadece Ses Modu Aktif"
                    color: "#FFFFFF"
                    font.pixelSize: 18
                    font.bold: true
                    font.family: "Nokia Pure Text"
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Text {
                    text: "Ekran kapaliyken de calar."
                    color: "#777777"
                    font.pixelSize: 13
                    font.family: "Nokia Pure Text"
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }
        }

        // Yukleniyor Spinner
        BusyIndicator {
            anchors.centerIn: parent
            running: (videoPlayer.status === 1 || videoPlayer.status === 2 || (isPlaying == false && videoPlayer.position == 0))
            visible: running
            platformStyle: BusyIndicatorStyle { size: "large" }
        }

        MouseArea {
            anchors.fill: parent
            onClicked: toggleControls()
        }

        Item {
            id: controlsOverlay
            anchors.fill: parent
            visible: controlsVisible

            // Ust Bar (Sadece Tam Ekranda)
            Rectangle {
                id: topBar
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                height: 52
                color: "#99000000"
                visible: isFullscreen

                Rectangle {
                    id: topExitFsBtn
                    anchors.left: parent.left
                    anchors.leftMargin: 12
                    anchors.verticalCenter: parent.verticalCenter
                    width: 40
                    height: 40
                    radius: 20
                    color: "#40000000"

                    Text {
                        anchors.centerIn: parent
                        text: "←"
                        color: "#FFFFFF"
                        font.pixelSize: 24
                        font.bold: true
                    }

                    MouseArea {
                        id: topExitMouse
                        anchors.fill: parent
                        onClicked: {
                            isFullscreen = false;
                        }
                    }
                }

                Text {
                    anchors.left: topExitFsBtn.right
                    anchors.leftMargin: 14
                    anchors.right: parent.right
                    anchors.rightMargin: 16
                    anchors.verticalCenter: parent.verticalCenter
                    text: initialTitle
                    color: "#FFFFFF"
                    font.pixelSize: 15
                    font.family: "Nokia Pure Text"
                    font.bold: true
                    elide: Text.ElideRight
                }
            }

            // Ortada Buyuk Oynat Butonu
            Rectangle {
                anchors.centerIn: parent
                width: 72
                height: 72
                radius: 36
                color: "#90000000"
                border.color: "#FFFFFF"
                border.width: 2
                visible: (isPlaying == false)

                Text {
                    anchors.centerIn: parent
                    anchors.horizontalCenterOffset: 3
                    text: "▶"
                    color: "#FFFFFF"
                    font.pixelSize: 32
                }

                MouseArea {
                    id: centerPlayMouse
                    anchors.fill: parent
                    onClicked: {
                        togglePlay();
                    }
                }
            }

            // Alt Kontrol Bari
            Rectangle {
                id: bottomControlsBar
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                height: 56
                color: "#B0000000"

                // OYNAT / DURDUR IKON BUTONU
                Rectangle {
                    id: playPauseBtn
                    anchors.left: parent.left
                    anchors.leftMargin: 10
                    anchors.verticalCenter: parent.verticalCenter
                    width: 44
                    height: 44
                    radius: 22
                    clip: true
                    color: "#30FFFFFF"

                    Row {
                        anchors.centerIn: parent
                        spacing: 4
                        visible: isPlaying

                        Rectangle {
                            width: 4
                            height: 16
                            radius: 1
                            color: "#FFFFFF"
                        }
                        Rectangle {
                            width: 4
                            height: 16
                            radius: 1
                            color: "#FFFFFF"
                        }
                    }

                    Text {
                        anchors.centerIn: parent
                        anchors.horizontalCenterOffset: 2
                        text: "▶"
                        color: "#FFFFFF"
                        font.pixelSize: 20
                        visible: (isPlaying == false)
                    }

                    MouseArea {
                        id: playPauseMouse
                        anchors.fill: parent
                        onClicked: {
                            togglePlay();
                        }
                    }
                }

                Text {
                    id: timeCurrentTxt
                    anchors.left: playPauseBtn.right
                    anchors.leftMargin: 10
                    anchors.verticalCenter: parent.verticalCenter
                    text: formatTime(videoPlayer.position)
                    color: "#FFFFFF"
                    font.pixelSize: 13
                    font.family: "Nokia Pure Text"
                }

                Rectangle {
                    id: fsBtn
                    anchors.right: parent.right
                    anchors.rightMargin: 10
                    anchors.verticalCenter: parent.verticalCenter
                    width: 44
                    height: 44
                    radius: 22
                    color: "#30FFFFFF"

                    Rectangle {
                        anchors.centerIn: parent
                        width: 18
                        height: 14
                        color: "transparent"
                        border.color: "#FFFFFF"
                        border.width: 2
                        radius: 2
                        visible: (isFullscreen == false)
                    }

                    Text {
                        anchors.centerIn: parent
                        text: "✕"
                        color: "#FFFFFF"
                        font.pixelSize: 18
                        font.bold: true
                        visible: isFullscreen
                    }

                    MouseArea {
                        id: fsMouse
                        anchors.fill: parent
                        onClicked: {
                            isFullscreen = (isFullscreen ? false : true);
                            autoHideTimer.restart();
                        }
                    }
                }

                Text {
                    id: timeDurationTxt
                    anchors.right: fsBtn.left
                    anchors.rightMargin: 10
                    anchors.verticalCenter: parent.verticalCenter
                    text: formatTime(videoPlayer.duration)
                    color: "#AAAAAA"
                    font.pixelSize: 13
                    font.family: "Nokia Pure Text"
                }

                Slider {
                    id: seekSlider
                    anchors.left: timeCurrentTxt.right
                    anchors.leftMargin: 8
                    anchors.right: timeDurationTxt.left
                    anchors.rightMargin: 8
                    anchors.verticalCenter: parent.verticalCenter
                    minimumValue: 0
                    maximumValue: (videoPlayer.duration > 0 ? videoPlayer.duration : 1)
                    onValueChanged: {
                        if (pressed) {
                            timeCurrentTxt.text = formatTime(value);
                        }
                    }
                    onPressedChanged: {
                        if (pressed == false) {
                            console.log(">>> [PlayerPage] Seek: " + Math.floor(value));
                            videoPlayer.position = Math.floor(value);
                            if (videoPlayer.paused == false) {
                                videoPlayer.play();
                            }
                        }
                    }
                }
            }
        }
    }

    // Video Detaylari
    Flickable {
        id: detailsFlickable
        anchors.top: videoBox.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        visible: (isFullscreen == false)
        contentWidth: width
        contentHeight: (detailsCol.height + 40)
        clip: true

        Column {
            id: detailsCol
            width: (parent.width - 32)
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 14

            Item {
                width: parent.width
                height: 4
            }

            Text {
                text: initialTitle
                width: parent.width
                color: "#FFFFFF"
                font.pixelSize: 19
                font.bold: true
                font.family: "Nokia Pure Text"
                wrapMode: Text.Wrap
            }

            Row {
                spacing: 8
                Rectangle {
                    width: 24
                    height: 24
                    radius: 12
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
                    text: initialAuthor
                    color: "#CCCCCC"
                    font.pixelSize: 15
                    font.family: "Nokia Pure Text"
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            Row {
                spacing: 12
                anchors.horizontalCenter: parent.horizontalCenter

                Rectangle {
                    width: 150
                    height: 44
                    radius: 22
                    color: (audioOnlyMode ? "#E50914" : "#1C1C1C")
                    border.color: (audioOnlyMode ? "#E50914" : "#333333")
                    border.width: 1

                    Row {
                        anchors.centerIn: parent
                        spacing: 8

                        Text {
                            text: "♪"
                            color: "#FFFFFF"
                            font.pixelSize: 18
                            font.bold: true
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Text {
                            text: (audioOnlyMode ? "Video Modu" : "Sadece Ses")
                            color: "#FFFFFF"
                            font.pixelSize: 14
                            font.bold: true
                            font.family: "Nokia Pure Text"
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    MouseArea {
                        id: audioMouse
                        anchors.fill: parent
                        onClicked: {
                            audioOnlyMode = (audioOnlyMode ? false : true);
                        }
                    }
                }

                Rectangle {
                    width: 150
                    height: 44
                    radius: 22
                    color: "#1C1C1C"
                    border.color: "#333333"
                    border.width: 1

                    Row {
                        anchors.centerIn: parent
                        spacing: 8

                        Text {
                            text: "↓"
                            color: "#FFFFFF"
                            font.pixelSize: 20
                            font.bold: true
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Text {
                            text: "Indir (MP4)"
                            color: "#FFFFFF"
                            font.pixelSize: 14
                            font.bold: true
                            font.family: "Nokia Pure Text"
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    MouseArea {
                        id: downloadMouse
                        anchors.fill: parent
                        onClicked: {
                            banner.show("Indirme ozelligi yakinda...");
                        }
                    }
                }
            }
        }
    }

    Rectangle {
        id: banner
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: 20
        width: (bannerText.width + 32)
        height: 40
        radius: 8
        color: "#E50914"
        visible: false
        z: 100

        Text {
            id: bannerText
            anchors.centerIn: parent
            text: ""
            color: "#FFFFFF"
            font.pixelSize: 14
            font.family: "Nokia Pure Text"
        }

        Timer {
            id: bannerTimer
            interval: 3000
            onTriggered: {
                banner.visible = false;
            }
        }

        function show(msg) {
            bannerText.text = msg;
            banner.visible = true;
            bannerTimer.restart();
        }
    }

}
