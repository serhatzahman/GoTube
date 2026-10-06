#ifndef YOUTUBECLIENT_H
#define YOUTUBECLIENT_H

#include <QObject>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QVariantList>
#include <QVariantMap>
#include <QFile>

class YouTubeClient : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString instanceUrl READ instanceUrl WRITE setInstanceUrl NOTIFY instanceUrlChanged)
    Q_PROPERTY(bool isLoading READ isLoading NOTIFY loadingChanged)

public:
    explicit YouTubeClient(QObject *parent = 0);
    ~YouTubeClient();

    QString instanceUrl() const;
    void setInstanceUrl(const QString &url);

    bool isLoading() const;

    Q_INVOKABLE void fetchTrending();
    Q_INVOKABLE void searchVideos(const QString &query);
    Q_INVOKABLE void fetchVideoDetails(const QString &videoId);
    Q_INVOKABLE void fetchChannel(const QString &channelId);
    Q_INVOKABLE void startDownload(const QString &streamUrl, const QString &fileName);
    Q_INVOKABLE void fetchLocalDownloads();
    Q_INVOKABLE void deleteLocalDownload(const QString &filePath);

signals:
    void instanceUrlChanged();
    void loadingChanged();
    void trendingLoaded(const QVariantList &videos);
    void searchCompleted(const QVariantList &videos);
    void videoDetailsLoaded(const QVariantMap &video);
    void channelLoaded(const QVariantMap &channelData);
    void localDownloadsLoaded(const QVariantList &downloads);
    void downloadProgress(qint64 bytesReceived, qint64 bytesTotal);
    void downloadFinished(const QString &savedPath);
    void errorOccurred(const QString &errorMessage);

private slots:
    void onTrendingReply();
    void onSearchReply();
    void onVideoDetailsReply();
    void onChannelReply();
    void onDownloadReadyRead();
    void onDownloadProgress(qint64 received, qint64 total);
    void onDownloadReplyFinished();

private:
    void setLoading(bool loading);
    QVariant parseJson(const QByteArray &data);
    QString getDownloadsDirectory() const;

    QNetworkAccessManager *m_nam;
    QString m_instanceUrl;
    bool m_isLoading;

    QNetworkReply *m_downloadReply;
    QFile *m_downloadFile;
    QString m_downloadPath;
};

#endif // YOUTUBECLIENT_H
