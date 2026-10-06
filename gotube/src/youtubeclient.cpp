#include "youtubeclient.h"
#include <QNetworkRequest>
#include <QUrl>
#include <QScriptEngine>
#include <QScriptValue>
#include <QDir>
#include <QFileInfo>
#include <QDateTime>
#include <QDebug>

YouTubeClient::YouTubeClient(QObject *parent) :
    QObject(parent),
    m_nam(new QNetworkAccessManager(this)),
    m_instanceUrl("https://inv.tux.pizza"),
    m_isLoading(false),
    m_downloadReply(NULL),
    m_downloadFile(NULL)
{
}

YouTubeClient::~YouTubeClient()
{
    if (m_downloadFile) {
        if (m_downloadFile->isOpen()) {
            m_downloadFile->close();
        }
        delete m_downloadFile;
    }
}

QString YouTubeClient::instanceUrl() const
{
    return m_instanceUrl;
}

void YouTubeClient::setInstanceUrl(const QString &url)
{
    QString trimmed = url.trimmed();
    if (trimmed.endsWith('/')) {
        trimmed.chop(1);
    }
    if (m_instanceUrl != trimmed) {
        m_instanceUrl = trimmed;
        emit instanceUrlChanged();
    }
}

bool YouTubeClient::isLoading() const
{
    return m_isLoading;
}

void YouTubeClient::setLoading(bool loading)
{
    if (m_isLoading != loading) {
        m_isLoading = loading;
        emit loadingChanged();
    }
}

QString YouTubeClient::getDownloadsDirectory() const
{
    // Nokia N9 default video directory
    QString targetDir = "/home/user/MyDocs/Videos";
    if (QDir(targetDir).exists()) {
        return targetDir;
    }
    // Fallback for development / desktop simulation
    QString fallbackDir = QDir::homePath() + "/Videos";
    if (!QDir(fallbackDir).exists()) {
        QDir().mkpath(fallbackDir);
    }
    return fallbackDir;
}

QVariant YouTubeClient::parseJson(const QByteArray &data)
{
    QScriptEngine engine;
    QString script = "(" + QString::fromUtf8(data) + ")";
    QScriptValue value = engine.evaluate(script);

    if (engine.hasUncaughtException()) {
        qWarning() << "JSON parsing error:" << engine.uncaughtException().toString();
        return QVariant();
    }

    return value.toVariant();
}

void YouTubeClient::fetchTrending()
{
    setLoading(true);
    QUrl url(m_instanceUrl + "/api/v1/trending?type=music");
    QNetworkRequest request(url);
    request.setRawHeader("User-Agent", "GoTube-MeeGo/1.0 (Nokia N9; Harmattan)");

    QNetworkReply *reply = m_nam->get(request);
    connect(reply, SIGNAL(finished()), this, SLOT(onTrendingReply()));
}

void YouTubeClient::onTrendingReply()
{
    setLoading(false);
    QNetworkReply *reply = qobject_cast<QNetworkReply*>(sender());
    if (!reply) return;

    if (reply->error() == QNetworkReply::NoError) {
        QByteArray data = reply->readAll();
        QVariant parsed = parseJson(data);
        if (parsed.type() == QVariant::List) {
            emit trendingLoaded(parsed.toList());
        } else {
            emit errorOccurred("Geçersiz trend veri formatı");
        }
    } else {
        emit errorOccurred("Ağ hatası: " + reply->errorString());
    }
    reply->deleteLater();
}

void YouTubeClient::searchVideos(const QString &query)
{
    if (query.trimmed().isEmpty()) return;

    setLoading(true);
    QString encodedQuery = QString::fromUtf8(QUrl::toPercentEncoding(query));
    QUrl url(m_instanceUrl + "/api/v1/search?q=" + encodedQuery + "&type=video");
    QNetworkRequest request(url);
    request.setRawHeader("User-Agent", "GoTube-MeeGo/1.0 (Nokia N9; Harmattan)");

    QNetworkReply *reply = m_nam->get(request);
    connect(reply, SIGNAL(finished()), this, SLOT(onSearchReply()));
}

void YouTubeClient::onSearchReply()
{
    setLoading(false);
    QNetworkReply *reply = qobject_cast<QNetworkReply*>(sender());
    if (!reply) return;

    if (reply->error() == QNetworkReply::NoError) {
        QByteArray data = reply->readAll();
        QVariant parsed = parseJson(data);
        if (parsed.type() == QVariant::List) {
            emit searchCompleted(parsed.toList());
        } else {
            emit errorOccurred("Geçersiz arama sonucu formatı");
        }
    } else {
        emit errorOccurred("Arama hatası: " + reply->errorString());
    }
    reply->deleteLater();
}

void YouTubeClient::fetchVideoDetails(const QString &videoId)
{
    setLoading(true);
    QUrl url(m_instanceUrl + "/api/v1/videos/" + videoId);
    QNetworkRequest request(url);
    request.setRawHeader("User-Agent", "GoTube-MeeGo/1.0 (Nokia N9; Harmattan)");

    QNetworkReply *reply = m_nam->get(request);
    connect(reply, SIGNAL(finished()), this, SLOT(onVideoDetailsReply()));
}

void YouTubeClient::onVideoDetailsReply()
{
    setLoading(false);
    QNetworkReply *reply = qobject_cast<QNetworkReply*>(sender());
    if (!reply) return;

    if (reply->error() == QNetworkReply::NoError) {
        QByteArray data = reply->readAll();
        QVariant parsed = parseJson(data);
        if (parsed.type() == QVariant::Map) {
            emit videoDetailsLoaded(parsed.toMap());
        } else {
            emit errorOccurred("Geçersiz video detay formatı");
        }
    } else {
        emit errorOccurred("Video detay hatası: " + reply->errorString());
    }
    reply->deleteLater();
}

void YouTubeClient::fetchChannel(const QString &channelId)
{
    setLoading(true);
    QUrl url(m_instanceUrl + "/api/v1/channels/" + channelId);
    QNetworkRequest request(url);
    request.setRawHeader("User-Agent", "GoTube-MeeGo/1.0 (Nokia N9; Harmattan)");

    QNetworkReply *reply = m_nam->get(request);
    connect(reply, SIGNAL(finished()), this, SLOT(onChannelReply()));
}

void YouTubeClient::onChannelReply()
{
    setLoading(false);
    QNetworkReply *reply = qobject_cast<QNetworkReply*>(sender());
    if (!reply) return;

    if (reply->error() == QNetworkReply::NoError) {
        QByteArray data = reply->readAll();
        QVariant parsed = parseJson(data);
        if (parsed.type() == QVariant::Map) {
            emit channelLoaded(parsed.toMap());
        } else {
            emit errorOccurred("Geçersiz kanal verisi");
        }
    } else {
        emit errorOccurred("Kanal yükleme hatası: " + reply->errorString());
    }
    reply->deleteLater();
}

void YouTubeClient::startDownload(const QString &streamUrl, const QString &fileName)
{
    if (m_downloadReply) {
        emit errorOccurred("Şu anda devam eden bir indirme var.");
        return;
    }

    QString targetDir = getDownloadsDirectory();

    QString safeName = fileName;
    safeName.replace(QRegExp("[\\\\/:*?\"<>|]"), "_");
    if (!safeName.endsWith(".mp4", Qt::CaseInsensitive)) {
        safeName += ".mp4";
    }

    m_downloadPath = targetDir + "/" + safeName;
    m_downloadFile = new QFile(m_downloadPath);

    if (!m_downloadFile->open(QIODevice::WriteOnly)) {
        emit errorOccurred("Dosya açılamadı: " + m_downloadFile->errorString());
        delete m_downloadFile;
        m_downloadFile = NULL;
        return;
    }

    QNetworkRequest request((QUrl(streamUrl)));
    request.setRawHeader("User-Agent", "GoTube-MeeGo/1.0 (Nokia N9; Harmattan)");

    m_downloadReply = m_nam->get(request);
    connect(m_downloadReply, SIGNAL(readyRead()), this, SLOT(onDownloadReadyRead()));
    connect(m_downloadReply, SIGNAL(downloadProgress(qint64,qint64)), this, SLOT(onDownloadProgress(qint64,qint64)));
    connect(m_downloadReply, SIGNAL(finished()), this, SLOT(onDownloadReplyFinished()));
}

void YouTubeClient::onDownloadReadyRead()
{
    if (m_downloadFile && m_downloadReply) {
        m_downloadFile->write(m_downloadReply->readAll());
    }
}

void YouTubeClient::onDownloadProgress(qint64 received, qint64 total)
{
    emit downloadProgress(received, total);
}

void YouTubeClient::onDownloadReplyFinished()
{
    if (!m_downloadReply) return;

    if (m_downloadReply->error() == QNetworkReply::NoError) {
        if (m_downloadFile) {
            m_downloadFile->write(m_downloadReply->readAll());
            m_downloadFile->close();
            delete m_downloadFile;
            m_downloadFile = NULL;
        }
        emit downloadFinished(m_downloadPath);
        fetchLocalDownloads();
    } else {
        if (m_downloadFile) {
            m_downloadFile->close();
            m_downloadFile->remove();
            delete m_downloadFile;
            m_downloadFile = NULL;
        }
        emit errorOccurred("İndirme başarısız: " + m_downloadReply->errorString());
    }

    m_downloadReply->deleteLater();
    m_downloadReply = NULL;
}

void YouTubeClient::fetchLocalDownloads()
{
    QDir dir(getDownloadsDirectory());
    QStringList filters;
    filters << "*.mp4" << "*.m4v" << "*.mkv";

    QFileInfoList fileList = dir.entryInfoList(filters, QDir::Files, QDir::Time);
    QVariantList results;

    foreach (const QFileInfo &info, fileList) {
        QVariantMap item;
        item["fileName"] = info.fileName();
        item["title"] = info.completeBaseName();
        item["filePath"] = info.absoluteFilePath();
        qint64 bytes = info.size();
        double mb = bytes / (1024.0 * 1024.0);
        item["fileSize"] = QString::number(mb, 'f', 1) + " MB";
        item["modifiedDate"] = info.lastModified().toString("dd.MM.yyyy hh:mm");
        results.append(item);
    }

    emit localDownloadsLoaded(results);
}

void YouTubeClient::deleteLocalDownload(const QString &filePath)
{
    QFile file(filePath);
    if (file.exists()) {
        if (file.remove()) {
            fetchLocalDownloads();
        } else {
            emit errorOccurred("Dosya silinemedi: " + file.errorString());
        }
    }
}
