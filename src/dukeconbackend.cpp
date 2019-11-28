/*
 * harbour-watchlist - Sailfish OS Version
 * Copyright © 2019 Andreas Wüst (andreas.wuest.freelancer@gmail.com)
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */
#include "dukeconbackend.h"

#include <QDebug>
#include <QFile>
#include <QUrl>
#include <QUrlQuery>
#include <QUuid>
#include <QCryptographicHash>
#include <QStandardPaths>
#include <QJsonObject>
#include <QJsonArray>
#include <QDateTime>
#include <QSqlDatabase>
#include <QSqlError>
#include <QSqlQueryModel>
#include <QCryptographicHash>
#include <QtDBus/QDBusConnection>
#include <QtDBus/QDBusInterface>


//const char SINGLE_INIT_URL = "https://programm.javaland.eu/2019/rest/init.json";
//const char SINGLE_CONF_DATA_URL = "https://programm.javaland.eu/2019/rest/image-resources.json";
//const char SINGLE_IMAGES_BASE_URL ="https://programm.javaland.eu/2019/rest/speaker/images/";

DukeconBackend::DukeconBackend(QNetworkAccessManager *manager, const QString &applicationName, const QString applicationVersion, QObject *parent) : QObject(parent) {
    qDebug() << "Initializing Dukecon Backend...";
    this->manager = manager;
    this->applicationName = applicationName;
    this->applicationVersion = applicationVersion;
}

DukeconBackend::~DukeconBackend() {
    qDebug() << "Shutting down Dukecon Backend...";
}

QNetworkReply *DukeconBackend::executeGetRequest(const QUrl &url) {
    qDebug() << "DukeconBackend::executeGetRequest " << url;
    QNetworkRequest request(url);
    request.setHeader(QNetworkRequest::ContentTypeHeader, MIME_TYPE_JSON);
    // TODO ETAG

    return manager->get(request);
}

QNetworkReply *DukeconBackend::executeGetRequestNonJson(const QUrl &url) {
    qDebug() << "DukeconBackend::executeGetRequest " << url;
    QNetworkRequest request(url);
    request.setHeader(QNetworkRequest::ContentTypeHeader, MIME_TYPE_JSON);
    // TODO ETAG

    return manager->get(request);
}


void DukeconBackend::downloadAllData(const bool singleConference, const QString &conferenceId, const QString &etag) {
    qDebug() << "DukeconBackend::downloadConferenceData";

    this->singleConference = singleConference;

    QUrl initUrl;
    if (singleConference) {
        initUrl = QUrl(SINGLE_INIT_URL);
    } else {
        // TODO
    }

    emit subLoadingLabelAvailable(QString(tr("Init Data")));

    // TODO etag
    QNetworkReply *reply = executeGetRequest(initUrl);

    connect(reply, SIGNAL(error(QNetworkReply::NetworkError)), this, SLOT(handleRequestError(QNetworkReply::NetworkError)), Qt::UniqueConnection);
    connect(reply, SIGNAL(finished()), this, SLOT(handleInitDataFinished()), Qt::UniqueConnection);
}

void DukeconBackend::handleInitDataFinished() {
    qDebug() << "DukeconBackend::handleInitDataFinished";
    QNetworkReply *reply = qobject_cast<QNetworkReply *>(sender());
    reply->deleteLater();
    if (reply->error() != QNetworkReply::NoError) {
        return;
    }

    const QString etag = getEtagValue(reply);
    const QByteArray responseData = reply->readAll();

    const QJsonDocument jsonDocument = QJsonDocument::fromJson(responseData);
    const QJsonObject rootObject = jsonDocument.object();
    //dataMap.insert("id", rootObject["id"].toString());
    QString conferenceId = rootObject["id"].toString();
    this->currentConferenceId = conferenceId;


    QMap<QString, QString> dataMap = getBaseConferenceData(conferenceId);
    dataMap.insert("name", rootObject["name"].toString());
    dataMap.insert("year", rootObject["year"].toString());
    dataMap.insert("startDate", rootObject["startDate"].toString());
    dataMap.insert("endDate", rootObject["endDate"].toString());
    dataMap.insert("state", "ACTIVE");
//    dataMap.insert("etag", etag);
//    dataMap.insert("content", ""); // TODO

    persistConferenceData(dataMap);

//    emit initDataResultAvailable(processResponses(reply->readAll()));

    QUrl confDataUrl;
    if (this->singleConference) {
        confDataUrl = QUrl(SINGLE_IMAGE_RESOURCES_URL);
    } else {
        // TODO
    }

    emit subLoadingLabelAvailable(QString(tr("Image Resources")));

    // TODO etag
    reply = executeGetRequest(confDataUrl);

    connect(reply, SIGNAL(error(QNetworkReply::NetworkError)), this, SLOT(handleRequestError(QNetworkReply::NetworkError)), Qt::UniqueConnection);
    connect(reply, SIGNAL(finished()), this, SLOT(handleImagesResourcesFinished()), Qt::UniqueConnection);
}

void DukeconBackend::handleImagesResourcesFinished() {
    qDebug() << "DukeconBackend::handleImagesResourcesFinished";
    QNetworkReply *reply = qobject_cast<QNetworkReply *>(sender());
    reply->deleteLater();
    if (reply->error() != QNetworkReply::NoError) {
        return;
    }

    QString etag = getEtagValue(reply);
    QMap<QString, QString> dataMap = getBaseConferenceResource(this->currentConferenceId, "conferenceImage");
    dataMap.insert("etag", etag);
    dataMap.insert("content", QString(reply->readAll()));
    persistConferenceResource(dataMap);

//    emit imageResourcesResultAvailable(processResponses(reply->readAll()));

    QUrl confDataUrl;
    if (this->singleConference) {
        confDataUrl = QUrl(SINGLE_CONF_DATA_URL);
    } else {
        // TODO
    }

    emit subLoadingLabelAvailable(QString(tr("Conference Data")));

    // TODO etag
    reply = executeGetRequestNonJson(confDataUrl);

    connect(reply, SIGNAL(error(QNetworkReply::NetworkError)), this, SLOT(handleRequestError(QNetworkReply::NetworkError)), Qt::UniqueConnection);
    connect(reply, SIGNAL(finished()), this, SLOT(handleConferenceDataFinished()), Qt::UniqueConnection);
}


void DukeconBackend::handleConferenceDataFinished() {
    qDebug() << "DukeconBackend::handleConferenceDataFinished";
    QNetworkReply *reply = qobject_cast<QNetworkReply *>(sender());
    reply->deleteLater();
    if (reply->error() != QNetworkReply::NoError) {
        return;
    }

    QString etag = getEtagValue(reply);
    const QByteArray responseData = reply->readAll();

    QMap<QString, QString> dataMap = getBaseConferenceData(this->currentConferenceId);
//    dataMap.insert("name", rootObject["name"].toString());
//    dataMap.insert("year", rootObject["year"].toString());
//    dataMap.insert("startDate", rootObject["startDate"].toString());
//    dataMap.insert("endDate", rootObject["endDate"].toString());
//    dataMap.insert("state", "ACTIVE");
    dataMap.insert("etag", etag);
    dataMap.insert("content", QString(responseData));

    persistConferenceData(dataMap);


    // emit conferenceDataResultAvailable(processResponses(responseData));

    const QJsonDocument jsonDocument = QJsonDocument::fromJson(responseData);
    const QJsonObject rootObject = jsonDocument.object();
    const QJsonArray speakersArray = rootObject["speakers"].toArray();

    foreach (const QJsonValue &speaker, speakersArray) {
        const QJsonObject speakerObject = speaker.toObject();
        const QString photoId = speakerObject["photoId"].toString();
        if (!photoId.isEmpty()) {
            this->photoIds.append(photoId);
        }
    }

    this->speakerImageCount = photoIds.length();

    fetchPhotoImages();
}

void DukeconBackend::fetchPhotoImages() {
    if (photoIds.length() > 0) { // > 0
        this->currentPhotoId = photoIds.first();
        photoIds.removeFirst();

        QUrl photoIdUrl;
        if (this->singleConference) {
            photoIdUrl = QUrl(SINGLE_IMAGES_BASE_URL + this->currentPhotoId);
        } else {
            // TODO
        }

        emit subLoadingLabelAvailable(QString(tr("Speaker Image (%1/%2)"))
                                      .arg(speakerImageCount - photoIds.length())
                                      .arg(this->speakerImageCount));

        // TODO etag
        QNetworkReply *reply = executeGetRequest(photoIdUrl);
        connect(reply, SIGNAL(error(QNetworkReply::NetworkError)), this, SLOT(handleRequestError(QNetworkReply::NetworkError)), Qt::UniqueConnection);
        connect(reply, SIGNAL(finished()), this, SLOT(handlePhotoIdFinished()), Qt::UniqueConnection);
    } else {
        cleanupDownloadData();
        emit loadingDataFinished();
    }
}

void DukeconBackend::cleanupDownloadData() {
    this->speakerImageCount = -1;
    this->photoIds.clear();
    this->currentPhotoId = nullptr;
}

void DukeconBackend::handlePhotoIdFinished() {
    qDebug() << "DukeconBackend::handlePhotoIdFinished";
    QNetworkReply *reply = qobject_cast<QNetworkReply *>(sender());
    reply->deleteLater();
    if (reply->error() != QNetworkReply::NoError) {
        return;
    }

    QString etag = getEtagValue(reply);

    QByteArray imageByteArray(reply->readAll());
    //QString imageAsBase64 = QString();
    QByteArray photoAsBase64ByteArray = imageByteArray.toBase64();
    //qDebug() << "DukeconBackend::handlePhotoIdFinished - imagebase64 : " << imageAsBase64.left(imageAsBase64.length() > 80 ? 80 : imageAsBase64.length());

    QMap<QString, QString> dataMap = getBaseConferenceResource(this->currentConferenceId, this->currentPhotoId);
    dataMap.insert("etag", etag);
    dataMap.insert("content", QString("data:image/png;base64," + photoAsBase64ByteArray));

    persistConferenceResource(dataMap);

//    emit speakerImageResultAvailable("data:image/png;base64," + processResponses(photoAsBase64ByteArray), this->currentPhotoId);

    fetchPhotoImages();
}


QString DukeconBackend::processResponses(QByteArray searchReply) {
    QString result = QString(searchReply);
    qDebug() << "DukeconBackend::processResponses - data : " << result.left(result.length() > 80 ? 80 : result.length());
    return result;
}

QString DukeconBackend::getEtagValue(QNetworkReply *reply) {
    QString etag = reply->rawHeader("ETag");
    qDebug() << "ETag was " << etag;
    return etag;
}

QMap<QString, QString> DukeconBackend::getBaseConferenceResource(QString conferenceId, QString resourceId) {
    QSqlDatabase db = QSqlDatabase::addDatabase("QSQLITE");
    db.setDatabaseName(databasePath);

    QMap<QString, QString> dataMap;
    dataMap.insert("conferenceId", conferenceId);
    dataMap.insert("resourceId", resourceId);

    if(db.open()){
        QSqlQuery query;
        query.prepare("SELECT conferenceId, resourceId, resourceType, etag FROM conference_resources WHERE conferenceId LIKE :conferenceId AND resourceId LIKE :resourceId");
        query.bindValue(":conferenceId", conferenceId);
        query.bindValue(":resourceId", resourceId);

        if (query.exec()) {
            qDebug() << "siezu : " << query.size();
        } else {
            qDebug() << "query failed" << query.lastError();
        }

        qDebug() << "siezu : " << query.size();

        if (query.next()) {
//            dataMap.insert("conferenceId", query.value("conferenceId").toString());
            // dataMap.insert("resourceId", query.value("resourceId").toString());
            dataMap.insert("resourceType", query.value("resourceType").toString());
            dataMap.insert("etag", query.value("etag").toString());
        } else {
            qDebug() << "no data found !" << query.lastError();
        }

        db.close();
    } else {
        qDebug() << "failed to open database";
    }

    return dataMap;
}

QMap<QString, QString> DukeconBackend::getBaseConferenceData(QString conferenceId) {
    QSqlDatabase db = QSqlDatabase::addDatabase("QSQLITE");
    db.setDatabaseName(databasePath);

    QMap<QString, QString> dataMap;
    dataMap.insert("id", conferenceId);

    if(db.open()){
        QSqlQuery query;
//        query.prepare("SELECT id, name, year, startDate, endDate, content, etag, state FROM conference WHERE id LIKE :conferenceId");
//        query.bindValue(":conferenceId", conferenceId);
        query.prepare("SELECT id, name, year, startDate, endDate, content, etag, state FROM conference WHERE id LIKE :conferenceId");
        query.bindValue(":conferenceId", conferenceId);
        if (query.exec()) {
            qDebug() << "siezu : " << query.size();
        } else {
            qDebug() << "query failed" << query.lastError();
        }

        //    dataMap.insert("name", rootObject["name"].toString());
        //    dataMap.insert("year", rootObject["year"].toString());
        //    dataMap.insert("startDate", rootObject["startDate"].toString());
        //    dataMap.insert("endDate", rootObject["endDate"].toString());
        //    dataMap.insert("state", "ACTIVE");

        qDebug() << "siezu : " << query.size();

        if (query.next()) {
            dataMap.insert("id", query.value("id").toString());
            dataMap.insert("name", query.value("name").toString());
            dataMap.insert("year", query.value("year").toString());
            dataMap.insert("startDate", query.value("startDate").toString());
            dataMap.insert("endDate", query.value("endDate").toString());
            dataMap.insert("content", query.value("content").toString());
            dataMap.insert("etag", query.value("etag").toString());
            dataMap.insert("state", query.value("state").toString());
        }

        db.close();
    } else {
        qDebug() << "failed to open database";
    }

    return dataMap;
}

void DukeconBackend::persistConferenceResource(QMap<QString, QString> dataMap) {
    QSqlDatabase db = QSqlDatabase::addDatabase("QSQLITE");
    db.setDatabaseName(databasePath);

    if(db.open()){
        QSqlQuery query;
        query.prepare(QString("INSERT OR REPLACE INTO conference_resources(conferenceId, resourceId, resourceType, etag, content) ")
                      + QString("VALUES (:conferenceId, :resourceId, :resourceType, :etag, :content)"));
        query.bindValue(":conferenceId", dataMap["conferenceId"]);
        query.bindValue(":resourceId", dataMap["resourceId"]);
        query.bindValue(":resourceType", dataMap["resourceType"]);
        query.bindValue(":etag", dataMap["etag"]);
        query.bindValue(":content", dataMap["content"]);

        if(!query.exec()) {
            qDebug() << "SQL Statement Error" << query.lastError();
        }

        db.commit();
        db.close();
    } else{
        qDebug() << "Cant open DB";
    }
}

void DukeconBackend::persistConferenceData(QMap<QString, QString> dataMap) {
    QSqlDatabase db = QSqlDatabase::addDatabase("QSQLITE");
    db.setDatabaseName(databasePath);

    if(db.open()){
        QSqlQuery query;
        query.prepare(QString("INSERT OR REPLACE INTO conference(id, name, year, url, homeUrl, startDate, endDate, state, content, etag) ")
                      + QString("VALUES (:id, :name, :year, :url, :homeUrl, :startDate, :endDate, :state, :content, :etag)"));
        query.bindValue(":id", dataMap["id"]);
        query.bindValue(":name", dataMap["name"]);
        query.bindValue(":year", dataMap["year"]);
        query.bindValue(":url", dataMap["url"]);
        query.bindValue(":startDate", dataMap["startDate"]);
        query.bindValue(":endDate", dataMap["endDate"]);
        query.bindValue(":state", dataMap["state"]);
        query.bindValue(":content", dataMap["content"]);
        query.bindValue(":etag", dataMap["etag"]);

        if(!query.exec()) {
            qDebug() << "SQL Statement Error" << query.lastError();
        }

        db.commit();
        db.close();

//        QSqlQueryModel* modal = new QSqlQueryModel();
//        QSqlQuery *query = new QSqlQuery(db);
//        query->prepare("Select id, name FROM conference");
//        query->exec();

//        while (query->next()) {
//            QString id = query->value(0).toString();
//            QString name = query->value(1).toString();
//            qDebug() << name << id;
//        }
    } else{
        qDebug() << "Cant open DB";
    }
}

void DukeconBackend::handleRequestError(QNetworkReply::NetworkError error) {
    QNetworkReply *reply = qobject_cast<QNetworkReply *>(sender());
    qWarning() << "DukeconBackend::handleRequestError:" << (int)error << reply->errorString() << reply->readAll();

    cleanupDownloadData();

    emit requestError("Return code: " + QString::number((int)error) + " - " + reply->errorString());
}





