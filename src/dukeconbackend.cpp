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

    getEtagValue(reply);
    emit initDataResultAvailable(processResponses(reply->readAll()));

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

    emit imageResourcesResultAvailable(processResponses(reply->readAll()));

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

    getEtagValue(reply);
    const QByteArray responseData = reply->readAll();
    emit conferenceDataResultAvailable(processResponses(responseData));

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
    if (photoIds.length() > 0) {
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

    QByteArray imageByteArray(reply->readAll());
    //QString imageAsBase64 = QString();
    QByteArray photoAsBase64ByteArray = imageByteArray.toBase64();
    //qDebug() << "DukeconBackend::handlePhotoIdFinished - imagebase64 : " << imageAsBase64.left(imageAsBase64.length() > 80 ? 80 : imageAsBase64.length());

    emit speakerImageResultAvailable("data:image/png;base64," + processResponses(photoAsBase64ByteArray), this->currentPhotoId);

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

void DukeconBackend::handleRequestError(QNetworkReply::NetworkError error) {
    QNetworkReply *reply = qobject_cast<QNetworkReply *>(sender());
    qWarning() << "DukeconBackend::handleRequestError:" << (int)error << reply->errorString() << reply->readAll();

    cleanupDownloadData();

    emit requestError("Return code: " + QString::number((int)error) + " - " + reply->errorString());
}





