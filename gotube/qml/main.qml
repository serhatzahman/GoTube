import QtQuick 1.1
import com.nokia.meego 1.0
import "pages"

PageStackWindow {
    id: appWindow
    initialPage: HomePage {}

    // Global Harmattan Toolbar
    ToolBarLayout {
        id: commonTools
        visible: true

        ToolIcon {
            iconId: "toolbar-home"
            onClicked: {
                if (pageStack.depth > 1) {
                    pageStack.pop(null);
                }
            }
        }

        ToolIcon {
            iconId: "toolbar-search"
            onClicked: {
                pageStack.push(Qt.resolvedUrl("pages/SearchPage.qml"));
            }
        }

        ToolIcon {
            iconId: "toolbar-directory"
            onClicked: {
                pageStack.push(Qt.resolvedUrl("pages/DownloadsPage.qml"));
            }
        }

        ToolIcon {
            iconId: "toolbar-view-menu"
            onClicked: mainMenu.open()
        }
    }

    // App Menu
    Menu {
        id: mainMenu
        visualParent: pageStack
        MenuLayout {
            MenuItem {
                text: "İndirilenler"
                onClicked: pageStack.push(Qt.resolvedUrl("pages/DownloadsPage.qml"))
            }
            MenuItem {
                text: "Sunucu (Instance) Ayarı"
                onClicked: instanceDialog.open()
            }
            MenuItem {
                text: "Hakkında"
                onClicked: aboutDialog.open()
            }
        }
    }

    // Server Instance Dialog
    Dialog {
        id: instanceDialog
        title: Text {
            text: "Invidious Sunucu Adresi"
            color: "#FFFFFF"
            font.pixelSize: 22
            font.bold: true
        }

        content: Column {
            width: parent.width
            spacing: 10

            Text {
                text: "Mevcut: " + youtubeClient.instanceUrl
                color: "#AAAAAA"
                font.pixelSize: 14
                wrapMode: Text.Wrap
                width: parent.width
            }

            Rectangle {
                width: parent.width
                height: 48
                radius: 8
                color: "#222222"
                border.color: "#444444"

                TextInput {
                    id: serverInput
                    anchors.fill: parent
                    anchors.margins: 10
                    text: youtubeClient.instanceUrl
                    color: "#FFFFFF"
                    font.pixelSize: 16
                }
            }
        }

        buttons: ButtonRow {
            style: ButtonStyle {}
            Button {
                text: "Kaydet"
                onClicked: {
                    youtubeClient.instanceUrl = serverInput.text;
                    instanceDialog.accept();
                }
            }
            Button {
                text: "İptal"
                onClicked: instanceDialog.reject()
            }
        }
    }

    // About Dialog
    QueryDialog {
        id: aboutDialog
        titleText: "GoTube Hakkında"
        message: "GoTube - Nokia N9 (MeeGo 1.2 Harmattan)\n\nYouTube videolarını reklamsız oynatan, arka planda ses çalabilen ve MP4 indirme desteği sunan açık kaynaklı istemci.\n\nQt 4.7 & Invidious API."
        acceptButtonText: "Tamam"
    }
}
