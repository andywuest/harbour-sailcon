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
import "../components/thirdparty"

// QTBUG-34418
import "."

import "../js/constants.js" as Constants
import "../js/utils2.js" as Utils2
import "../js/database.js" as Database

// http://imaginativethinking.ca/make-qml-component-singleton/
Page {
    id: selectConference
    property bool loaded : false
//    property var downloadConference;

    AppNotification {
        id: conferenceNotification
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

            function addConference() {
//                var data = listView.model.get(index)
//                downloadConference = data;
                loaded = false;
                conferenceUpdater.downloadConferenceData(listView.model.get(index));

//                if (Constants.SINGLE) {
//                    loaded = false;
//                    dukeconBackend.downloadAllData(Constants.SINGLE, data.id, null)
//                    return;
//                }
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
                    visible: !isPersisted
                    MenuItem {
                        visible: !isPersisted
                        text: qsTr("Add")
                        onClicked: addConference()
                    }
                }
            }
        }

        VerticalScrollDecorator {
        }

//        function initDataResultHandler(result) {
//            console.log("result init data : " + result.substring(1, 80));
//        }

//        function imageResourcesResultHandler(result) {
//            console.log("result image resources : " + result.substring(1, 80));
//            // TODO etag
//            result = Database.persistConferenceImage(downloadConference.id, 'conferenceImage', result, "", 'logo')
//        }

//        function conferenceDataResultHandler(result) {
//            console.log("result conf data : " + result.substring(1, 80));
//            // TODO etag
//            result = Database.persistConferenceData(downloadConference, result, "");
//        }

//        function speakerImageResultHandler(result, photoId) {
//            console.log("result speaker iamge : " + result.substring(1, 80));
//            Database.persistConferenceImage(downloadConference.id, 'speakerImage', result, "", photoId);
//        }

//        function errorResultHandler(result) {
//            // TODO stockUpdateProblemNotification.show(result)
//            updateAvailableConferences();
//            loaded = true;
//        }

//        function subLoadingLabelResultHandler(subInfoLabelText) {
//            conferenceLoadingIndicator.subInfoLabelText = subInfoLabelText;
//        }

//        function loadingDataFinishedResultHandler() {
//            updateAvailableConferences();
//            loaded = true;
//        }

        function updateAvailableConferences() {
            conferencesListModel.clear();
            var persistedConferenceIds = Database.getPersistedConferenceIds();
            if (Constants.SINGLE) {
                var conf = {};
                conf.id = "javaland2019"
                conf.name = "JavaLand 2019"
                conf.year = "2019"
                conf.isPersisted = (persistedConferenceIds.indexOf(conf.id) > -1);
                conferencesListModel.append(conf)

                conf = {};
                conf.id = "javaland2020"
                conf.name = "JavaLand 2020"
                conf.year = "2020"
                conf.isPersisted = (persistedConferenceIds.indexOf(conf.id) > -1);
                conferencesListModel.append(conf)

            } else {
                var conferenceListManager = Utils2.createConferenceListManager()
                conferenceListManager.fetchConferences(
                            Constants.CONFERENCES_URL,
                            function (status, sortedConferences) {
                                console.log("conferences : " + sortedConferences)
                                console.log("status : " + status)

                                if (sortedConferences !== null) {
                                    sortedConferences.forEach(
                                                function (element) {
                                                    console.log("confx : " + element.name + " - "
                                                                + element.startDate + " - ")
                                                    // var isAlreadyDownloaded = persistedConferenceIds.indexOf(element.id);
                                                    element.isPersisted
                                                            = (persistedConferenceIds.indexOf(
                                                                   element.id) > -1)
                                                    // console.log("idx : " + element.id + " available : " + isAlreadyDownloaded);
                                                    console.log("persisted : "
                                                                + element.isPersisted)
                                                    conferencesListModel.append(
                                                                element)
                                                })
                                } else {
                                    console.log("failed to Download conferences")
                                    console.log("failed to Download conferences - http status was "
                                                + status)
                                }
                            })
            }
        }

        Component.onCompleted: {
//            dukeconBackend.initDataResultAvailable.connect(initDataResultHandler);
//            dukeconBackend.imageResourcesResultAvailable.connect(imageResourcesResultHandler);
//            dukeconBackend.conferenceDataResultAvailable.connect(conferenceDataResultHandler);
//            dukeconBackend.speakerImageResultAvailable.connect(speakerImageResultHandler);
//            dukeconBackend.subLoadingLabelAvailable.connect(subLoadingLabelResultHandler)
//            dukeconBackend.loadingDataFinished.connect(loadingDataFinishedResultHandler)
//            dukeconBackend.requestError.connect(errorResultHandler);

            updateAvailableConferences();
            loaded = true;
        }

    }

    ConferenceUpdater {
        id: conferenceUpdater
        onLoadingFinished: {
            console.log("loadig finished !");
            listView.updateAvailableConferences();
            //flickable.reloadModelFromDatabase(conferencesListModel)
            //flickable.setActiveConferenceInGlobalModel()
            selectConference.loaded = true;
        }
        onErrorOccured: console.log("error message : " + errorMessage);
        onSubLoadingLabelChanged: conferenceLoadingIndicator.subInfoLabelText = label;
    }

    LoadingIndicator {
        id: conferenceLoadingIndicator
        subInfoLabelText: ""
        visible: !loaded
        Behavior on opacity {
            NumberAnimation {
            }
        }
        opacity: loaded ? 0 : 1
        height: parent.height
        width: parent.width
    }

}
