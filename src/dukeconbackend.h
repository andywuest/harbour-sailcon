#ifndef DUKECONBACKEND_H
#define DUKECONBACKEND_H

#include <QObject>
#include <QNetworkReply>
#include <QNetworkAccessManager>
#include <QVariantMap>
#include <QJsonDocument>
#include <QSqlDatabase>
#include <QSqlQuery>
#include <QSqlTableModel>

const char MIME_TYPE_JSON[] = "application/json";

// single conf is currencly javaland2020
const char SINGLE_INIT_URL[] = "https://programm.javaland.eu/2020/rest/init.json";
const char SINGLE_IMAGE_RESOURCES_URL[] = "https://programm.javaland.eu/2020/rest/image-resources.json";
const char SINGLE_CONF_DATA_URL[] = "https://programm.javaland.eu/2020/rest/conferences/javaland2020";
const char SINGLE_IMAGES_BASE_URL[] ="https://programm.javaland.eu/2020/rest/speaker/images/";

class DukeconBackend : public QObject {
    Q_OBJECT
public:
    explicit DukeconBackend(QNetworkAccessManager *manager, const QString &applicationName, const QString applicationVersion, QObject *parent = 0);
    ~DukeconBackend();
    Q_INVOKABLE void downloadAllData(const bool singleConference, const QString &conferenceId);

    // signals for the qml part
    Q_SIGNAL void subLoadingLabelAvailable(const QString &reply);
    Q_SIGNAL void loadingDataFinished();
    Q_SIGNAL void requestError(const QString &errorMessage);

signals:

public slots:

private:

    QSqlDatabase db;
    bool singleConference = false;
    int speakerImageCount = -1;
    QString currentPhotoId;
    QString currentConferenceId;
    QList<QString> photoIds;

    QString applicationName;
    QString applicationVersion;
    QNetworkAccessManager *manager;

    QNetworkReply *executeGetRequest(const QUrl &url, const QString &etag);
    QNetworkReply *executeGetRequestNonJson(const QUrl &url, const QString &etag);

    void initializeDatabase();
    QString processResponses(QByteArray searchReply);
    int getHttpReturnCode(QNetworkReply *reply);
    QString getEtagValue(QNetworkReply *reply);
    void persistConferenceData(QMap<QString, QString> dataMap);
    void persistConferenceResource(QMap<QString, QString> dataMap);
    QMap<QString, QString> getBaseConferenceData(QString conferenceId);
    QMap<QString, QString> getBaseConferenceResource(QString conferenceId, QString resourceId);
    QString lookupEtagForConferenceData(QString conferenceId);
    QString lookupEtagForConferenceResource(QString conferenceId, QString resourceId);

    void fetchPhotoImages();
    void cleanupDownloadData();

private slots:
    void handleRequestError(QNetworkReply::NetworkError error);
    void handleInitDataFinished();
    void handleImagesResourcesFinished();
    void handleConferenceDataFinished();
    void handlePhotoIdFinished();

};

#endif // DUKECONBACKEND_H
