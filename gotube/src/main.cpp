#include <QtGui/QApplication>
#include <QtDeclarative/QDeclarativeView>
#include <QtDeclarative/QDeclarativeContext>
#include <QFile>
#include <QUrl>
#include "youtubeclient.h"

#ifdef HARMATTAN_BOOSTER
#include <MDeclarativeCache>
#endif

int main(int argc, char *argv[])
{
#ifdef HARMATTAN_BOOSTER
    QApplication *app = MDeclarativeCache::qApplication(argc, argv);
    QDeclarativeView *view = MDeclarativeCache::qDeclarativeView();
#else
    QApplication *app = new QApplication(argc, argv);
    QDeclarativeView *view = new QDeclarativeView();
#endif

    app->setApplicationName("GoTube");
    app->setOrganizationName("GoTube");

    YouTubeClient *client = new YouTubeClient(app);
    view->rootContext()->setContextProperty("youtubeClient", client);

    // Performance optimizations for Nokia N9 AMOLED display & PowerVR SGX530
    view->setAttribute(Qt::WA_OpaquePaintEvent);
    view->setAttribute(Qt::WA_NoSystemBackground);
    view->viewport()->setAttribute(Qt::WA_OpaquePaintEvent);
    view->viewport()->setAttribute(Qt::WA_NoSystemBackground);

    // Path resolution: installed path vs local development path
    QString qmlPath = "/opt/gotube/qml/main.qml";
    if (!QFile::exists(qmlPath)) {
        qmlPath = "qml/main.qml";
    }

    view->setSource(QUrl::fromLocalFile(qmlPath));

#if defined(MEEGO_EDITION_HARMATTAN) || defined(HARMATTAN_BOOSTER)
    view->showFullScreen();
#else
    view->resize(480, 854); // Nokia N9 FWVGA resolution
    view->show();
#endif

    return app->exec();
}
