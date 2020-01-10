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
#include <sailfishapp.h>

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
#include <QCoreApplication>
#include <QQmlApplicationEngine>
#include <QtDBus/QDBusConnection>
#include <QtDBus/QDBusInterface>

DukeconBackend::DukeconBackend(QNetworkAccessManager *manager, const QString &applicationName, const QString applicationVersion, QObject *parent) : QObject(parent) {
    qDebug() << "Initializing Dukecon Backend...";
    this->manager = manager;
    this->applicationName = applicationName;
    this->applicationVersion = applicationVersion;

    db = QSqlDatabase::addDatabase("QSQLITE");
}

DukeconBackend::~DukeconBackend() {
    qDebug() << "Shutting down Dukecon Backend...";
}

QNetworkReply *DukeconBackend::executeGetRequest(const QUrl &url, const QString &etag) {
    qDebug() << "DukeconBackend::executeGetRequest " << url;
    QNetworkRequest request(url);
    request.setHeader(QNetworkRequest::ContentTypeHeader, MIME_TYPE_JSON);
    if (!etag.isEmpty())  {
        // request.setHeader(QNetworkRequest::IfNoneMatchHeader, QString()); TODO update with later QT api
        request.setRawHeader(QByteArray("If-None-Match"), etag.toUtf8());
    }
    return manager->get(request);
}

QNetworkReply *DukeconBackend::executeGetRequestNonJson(const QUrl &url, const QString &etag) {
    qDebug() << "DukeconBackend::executeGetRequest " << url;
    QNetworkRequest request(url);
    //    request.setHeader(QNetworkRequest::ContentTypeHeader, MIME_TYPE_JSON);
    if (!etag.isEmpty())  {
        // request.setHeader(QNetworkRequest::IfNoneMatchHeader, QString()); TODO update with later QT api
        request.setRawHeader(QByteArray("If-None-Match"), etag.toUtf8());
    }
    return manager->get(request);
}

QString DukeconBackend::resolveConferenceUrl(const bool singleConference, const QString &conferenceId, const QString &year, const QString &urlType) {
    if (singleConference) {
        QString conferenceKey = "";
        if (conferenceId.startsWith("javaland")) {
            conferenceKey = "javaland";
        } else if (conferenceId.startsWith("apex")) {
            conferenceKey = "apex";
        }

        QString url = CONFERENCES_MAP[conferenceKey][urlType].arg(year);
        qDebug() << "url is now " << url;

        return url;
    } else {
        // TODO
    }
    return QString("");
}

void DukeconBackend::downloadAllData(const bool singleConference, const QString &conferenceId, const QString &year) {
    qDebug() << "DukeconBackend::downloadAllData " << conferenceId << " " << year;

    this->singleConference = singleConference;
    this->currentConferenceYear = year;

    QUrl initUrl = QUrl(resolveConferenceUrl(singleConference, conferenceId, year, QString("SINGLE_INIT_URL")));

    emit subLoadingLabelAvailable(QString(tr("Init Data")));

    const QString etag = lookupEtagForConferenceData(conferenceId);
    QNetworkReply *reply = executeGetRequest(initUrl, etag);

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

    const QByteArray responseData = reply->readAll();
    const QJsonDocument jsonDocument = QJsonDocument::fromJson(responseData);
    const QJsonObject rootObject = jsonDocument.object();
    QString conferenceId = rootObject["id"].toString();
    this->currentConferenceId = conferenceId;

    QMap<QString, QString> dataMap = getBaseConferenceData(conferenceId);
    dataMap.insert("name", rootObject["name"].toString());
    dataMap.insert("year", rootObject["year"].toString());
    dataMap.insert("startDate", rootObject["startDate"].toString());
    dataMap.insert("endDate", rootObject["endDate"].toString());
    dataMap.insert("state", "ACTIVE");

    persistConferenceData(dataMap);

    QUrl confDataUrl = QUrl(resolveConferenceUrl(this->singleConference, this->currentConferenceId, this->currentConferenceYear, QString("SINGLE_IMAGE_RESOURCES_URL")));

//            ;
//    if (this->singleConference) {
//        confDataUrl = QUrl(SINGLE_IMAGE_RESOURCES_URL);
//    } else {
//        // TODO
//    }

    emit subLoadingLabelAvailable(QString(tr("Image Resources")));

    const QString etag = lookupEtagForConferenceResource(conferenceId, "conferenceImage");
    reply = executeGetRequest(confDataUrl, etag);

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

    const int httpReturnCode = getHttpReturnCode(reply);

    // if the conference data has not changed - there is no need to fetch the speaker images again!
    // TODO add const for th 304 return code as long as QT it does not provide (QNetworkRequest::IfModifiedSinceHeader)
    if (httpReturnCode == 304) {
        qDebug() << " => http return code for images resources of " << this->currentConferenceId << " was " << httpReturnCode << " nothing changed !";
    } else {
        QMap<QString, QString> dataMap = getBaseConferenceResource(this->currentConferenceId, "conferenceImage");
        dataMap.insert("etag", getEtagValue(reply));
        dataMap.insert("content", QString(reply->readAll()));
        persistConferenceResource(dataMap);
    }

    QUrl confDataUrl = QUrl(resolveConferenceUrl(this->singleConference, this->currentConferenceId, this->currentConferenceYear, QString("SINGLE_CONF_DATA_URL")));
//    if (this->singleConference) {
//        confDataUrl = QUrl(SINGLE_CONF_DATA_URL);
//    } else {
//        // TODO
//    }

    emit subLoadingLabelAvailable(QString(tr("Conference Data")));

    const QString etagValue = lookupEtagForConferenceData(this->currentConferenceId);
    reply = executeGetRequestNonJson(confDataUrl, etagValue);

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

    const int httpReturnCode = getHttpReturnCode(reply);

    // if the conference data has not changed - there is no need to fetch the speaker images again!
    if (httpReturnCode == 304) {
        qDebug() << " => http return code for " << this->currentConferenceId << " was " << httpReturnCode << " nothing changed !";
        cleanupDownloadData();
        emit loadingDataFinished();
    } else {
        const QByteArray responseData = reply->readAll();

        QMap<QString, QString> dataMap = getBaseConferenceData(this->currentConferenceId);
        dataMap.insert("etag", getEtagValue(reply));
        dataMap.insert("content", QString(responseData));

        persistConferenceData(dataMap);

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
}

void DukeconBackend::fetchPhotoImages() {
    if (photoIds.length() > 0) {
        this->currentPhotoId = photoIds.first();
        photoIds.removeFirst();

        QString basePhotoUrl = resolveConferenceUrl(this->singleConference, this->currentConferenceId, this->currentConferenceYear, QString("SINGLE_IMAGES_BASE_URL"));
        QUrl photoIdUrl = QUrl(basePhotoUrl + this->currentPhotoId);
//        if (this->singleConference) {
//            photoIdUrl = QUrl(SINGLE_IMAGES_BASE_URL + this->currentPhotoId);
//        } else {
//            // TODO
//        }

        emit subLoadingLabelAvailable(QString(tr("Speaker Image (%1/%2)"))
                                      .arg(speakerImageCount - photoIds.length())
                                      .arg(this->speakerImageCount));

        QString etagValue = lookupEtagForConferenceResource(this->currentConferenceId, this->currentPhotoId);
        QNetworkReply *reply = executeGetRequest(photoIdUrl, etagValue);
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

    const int httpReturnCode = getHttpReturnCode(reply);

    if (httpReturnCode == 304) {
        qDebug() << " => http return code for " << this->currentPhotoId << " was " << httpReturnCode << " nothing changed !";
    } else {
        const QByteArray imageByteArray(reply->readAll());
        const QByteArray photoAsBase64ByteArray = imageByteArray.toBase64();

        QMap<QString, QString> dataMap = getBaseConferenceResource(this->currentConferenceId, this->currentPhotoId);
        dataMap.insert("etag", getEtagValue(reply));
        dataMap.insert("content", QString("data:image/png;base64," + photoAsBase64ByteArray));

        // TODO do not persist the images in the database but in the filessystem - only persist the references / etag to the image
        persistConferenceResource(dataMap);
    }

    fetchPhotoImages();
}


QString DukeconBackend::processResponses(QByteArray searchReply) {
    QString result = QString(searchReply);
    qDebug() << "DukeconBackend::processResponses - data : " << result.left(result.length() > 80 ? 80 : result.length());
    return result;
}

int DukeconBackend::getHttpReturnCode(QNetworkReply *reply) {
    QVariant statusCode = reply->attribute( QNetworkRequest::HttpStatusCodeAttribute);
    return statusCode.toInt();
}

QString DukeconBackend::getEtagValue(QNetworkReply *reply) {
    QString etag = reply->rawHeader("ETag");
    qDebug() << "ETag was " << etag;
    return etag;
}

void DukeconBackend::initializeDatabase() {
    if (db.databaseName().isEmpty()) {
        QQmlApplicationEngine engine;
        qDebug() << "path : " << engine.offlineStoragePath();

        // https://lists.qt-project.org/pipermail/interest/2016-March/021316.html
        QString path(engine.offlineStoragePath() + "/Databases/"
                     +QCryptographicHash::hash("harbour-sailcon", QCryptographicHash::Md5).toHex()
                     +".sqlite");

        qDebug() << "path : " << path;

        db.setDatabaseName(path);
    }
}

QString DukeconBackend::lookupEtagForConferenceResource(QString conferenceId, QString resourceId) {
    QMap<QString, QString> result = getBaseConferenceResource(conferenceId, resourceId);
    QString etagValue = result["etag"];
    return etagValue;
}

QMap<QString, QString> DukeconBackend::getBaseConferenceResource(QString conferenceId, QString resourceId) {
    initializeDatabase();

    QMap<QString, QString> dataMap;
    dataMap.insert("conferenceId", conferenceId);
    dataMap.insert("resourceId", resourceId);

    if(db.open()){
        QSqlQuery query;
        query.prepare("SELECT conferenceId, resourceId, resourceType, etag FROM conference_resources WHERE conferenceId LIKE :conferenceId AND resourceId LIKE :resourceId");
        query.bindValue(":conferenceId", conferenceId);
        query.bindValue(":resourceId", resourceId);

        if (!query.exec()) {
            qDebug() << "query failed" << query.lastError();
        }

        if (query.next()) {
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

QString DukeconBackend::lookupEtagForConferenceData(QString conferenceId) {
    QMap<QString, QString> result = getBaseConferenceData(conferenceId);
    QString etagValue = result["etag"];
    return etagValue;
}

QMap<QString, QString> DukeconBackend::getBaseConferenceData(QString conferenceId) {
    initializeDatabase();

    QMap<QString, QString> dataMap;
    dataMap.insert("id", conferenceId);

    if(db.open()){
        QSqlQuery query;
        query.prepare("SELECT id, name, year, startDate, endDate, content, etag, state FROM conference WHERE id LIKE :conferenceId");
        query.bindValue(":conferenceId", conferenceId);
        if (!query.exec()) {
            qDebug() << "query failed - error was " << query.lastError();
        }

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
    initializeDatabase();

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
    initializeDatabase();

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

