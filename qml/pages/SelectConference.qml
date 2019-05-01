/*
 * DukeCon App Java Stuff - Sailfish OS Version
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
import Sailfish.Silica 1.0
import QtQuick.LocalStorage 2.0

import "../components"

// QTBUG-34418
import "."

import "constants.js" as Constants
import "utils2.js" as Utils2
import "database.js" as Database


// http://imaginativethinking.ca/make-qml-component-singleton/
Page {
    id: selectConference

    Timer {
        id: timer
    }

    function delay(delayTime, cb) {
        timer.interval = delayTime
        timer.repeat = false
        timer.triggered.connect(cb)
        timer.start()
    }

    AppNotification {
        id: conferenceNotification
    }

    /*
    Label {
        id: speakerImagesLabel
        visible: false
        text: "?"
    }
    */

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
//             im.data[3] = 128;
               ctx.drawImage(im, 0, 0, 300, 300);
                //ctx.drawImage(im, 10, 10, 280, 280); // with some margin
             }

            var dataUrl = speakerImageCanvas.toDataURL("image/png");
      //      var manager = Utils2.createConferenceManager(GlobalDataModel.conferenceJsonData);
//             console.log("stored image under  : " + GlobalDataModel.conferenceJsonData.id + ", " + 'd15f234b7a5fe0b72b5a3e21d72a7445');
        //    console.log("dataurlxx : " + dataUrl);


            // check if the image is set
            if (imagefile.length > 0) {
                // extract the photoId from the url string
                var resourceId = imagefile.substring(imagefile.lastIndexOf("/") + 1);
                // no etags when loading via canvas
                var result = Database.persistConferenceImage(GlobalDataModel.conferenceJsonData.id, 'speakerImage', dataUrl, null, resourceId);
                console.log("result is : " + result);
                if ((currentIndex + 1) < imagefiles.length) {
                    currentIndex++;
                    imagefile = imagefiles[currentIndex];
//                    speakerImagesLabel.text = "Loading image " + currentIndex + " of " + imagefiles.length;
                    loadImage(imagefile);
                    console.log("Loading image " + currentIndex + " of " + imagefiles.length);
                }
            }
         }
    }

    ConferenceDownloadProgressIndicator {
                id: favoritesLoadingIndicator
                visible: false
                Behavior on opacity { NumberAnimation {} }
                opacity: !favoritesLoadingIndicator.visbile ? 1 : 0
                height: parent.height
                width: parent.width
    }

    SilicaListView {
        id: listView

        model: ListModel {
            id: conferencesListModel
        }
        anchors.fill: parent
        header: PageHeader {
            title: qsTr("Available Conferences")
        }

        section {
            property: "year"
            criteria: ViewSection.FullString
            delegate: SectionHeader {
                text: section
            }
        }

        delegate: /*BackgroundItem*/ ListItem {
            id: delegate
            menu: contextMenu

            function performDownload() {
                var data = listView.model.get(index)

//                favoritesLoadingIndicator.conferenceId = data.id;
//                favoritesLoadingIndicator.conferenceYear = data.year;
                favoritesLoadingIndicator.confData = data;
                favoritesLoadingIndicator.visible = true;

                if (1 == 1) {
                    return;
                }

                var eTag = Database.getETagForConferenceId(data.id)

                var urlService = Utils2.createUrlService(Constants.CONFERENCES_URL, Constants.SINGLE);
                var dataUrl = urlService.getConferenceDataUrl(data);
                var imagesUrl = urlService.getConferenceImagesUrl(data);

                var url = urlService.getConferenceDataUrl(data);

                var downloadData = Utils2.createDownloadData();
                downloadData.url = url;
                downloadData.eTag = eTag;

                var downloadConferenceData = function(returnCode, httpRequest) {
                    var result = null;
                    if (returnCode === 0) {
                        GlobalDataModel.conferenceJsonData = JSON.parse(httpRequest.responseText)
                        console.log("updated data model to " + GlobalDataModel.conferenceJsonData)
                        var responseETag = httpRequest.getResponseHeader("ETag");

                        result = Database.persistConferenceData(data, httpRequest.responseText, eTag, responseETag)
                        data.isPersisted = true;
                        var downloads = [];
                        downloads.push('logo');
                        downloads.push('speakers');
                        performImageDownload(data, downloads);
                        performSpeakerImagesDownload(data, httpRequest.responseText, downloads);
                    } else if (returnCode === 1) {
                        result = qsTr("Conference data unchanged.");
                        performImageDownload(data);
                        performSpeakerImagesDownload(httpRequest.responseText);
                    } else if (returnCode === 2) {
                        result = qsTr("Connection error (HTTP:" + httpRequest.status + ")");
                    } else {
                        showText('Error occured : ' + error)
                    }
                    conferenceNotification.show(result)
                };

                var downloadService = Utils2.createDownloadService();
                downloadService.execute(downloadData, downloadConferenceData);





//                console.log("Downloading conference data from URL : " + url)
//                console.log("Using request eTag : " + eTag)

//                var request = new XMLHttpRequest()
//                request.open('GET', url)
//                request.setRequestHeader('Content-Type',
//                                         'application/json;charset=utf-8')
//                request.setRequestHeader('If-None-Match', eTag)
//                request.onreadystatechange = function () {
//                    console.log(" download finished : ")
//                    if (request.readyState === XMLHttpRequest.DONE) {
//                        var headers = request.getAllResponseHeaders()
//                        var responseETag = request.getResponseHeader("ETag")
//                        console.log("Resposne ETag : " + responseETag)
//                        console.log("Resposne ETag : " + request.status)
//                        console.log("headers : " + headers)

//                        var result = null
//                        if (request.status
//                                && request.status === Constants.HTTP_OK) {
//                            console.log("response",
//                                        request.responseText.substring(0, 200))

//                            GlobalDataModel.conferenceJsonData = JSON.parse(
//                                        request.responseText)

//                            console.log("data model is now " + GlobalDataModel.conferenceJsonData)

//                            result = Database.persistConferenceData(
//                                        data, request.responseText, eTag,
//                                        responseETag)
//                            data.isPersisted = true
//                        } else if (request.status
//                                   && request.status === Constants.HTTP_NOT_MODIFIED) {
//                            result = qsTr("Conference data unchanged.")
//                        } else {
//                            // showText("Failed to lookup conferences! HTTP error code was " + request.status + " (" + request.statusText +  ")" );
//                            console.log("HTTP:", request.status)
//                            console.log("responsedata : " + request.responseText)
//                            result = qsTr(
//                                        "Connection error (HTTP:" + request.status + ")")
//                        }

//                        conferenceNotification.show(result)


//                        // when succussful start image download
//                        performImageDownload(data);

////                        console.log("hideBusyIndicator")
////                        busyIndicator2.running = false
////                        busyIndicator2.opacity = 0
////                        opacity = 1
//                    }
//                }

//                try {
//                    request.send()
//                } catch (error) {
//                    showText('Error occured : ' + error)
//                }

                /*view.model.remove(index)*/

                //console.log("hideBusyIndicator");
                //busyIndicator.visible = false;
                // busyIndicator.opacity = 1;
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

//                            GlobalDataModel.conferenceJsonData = JSON.parse(
//                                        request.responseText)

//                            console.log("data model is now " + GlobalDataModel.conferenceJsonData)

                            result = Database.persistConferenceImage(
                                        data.id, 'conferenceImage', request2.responseText,
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

                        conferenceNotification.show(result)


//                        downloads.pop();

                        if (downloads.length === 0) {
                            console.log("hideBusyIndicator")
                            // busyIndicator.visible = false
                            // busyIndicator.opacity = 1
                            busyIndicator2.running = false
                            busyIndicator2.opacity = 0
                            opacity = 1
                        } else {
                            console.log("other download is still running");
                        }

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

//                var speakerIds = [];

//                if (speakers !== undefined && speakers.length > 0) {
//                    for (var i = 0; i < speakers.length; i++) {
//                        if (speakers[i].photoId !== undefined) {
//                            speakerIds.push(speakers[i].photoId);
//                        }
//                        console.log("Speaker : " + baseUrl + speakers[i].photoId);
//                    }
//                 }

//                 console.log("number of speakers with image : " + speakerIds.length);
//                for (var j = 0; j < speakerIds.length; j++) {
//                    console.log("Speaker : " + baseUrl + speakerIds[j]);
//                }

                var manager = Utils2.createConferenceManager(detailedConferenceData);
                var photoIdUrls = manager.getSpeakerPhotoIdUrls(baseUrl);

                console.log(photoIdUrls)

//                speakerImagesLabel.visible = true;

                speakerImageCanvas.visible = false; // true to debug
                speakerImageCanvas.imagefiles = photoIdUrls;
                speakerImageCanvas.currentIndex = 0;
                speakerImageCanvas.imagefile = photoIdUrls[0];
                speakerImageCanvas.loadImage(speakerImageCanvas.imagefile);

//                downloads.pop();

                if (downloads.length === 0) {
                    console.log("hideBusyIndicator")
                    // busyIndicator.visible = false
                    // busyIndicator.opacity = 1
                    busyIndicator2.running = false
                    busyIndicator2.opacity = 0
                    opacity = 1
                } else {
                    console.log("other download is still running");
                }



//                // TODO try to fetch etag for images
//                // var eTag = Database.getETagForConferenceId(data.id)
//                var eTag = null;

//                console.log("Downloading conference images from URL : " + url)
//                console.log("Using request eTag : " + eTag)

//                var request2 = new XMLHttpRequest()
//                request2.open('GET', url)
//                request2.setRequestHeader('Content-Type',
//                                         'application/json;charset=utf-8')
//                if (eTag) {
//                    request.setRequestHeader('If-None-Match', eTag)
//                }
//                request2.onreadystatechange = function () {
//                    console.log(" download finished : ")
//                    if (request2.readyState === XMLHttpRequest.DONE) {
//                        var headers = request2.getAllResponseHeaders()
//                        var responseETag = request2.getResponseHeader("ETag")
//                        console.log("Resposne ETag : " + responseETag)
//                        console.log("Resposne ETag : " + request2.status)
//                        console.log("headers : " + headers)

//                        var result = null
//                        if (request2.status
//                                && request2.status === Constants.HTTP_OK) {
//                            console.log("response",
//                                        request2.responseText.substring(0, 200))

////                            GlobalDataModel.conferenceJsonData = JSON.parse(
////                                        request.responseText)

////                            console.log("data model is now " + GlobalDataModel.conferenceJsonData)

//                            result = Database.persistConferenceImage(
//                                        data.id, request2.responseText,
//                                        responseETag, 'logo')
//                            data.isPersisted = true
//                        } else if (request2.status
//                                   && request2.status === Constants.HTTP_NOT_MODIFIED) {
//                            result = qsTr("Conference data unchanged.")
//                        } else {
//                            // showText("Failed to lookup conferences! HTTP error code was " + request.status + " (" + request.statusText +  ")" );
//                            console.log("HTTP:", request2.status)
//                            console.log("responsedata : " + request2.responseText)
//                            result = qsTr(
//                                        "Connection error (HTTP:" + request2.status + ")")
//                        }

//                        conferenceNotification.show(result)

//                        console.log("hideBusyIndicator")
//                        // busyIndicator.visible = false
//                        // busyIndicator.opacity = 1
//                        busyIndicator2.running = false
//                        busyIndicator2.opacity = 0
//                        opacity = 1
//                    }
//                }

//                try {
//                    request2.send()
//                } catch (error) {
//                    showText('Error occured : ' + error)
//                }

                /*view.model.remove(index)*/

                //console.log("hideBusyIndicator");
                //busyIndicator.visible = false;
                // busyIndicator.opacity = 1;
            }




            // TODO rename the method -> also needed in the FirstPage.qml
            function addConference() {
                remorseAction("Downloading Data", function () {
                    //busyIndicator.visible = true;
                    // busyIndicator.opacity = 0;


                    /*
                    busyIndicator2.running = true
                    busyIndicator2.opacity = 1
                    opacity = 0.4
                    */

                    console.log("showBusyIndicator")

                    delay(10, performDownload)

                    // setTimeout(performDownload, 13000);
                })
                // https://programm.javaland.eu/2018/rest/conferences/javaland2018
            }

            Label {
                x: Theme.paddingLarge
                text: name
                anchors.verticalCenter: parent.verticalCenter
                color: delegate.highlighted ? Theme.highlightColor : Theme.primaryColor
            }
            onClicked: {
                var selectedItem = listView.model.get(index)
                console.log("Clicked " + index)
                console.log("name : " + selectedItem.name)
            }

            Component {
                id: contextMenu
                ContextMenu {
                    MenuItem {
                        visible: !isPersisted
                        text: qsTr("Add")
                        onClicked: addConference()
                    }
                    MenuItem {
                        visible: isPersisted
                        text: qsTr("Update")
                        onClicked: addConference()
                    }
                }
            }

            // z: ???
            BusyIndicator {
                running: false
                id: busyIndicator2
                anchors.centerIn: parent
                size: BusyIndicatorSize.Medium
                z: 0.7
                //opacity: 0.8
            }
        }
        VerticalScrollDecorator {
        }

        Component.onCompleted: {
            var conferenceListManager = Utils2.createConferenceListManager()
            var persistedConferenceIds = Database.getPersistedConferenceIds()
            conferenceListManager.fetchConferences(Constants.CONFERENCES_URL,
                        function (status, sortedConferences) {
                            console.log("conferences : " + sortedConferences)
                            console.log("status : " + status)

                            if (sortedConferences !== null) {
                                sortedConferences.forEach(function (element) {
                                    console.log("confx : " + element.name + " - "
                                                + element.startDate + " - ")
                                    // var isAlreadyDownloaded = persistedConferenceIds.indexOf(element.id);
                                    element.isPersisted = (persistedConferenceIds.indexOf(
                                                               element.id) > -1)
                                    // console.log("idx : " + element.id + " available : " + isAlreadyDownloaded);
                                    console.log("persisted : " + element.isPersisted)
                                    conferencesListModel.append(element)
                                })
                            } else {
                                console.log("failed to Download conferences")
                                console.log("failed to Download conferences - http status was " + status);
                            }
                        })

            //            var manager = Utils2.createConferenceManager(Data.javaforum2016);
            //            var sbModelItem = manager.getTracksForEventDayAsSelectBoxModelItems(selectedDate);
            //            sbModelItem.forEach(function(element) {
            //                trackListModel.append(element);
            //            });
        }
    }

    LoadingIndicator {
        id: busyIndicator
        visible: false
        Behavior on opacity {
            NumberAnimation {
            }
        }
        opacity: 1
        height: parent.height
        width: parent.width
    }

    BusyIndicator {
        id: busyIndicator3
        anchors.centerIn: parent
        size: BusyIndicatorSize.Large
        z: 1
    }
}
