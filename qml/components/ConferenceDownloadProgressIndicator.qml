/*
 * SailCon - Sailfish OS Version
 * Copyright © 2017 Andreas Wüst (andreas.wuest.freelancer@gmail.com)
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

import QtQuick 2.0
import QtQuick.LocalStorage 2.0
import Sailfish.Silica 1.0

// QTBUG-34418
import "../pages/."

// import "../pages/logic.js" as Logic
import "../pages/utils2.js" as Utils2
import "../pages/constants.js" as Constants
import "../pages/database.js" as Database

Item {
    id: loadingIndicator

    property bool withOverlay: true
//    property string conferenceId: ""
//    property string conferenceYear: ""
    property var confData: null;
    property var runningDownloads: [];

    width: parent.width
    height: parent.height
    Rectangle {
        id: loadingOverlay
        color: "black"
        opacity: 0.7
        width: parent.width
        height: parent.height
        visible: loadingIndicator.withOverlay
    }

    AppNotification {
        id: conferenceNotification
    }

    Timer {
        id: closeIndicatorTimer
        repeat: false
        interval: 2000
    }

    Connections {
        target: closeIndicatorTimer
        onTriggered: {
            loadingIndicator.visible = false;
        }
    }

    Canvas {
        id: speakerImageCanvas
        width: 300;
        height: 300;
        visible: false;


        property int currentIndex : 0;
        property var imagefiles : [];
        property string imagefile : "";

        onImageLoaded : {
            requestPaint();
            console.log("image loaded !" + imagefile);
        }

        onPaint: {
            console.log("PAINT !");
            console.log("loaded: " +speakerImageCanvas.isImageLoaded(imagefile))
            var ctx = getContext("2d");

            if (speakerImageCanvas.isImageLoaded(imagefile)) {
              var im = ctx.createImageData(imagefile);
               ctx.drawImage(im, 0, 0, 300, 300);

            var dataUrl = speakerImageCanvas.toDataURL("image/png");

            // check if the image is set
            if (imagefile.length > 0) {
                // extract the photoId from the url string
                var resourceId = imagefile.substring(imagefile.lastIndexOf("/") + 1);
                // no etags when loading via canvas
                var result = Database.persistConferenceImages(GlobalDataModel.conferenceJsonData, 'speakerImage', dataUrl, null, null, resourceId);
                // after persisting - unload image
                unloadImage(imagefile);
                ctx.reset();
                console.log("result is : " + result);
                if ((currentIndex + 1) < imagefiles.length) {
                    currentIndex++;
                    imagefile = imagefiles[currentIndex];
                    // speakerImagesLabel.text = "Loading image " + currentIndex + " of " + imagefiles.length;
                    console.log("Loading image " + currentIndex + " of " + imagefiles.length);
                    loadingLabel4.text = currentIndex + " / " + imagefiles.length;
                    loadImage(imagefile);
                } else {
                    console.log("Finished downloading the images - last one fectech");
                    loadingLabel4.text = (currentIndex + 1) + " / " + imagefiles.length;
                    checkDownloadsFinished();
                }
            }
            }
         }
    }

    Column {
        width: parent.width
        height: loadingLabel1.height + loadingLabel2.height +loadingLabel3.height +loadingLabel4.height +loadingBusyIndicator.height + Theme.paddingMedium
        spacing: Theme.paddingMedium
        anchors.verticalCenter: parent.verticalCenter

        InfoLabel {
            id: loadingLabel1
            font.pixelSize: Theme.fontSizeMedium
            text: qsTr("Loading Conference Data ....")
        }
        InfoLabel {
            id: loadingLabel2
            font.pixelSize: Theme.fontSizeMedium
            text: qsTr("Loading Logo ....")
        }
        InfoLabel {
            id: loadingLabel3
            font.pixelSize: Theme.fontSizeMedium
            text: qsTr("Loading Speaker Images")
            color: Theme.rgba(Theme.highlightColor, 0.9)
        }
        InfoLabel {
            id: loadingLabel4
            font.pixelSize: Theme.fontSizeMedium
            text: qsTr("- / -")
            color: Theme.rgba(Theme.highlightColor, 0.9)
        }
        BusyIndicator {
            id: loadingBusyIndicator
            anchors.horizontalCenter: parent.horizontalCenter
            running: loadingIndicator.visible
            size: BusyIndicatorSize.Large
        }
    }

    function checkDownloadsFinished() {
        runningDownloads.pop();
        if (runningDownloads.length === 0) {
            closeIndicatorTimer.start();
        }
    }

    function performDownload() {
        var data = confData;
//        data.id = conferenceId;
//        data.year = conferenceYear;

        var requestETag = Database.getETagForConferenceId(data.id)

        var urlService = Utils2.createUrlService(Constants.CONFERENCES_URL, Constants.SINGLE);
        var dataUrl = urlService.getConferenceDataUrl(data);
        var imagesUrl = urlService.getConferenceImagesUrl(data);
        var url = urlService.getConferenceDataUrl(data);

        var downloadData = Utils2.createDownloadData();
        downloadData.url = url;
        downloadData.eTag = requestETag;

        var downloadConferenceData = function(returnCode, httpRequest) {
            var result = null;

            if (returnCode === Constants.RETURN_CODE_OK || returnCode === Constants.RETURN_CODE_NOT_MODIFIED) {
                // ok -> data was updated -> so we persist it
                var detailedConferenceDataString = "";
                if (returnCode === Constants.RETURN_CODE_OK) {
                    detailedConferenceDataString = httpRequest.responseText;
                    GlobalDataModel.conferenceJsonData = JSON.parse(detailedConferenceDataString)
                    console.log("Conference data was updated updated data model to " + GlobalDataModel.conferenceJsonData)
                    var responseETag = httpRequest.getResponseHeader("ETag");
                    result = Database.persistConferenceData(data, detailedConferenceDataString, requestETag, responseETag)
                    data.isPersisted = true;
                } else if (returnCode === Constants.RETURN_CODE_NOT_MODIFIED) {
                    // TODO reload from DB
                    data = Database.loadConferenceFromDatabase(data.id);
                    detailedConferenceDataString = data.content;
                    console.log("model not changed -> have to load it from DB !");
                    result = qsTr("Confenrence Data unchanged.")
                }

                // trigger download of conferenceLogo and speaker images
                // runningDownloads.push('logo');
                runningDownloads.push('speakers');
                // performImageDownload(data, runningDownloads);
                performSpeakerImagesDownload(data, detailedConferenceDataString, runningDownloads);
            } else if (returnCode === Constants.RETURN_CODE_ERROR) {
                result = qsTr("Connection error (HTTP:" + httpRequest.status + ")");
                // hide loading indicator again
                closeIndicatorTimer.start();
            }

            conferenceNotification.show(result)
        };

        var downloadService = Utils2.createDownloadService();
        downloadService.execute(downloadData, downloadConferenceData);
    }

    function performImageDownload(data, downloads) {
        var urlService = Utils2.createUrlService(Constants.CONFERENCES_URL, Constants.SINGLE);
        var url = urlService.getConferenceImagesUrl(data);
        // TODO try to fetch etag for images
        // var eTag = Database.getETagForConferenceId(data.id)
        var eTag = null;

        console.log("Downloading conference images from URL : " + url)
        console.log("Using request eTag : " + eTag)

        var request2 = new XMLHttpRequest()
        request2.open('GET', url)
        request2.setRequestHeader('Content-Type',
                                 'application/json;charset=utf-8')
        if (eTag) {
            request.setRequestHeader('If-None-Match', eTag)
        }
        request2.onreadystatechange = function () {
            console.log(" download finished : ")
            if (request2.readyState === XMLHttpRequest.DONE) {
                var headers = request2.getAllResponseHeaders()
                var responseETag = request2.getResponseHeader("ETag")
                console.log("Resposne ETag : " + responseETag)
                console.log("Resposne ETag : " + request2.status)
                console.log("headers : " + headers)

                var result = null
                if (request2.status
                        && request2.status === Constants.HTTP_OK) {
                    console.log("response",
                                request2.responseText.substring(0, 200))

                    result = Database.persistConferenceImages(
                                data, 'conferenceImage', request2.responseText, eTag,
                                responseETag, 'logo')
                    data.isPersisted = true


                 //   performSpeakerImagesDownload(data);
                } else if (request2.status
                           && request2.status === Constants.HTTP_NOT_MODIFIED) {
                    result = qsTr("Conference data unchanged.");


                   //  performSpeakerImagesDownload(data);
                } else {
                    // showText("Failed to lookup conferences! HTTP error code was " + request.status + " (" + request.statusText +  ")" );
                    console.log("HTTP:", request2.status)
                    console.log("responsedata : " + request2.responseText)
                    result = qsTr(
                                "Connection error (HTTP:" + request2.status + ")")
                }

//                        conferenceNotification.show(result)
                  checkDownloadsFinished();
            }
        }

        try {
            request2.send()
        } catch (error) {
            showText('Error occured : ' + error)
        }

        /*view.model.remove(index)*/

        //console.log("hideBusyIndicator");
        //busyIndicator.visible = false;
        // busyIndicator.opacity = 1;
    }

    function performSpeakerImagesDownload(data, detailedConferenceDataString, downloads) {
        var urlService = Utils2.createUrlService(Constants.CONFERENCES_URL, Constants.SINGLE);
        var baseUrl = urlService.getSpeakerImagesUrl(data);

        var detailedConferenceData = JSON.parse(detailedConferenceDataString);
        var speakers = detailedConferenceData.speakers;

        var manager = Utils2.createConferenceManager(detailedConferenceData);
        var photoIdUrls = manager.getSpeakerPhotoIdUrls(baseUrl);
        console.log(photoIdUrls)

        loadingLabel4.text = 0 + " / " + photoIdUrls.length;

        // speakerImagesLabel.visible = true;

        speakerImageCanvas.visible = false; // true to debug
        speakerImageCanvas.currentIndex = 0;
        speakerImageCanvas.imagefiles = photoIdUrls;
        speakerImageCanvas.imagefile = photoIdUrls[0];

        // by setting the loadImage with a file we trigger the downloading via the canvas!!
        // the canvas will check if there are more images to download via the imagefiles array given.
        console.log(" load image trigger : " + speakerImageCanvas.imagefile);
        console.log("image loaded: " + speakerImageCanvas.isImageLoaded(speakerImageCanvas.imagefile));
        speakerImageCanvas.loadImage(speakerImageCanvas.imagefile);
    }

    onVisibleChanged: {
        if (loadingIndicator.visible == true) {
            console.log("NOW VISIBLE !");
            performDownload();
        }
    }

}
