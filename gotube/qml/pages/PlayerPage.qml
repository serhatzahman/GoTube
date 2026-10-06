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
    property string currentQuality: "360p"
    property real currentSpeed: 1.0
    property variant speedOptions: [0.75, 1.0, 1.25, 1.5, 2.0]
    property int speedIndex: 1
    property bool audioOnlyMode: false
    property bool isFullscreen: false
    property bool controlsVisible: true
    property bool isPlaying: (videoPlayer.playing == true && videoPlayer.paused == false)
    property variant relatedVideos: []

    Component.onCompleted: {
        console.log(">>> [GoTube v2] Video acildi: " + videoId);
        loadStream();
        fetchRelatedVideos();
    }

    function loadStream() {
        if (videoId.length > 0) {
            currentStreamUrl = "http://192.168.8.137:8888/stream/" + videoId + "_" + currentQuality + ".mp4";
            videoPlayer.source = currentStreamUrl;
            videoPlayer.play();
        }
    }

    function switchQuality() {
        var savedPos = videoPlayer.position;
        currentQuality = (currentQuality == "360p" ? "720p" : "360p");
        banner.show("Kalite: " + currentQuality + " geciliyor...");
        currentStreamUrl = "http://192.168.8.137:8888/stream/" + videoId + "_" + currentQuality + ".mp4";
        videoPlayer.source = currentStreamUrl;
        videoPlayer.play();
        seekTimer.targetPosition = savedPos;
        seekTimer.restart();
    }

    Timer {
        id: seekTimer
        property int targetPosition: 0
        interval: 600
        repeat: false
        onTriggered: {
            if (targetPosition > 0) {
                videoPlayer.position = targetPosition;
            }
        }
    }

    function cycleSpeed() {
        speedIndex = ((speedIndex + 1) % 5);
        currentSpeed = speedOptions[speedIndex];
        videoPlayer.playbackRate = currentSpeed;
        banner.show("Oynatma Hizi: " + currentSpeed + "x");
    }

    function fetchRelatedVideos() {
        var xhr = new XMLHttpRequest();
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200) {
                    try {
                        var data = JSON.parse(xhr.responseText);
                        relatedVideos = data;
                    } catch (e) {
                        console.log("Related parse hatasi:", e);
                    }
                }
            }
        };
        var url = "http://192.168.8.137:8888/api/v1/related/" + videoId + "?title=" + encodeURIComponent(initialTitle);
        xhr.open("GET", url);
        xhr.send();
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

    function skipTime(deltaMs) {
        var newPos = (videoPlayer.position + deltaMs);
        if (newPos < 0) {
            newPos = 0;
        }
        if (videoPlayer.duration > 0 && newPos > videoPlayer.duration) {
            newPos = videoPlayer.duration;
        }
        videoPlayer.position = newPos;

        if (deltaMs > 0) {
            forwardSkipBadge.showBadge("+10s ▶▶");
        } else {
            rewindSkipBadge.showBadge("◀◀ -10s");
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

    // Video Container
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

        // Yukleniyor Gostergesi
        BusyIndicator {
            anchors.centerIn: parent
            running: (videoPlayer.status === 1 || videoPlayer.status === 2 || (isPlaying == false && videoPlayer.position == 0))
            visible: running
            platformStyle: BusyIndicatorStyle { size: "large" }
        }

        // Cift Dokunma ve Kontrol Alanlari
        Item {
            anchors.fill: parent

            // Sol Yari (Geri 10sn Atlama)
            MouseArea {
                id: leftTapArea
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                width: (parent.width / 2)

                property int clickCount: 0

                onClicked: {
                    clickCount = (clickCount + 1);
                    if (clickCount == 1) {
                        leftTimer.restart();
                    } else if (clickCount >= 2) {
                        leftTimer.stop();
                        clickCount = 0;
                        skipTime(-10000);
                    }
                }

                Timer {
                    id: leftTimer
                    interval: 280
                    repeat: false
                    onTriggered: {
                        leftTapArea.clickCount = 0;
                        toggleControls();
                    }
                }
            }

            // Sag Yari (Ileri 10sn Atlama)
            MouseArea {
                id: rightTapArea
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.right: parent.right
                width: (parent.width / 2)

                property int clickCount: 0

                onClicked: {
                    clickCount = (clickCount + 1);
                    if (clickCount == 1) {
                        rightTimer.restart();
                    } else if (clickCount >= 2) {
                        rightTimer.stop();
                        clickCount = 0;
                        skipTime(10000);
                    }
                }

                Timer {
                    id: rightTimer
                    interval: 280
                    repeat: false
                    onTriggered: {
                        rightTapArea.clickCount = 0;
                        toggleControls();
                    }
                }
            }
        }

        // 10sn Atlama Rozetleri (Animasyonlu)
        Rectangle {
            id: rewindSkipBadge
            anchors.left: parent.left
            anchors.leftMargin: 30
            anchors.verticalCenter: parent.verticalCenter
            width: 90
            height: 44
            radius: 22
            color: "#B0000000"
            border.color: "#FFFFFF"
            border.width: 1
            visible: false

            Text {
                id: rewindTxt
                anchors.centerIn: parent
                text: "◀◀ -10s"
                color: "#FFFFFF"
                font.pixelSize: 14
                font.bold: true
                font.family: "Nokia Pure Text"
            }

            Timer {
                id: rewindTimer
                interval: 700
                onTriggered: rewindSkipBadge.visible = false
            }

            function showBadge(msg) {
                rewindTxt.text = msg;
                rewindSkipBadge.visible = true;
                rewindTimer.restart();
            }
        }

        Rectangle {
            id: forwardSkipBadge
            anchors.right: parent.right
            anchors.rightMargin: 30
            anchors.verticalCenter: parent.verticalCenter
            width: 90
            height: 44
            radius: 22
            color: "#B0000000"
            border.color: "#FFFFFF"
            border.width: 1
            visible: false

            Text {
                id: forwardTxt
                anchors.centerIn: parent
                text: "+10s ▶▶"
                color: "#FFFFFF"
                font.pixelSize: 14
                font.bold: true
                font.family: "Nokia Pure Text"
            }

            Timer {
                id: forwardTimer
                interval: 700
                onTriggered: forwardSkipBadge.visible = false
            }

            function showBadge(msg) {
                forwardTxt.text = msg;
                forwardSkipBadge.visible = true;
                forwardTimer.restart();
            }
        }

        // Kontroller Katmani
        Item {
            id: controlsOverlay
            anchors.fill: parent
            visible: controlsVisible

            // Ust Bar (Tam Ekran Baslik)
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

                // OYNAT / DURDUR BUTONU
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
                        anchors.fill: parent
                        onClicked: {
                            togglePlay();
                        }
                    }
                }

                Text {
                    id: timeCurrentTxt
                    anchors.left: playPauseBtn.right
                    anchors.leftMargin: 8
                    anchors.verticalCenter: parent.verticalCenter
                    text: formatTime(videoPlayer.position)
                    color: "#FFFFFF"
                    font.pixelSize: 13
                    font.family: "Nokia Pure Text"
                }

                // Tam Ekran Butonu
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
                    anchors.rightMargin: 8
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
                            var targetPos = Math.floor(value);
                            console.log(">>> [GoTube v2] Seek: " + targetPos);
                            videoPlayer.position = targetPos;
                        }
                    }
                }
            }
        }
    }

    // Video Detaylari ve Ilgili Videolar (Flickable)
    Flickable {
        id: detailsFlickable
        anchors.top: videoBox.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        visible: (isFullscreen == false)
        contentWidth: width
        contentHeight: (detailsCol.height + 60)
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

            // Baslik
            Text {
                text: initialTitle
                width: parent.width
                color: "#FFFFFF"
                font.pixelSize: 19
                font.bold: true
                font.family: "Nokia Pure Text"
                wrapMode: Text.Wrap
            }

            // Kanal Bilgisi (Tiklanabilir Kanal Sayfasi)
            Item {
                width: parent.width
                height: 32

                Row {
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 8

                    Rectangle {
                        width: 26
                        height: 26
                        radius: 13
                        color: "#E50914"
                        anchors.verticalCenter: parent.verticalCenter
                        Text {
                            anchors.centerIn: parent
                            text: "▶"
                            color: "#FFFFFF"
                            font.pixelSize: 12
                        }
                    }
                    Text {
                        text: initialAuthor
                        color: "#E0E0E0"
                        font.pixelSize: 15
                        font.family: "Nokia Pure Text"
                        font.bold: true
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Text {
                        text: "• Kanala Git ›"
                        color: "#888888"
                        font.pixelSize: 13
                        font.family: "Nokia Pure Text"
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        pageStack.push(Qt.resolvedUrl("ChannelPage.qml"), {
                            channelTitle: initialAuthor
                        });
                    }
                }
            }

            // Aksiyon Butonlari (Sadece Ses, Kalite, Hiz, Indir)
            Grid {
                columns: 2
                spacing: 10
                width: parent.width

                // 1. Sadece Ses Cipi
                Rectangle {
                    width: ((parent.width - 10) / 2)
                    height: 42
                    radius: 21
                    color: (audioOnlyMode ? "#E50914" : "#1C1C1C")
                    border.color: (audioOnlyMode ? "#E50914" : "#333333")
                    border.width: 1

                    Row {
                        anchors.centerIn: parent
                        spacing: 6
                        Text {
                            text: "♪"
                            color: "#FFFFFF"
                            font.pixelSize: 16
                            font.bold: true
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        Text {
                            text: (audioOnlyMode ? "Video Modu" : "Sadece Ses")
                            color: "#FFFFFF"
                            font.pixelSize: 13
                            font.bold: true
                            font.family: "Nokia Pure Text"
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            audioOnlyMode = (audioOnlyMode ? false : true);
                        }
                    }
                }

                // 2. Kalite Secici Cipi (360p / 720p HD)
                Rectangle {
                    width: ((parent.width - 10) / 2)
                    height: 42
                    radius: 21
                    color: (currentQuality == "720p" ? "#0D47A1" : "#1C1C1C")
                    border.color: (currentQuality == "720p" ? "#1976D2" : "#333333")
                    border.width: 1

                    Row {
                        anchors.centerIn: parent
                        spacing: 6
                        Text {
                            text: "HD"
                            color: (currentQuality == "720p" ? "#FFFFFF" : "#AAAAAA")
                            font.pixelSize: 14
                            font.bold: true
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        Text {
                            text: currentQuality
                            color: "#FFFFFF"
                            font.pixelSize: 13
                            font.bold: true
                            font.family: "Nokia Pure Text"
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            switchQuality();
                        }
                    }
                }

                // 3. Oynatma Hizi Cipi (0.75x, 1x, 1.25x, 1.5x, 2x)
                Rectangle {
                    width: ((parent.width - 10) / 2)
                    height: 42
                    radius: 21
                    color: (currentSpeed != 1.0 ? "#D84315" : "#1C1C1C")
                    border.color: (currentSpeed != 1.0 ? "#FF5722" : "#333333")
                    border.width: 1

                    Row {
                        anchors.centerIn: parent
                        spacing: 6
                        Text {
                            text: "⚡"
                            color: "#FFFFFF"
                            font.pixelSize: 14
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        Text {
                            text: "Hiz: " + currentSpeed + "x"
                            color: "#FFFFFF"
                            font.pixelSize: 13
                            font.bold: true
                            font.family: "Nokia Pure Text"
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            cycleSpeed();
                        }
                    }
                }

                // 4. Indir Butonu
                Rectangle {
                    width: ((parent.width - 10) / 2)
                    height: 42
                    radius: 21
                    color: "#1C1C1C"
                    border.color: "#333333"
                    border.width: 1

                    Row {
                        anchors.centerIn: parent
                        spacing: 6
                        Text {
                            text: "↓"
                            color: "#FFFFFF"
                            font.pixelSize: 18
                            font.bold: true
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        Text {
                            text: "Indir (MP4)"
                            color: "#FFFFFF"
                            font.pixelSize: 13
                            font.bold: true
                            font.family: "Nokia Pure Text"
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            youtubeClient.startDownload(currentStreamUrl, initialTitle);
                            banner.show("Indirme baslatildi (/home/user/MyDocs/Videos)");
                        }
                    }
                }
            }

            // Ayrac Cizgisi
            Rectangle {
                width: parent.width
                height: 1
                color: "#252525"
            }

            // Siradaki / Ilgili Videolar Basligi
            Row {
                spacing: 8
                Rectangle {
                    width: 4
                    height: 18
                    radius: 2
                    color: "#E50914"
                    anchors.verticalCenter: parent.verticalCenter
                }
                Text {
                    text: "Siradaki ve Ilgili Videolar"
                    color: "#FFFFFF"
                    font.pixelSize: 17
                    font.bold: true
                    font.family: "Nokia Pure Text"
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            // Ilgili Videolar Listesi
            Repeater {
                model: relatedVideos
                delegate: Rectangle {
                    width: detailsCol.width
                    height: 72
                    radius: 8
                    color: "#121212"

                    Row {
                        anchors.fill: parent
                        anchors.margins: 6
                        spacing: 10

                        // Kucuk Resim
                        Rectangle {
                            width: 88
                            height: 60
                            radius: 4
                            color: "#000000"
                            clip: true
                            anchors.verticalCenter: parent.verticalCenter

                            Image {
                                anchors.fill: parent
                                fillMode: Image.PreserveAspectCrop
                                source: (modelData.videoThumbnails && modelData.videoThumbnails.length > 0 ? modelData.videoThumbnails[0].url : "")
                            }
                        }

                        // Video Basligi ve Kanali
                        Column {
                            width: (parent.width - 104)
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 4

                            Text {
                                text: modelData.title
                                width: parent.width
                                color: "#FFFFFF"
                                font.pixelSize: 13
                                font.bold: true
                                font.family: "Nokia Pure Text"
                                elide: Text.ElideRight
                                maximumLineCount: 2
                                wrapMode: Text.Wrap
                            }

                            Text {
                                text: modelData.author
                                width: parent.width
                                color: "#888888"
                                font.pixelSize: 12
                                font.family: "Nokia Pure Text"
                                elide: Text.ElideRight
                            }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            videoPlayer.stop();
                            pageStack.replace(Qt.resolvedUrl("PlayerPage.qml"), {
                                videoId: modelData.videoId,
                                initialTitle: modelData.title,
                                initialAuthor: modelData.author
                            });
                        }
                    }
                }
            }
        }
    }

    // Bilgilendirme Rozeti
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
