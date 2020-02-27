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

import "../js/logic.js" as Logic
import "../js/utils2.js" as Utils2
import "../js/constants.js" as Constants
import "../js/database.js" as Database

Page {
    id: page
    property bool loaded : false
    property var downloadConference;

    // TODO pully for each conference in the list
    // -> delete
    // -> set as selected
    // start browser conference
    onEntered: {
        console.log("first page entered !")
    }
    onExited: {
        console.log("first page left")
    }

    Image {
            id: img
        }

    function globalFunction() {
        console.log("test global function");
    }


//    Timer {
//        id: timer
//    }

//    function delay(delayTime, cb) {
//        timer.interval = delayTime
//        timer.repeat = false
//        timer.triggered.connect(cb)
//        timer.start()
//    }

//    property bool indicatorVisible : true;

    // To enable PullDownMenu, place our content in a SilicaFlickable
    SilicaFlickable {
        id: flickable
        anchors.fill: parent

        // PullDownMenu and PushUpMenu must be declared in SilicaFlickable, SilicaListView or SilicaGridView
        PullDownMenu {
//            MenuItem {
//                text: qsTr("Reset")
//                onClicked: {
//                    Database.resetApplication();
//                    Database.initApplicationTables();
//                    // reload the model to make sure we have the latest state
//                    flickable.reloadModelFromDatabase(listView.model);
//                }
//            }
            MenuItem {
                text: qsTr("About")
                onClicked: pageStack.push(Qt.resolvedUrl("AboutPage.qml"))
            }
            MenuItem {
                text: qsTr("Settings")
                onClicked: pageStack.push(Qt.resolvedUrl("Settings.qml"))
            }
            MenuItem {
                text: qsTr("Select Conference")
                onClicked: pageStack.push(Qt.resolvedUrl(
                                              "ConferenceSelectionPage.qml"))
            }
//            MenuItem {
//                text: qsTr("DukeCon App")
//                onClicked: pageStack.push(Qt.resolvedUrl("ExploreByDay.qml"))
//            }
//            MenuItem {
//                text: qsTr("Indicator")
//                onClicked: {
//                    //indicatorVisible = true;
//                    favoritesLoadingIndicator.visible = true;
//                }
//            }



        }

//        ConferenceDownloadProgressIndicator {
//                    id: favoritesLoadingIndicator
//                    visible: false
//                    Behavior on opacity { NumberAnimation {} }
//                    opacity: !favoritesLoadingIndicator.visbile ? 1 : 0
//                    height: parent.height
//                    width: parent.width
//        }



        // Tell SilicaFlickable the height of its content.
        //contentHeight: column.height

        // Place our content in a Column.  The PageHeader is always placed at the top
        // of the page, followed by our content.

        //        Column {
        //            id: column

        //            width: page.width
        //            spacing: Theme.paddingLarge
        //            PageHeader {
        //                title: qsTr("")
        //            }
        //            Label {
        //                x: Theme.paddingLarge
        //                text: qsTr("Hello Sailors")
        //                color: Theme.secondaryHighlightColor
        //                font.pixelSize: Theme.fontSizeExtraLarge
        //            }
        //        }
        SilicaListView {
            id: listView

            model: ListModel {
                id: conferencesListModel
            }
            anchors.fill: parent
            header: PageHeader {
                title: qsTr("Conferences")
            }

            section {
                property: "stateLabel"
                criteria: ViewSection.FullString
                delegate: SectionHeader {
                    text: section
                }
            }

            delegate: /*BackgroundItem*/ ListItem {
                id: delegate
                menu: contextMenu

                function updateConference(index) {
                    loaded = false;
                    conferenceUpdater.downloadConferenceData(listView.model.get(index));
//                    var data =
//                    downloadConference = data;

//                    if (Constants.SINGLE) {
//                        loaded = false;
//                        dukeconBackend.downloadAllData(Constants.SINGLE, data.id, null)
//                        return;
//                    }
                }

                Label {
                    x: Theme.paddingLarge
                    text: "" + label // tmp workaround for no label
                    anchors.verticalCenter: parent.verticalCenter
                    color: delegate.highlighted ? Theme.highlightColor : Theme.primaryColor
                }

                onClicked: {
                    var selectedItem = listView.model.get(index)
                    console.log("Clicked " + index)
                    console.log("name : " + selectedItem.name)
                    var manager = Utils2.createConferenceManager(
                                GlobalDataModel.conferenceJsonData)
                    var isSingleDayConference = manager.isSingleDayConference()
                    console.log("is single day conferenc e: " + isSingleDayConference)

                    if (selectedItem.state === Constants.CONFERENCE_ACTIVE) {
                        // TODO check - if only one day - skip that page
                        if (isSingleDayConference) {
                            var conferenceDay = manager.getDaysOfConference()[0]
                            pageStack.push(Qt.resolvedUrl(
                                               "ExplorationTypeSelection.qml"),
                                           {
                                               selectedDate: conferenceDay
                                           })
                        } else {
                            pageStack.push(Qt.resolvedUrl("ExploreByDay.qml"))
                        }
                    }
                }

                Component {
                    id: contextMenu
                    ContextMenu {
                        visible: (listView.model.get(index) !== undefined
                                  && "noConf" !== listView.model.get(
                                      index).name)
                        MenuItem {
                            text: "Remove conference"
                            onClicked: deleteConference(index)
                        }
                        MenuItem {
                            visible: (listView.model.get(index) !== undefined
                                      && "noConf" !== listView.model.get(
                                          index).name && listView.model.get(
                                          index).state === Constants.CONFERENCE_INACTIVE)
                            text: "Set as Active"
                            onClicked: activateConference(index)
                        }
                        MenuItem {
                            visible: (listView.model.get(index) !== undefined
                                      && "noConf" !== listView.model.get(
                                          index).name && listView.model.get(
                                          index).state === Constants.CONFERENCE_ACTIVE)
                            text: "Unset as Active"
                            onClicked: deactivateAllConferences()
                        }
                        MenuItem {
                            visible: true
                            text: qsTr("Update")
                            onClicked: updateConference(index);
                        }
                    }
                }

                function deactivateAllConferences() {
                    Database.activateConferenceInDatabase()
                    flickable.setActiveConferenceInGlobalModel();
                    flickable.reloadModelFromDatabase(listView.model)
                }

//                function updateConference(index) {
//                    var conferenceId = listView.model.get(index).name;
//                    remorseAction("Downloading Data", function () {
//                        favoritesLoadingIndicator.confData = Database.loadConferenceFromDatabase(conferenceId);
//                        favoritesLoadingIndicator.visible = true;
//                    })
//                }

                function activateConference(index) {
                    Database.activateConferenceInDatabase(listView.model.get(index).name)
                    flickable.setActiveConferenceInGlobalModel();
                    flickable.reloadModelFromDatabase(listView.model)
                }

                function deleteConference(index) {
                    console.log("deleting the attribute with index " + index)
                    Database.deleteConferenceFromDatabase(listView.model.get(index).name)
                    flickable.reloadModelFromDatabase(listView.model)
                }

//                // z: ???
//                BusyIndicator {
//                    running: false
//                    id: busyIndicator2
//                    anchors.centerIn: parent
//                    size: BusyIndicatorSize.Medium
//                    z: 0.7
//                    //opacity: 0.8
//                }
            }

            function reloadData() {
                console.log("reload data")
            }
        }

        onVisibleChanged: {
            if (listView.visible) {
                console.log("visibility change ! -> visible ")

                //                    reloadData();
                //reloadModelFromDatabase(model);
                reloadModelFromDatabase(conferencesListModel)
            } else {
                console.log("visibility change ! -> not visible ")
            }
        }

//        Component.onCompleted: {
//            Database.initApplicationTables()
//            reloadModelFromDatabase(conferencesListModel)
//            setActiveConferenceInGlobalModel()
//        }

        function setActiveConferenceInGlobalModel() {
            try {
                var db = Database.getOpenDatabase()
                console.log('Setting current active conference to global data model!')
                db.transaction(function (tx) {
                    var results = tx.executeSql(
                                'SELECT name, content FROM conference WHERE state = ?',
                                [Constants.CONFERENCE_ACTIVE])

                    if (results.rows.length === 1) {
                        var resultRow = results.rows.item(0)
                        console.log('Found one conference ' + resultRow.name
                                    + ' - setting data to global model!')
                        GlobalDataModel.conferenceJsonData = JSON.parse(
                                    resultRow.content)
                    } else {
                        console.log('Found ' + results.rows.length
                                    + ' conference(s) - NOT SETTING GLOBAL MODEL!')
                    }
                })
            } catch (err) {
                console.log("Failed to set active conference to global model due to error : " + err)
            }
        }

//        function activateConferenceInDatabase(conferenceId) {
//            try {
//                var db = Database.getOpenDatabase()
//                db.transaction(function (tx) {
//                    console.log("resetting all conference states to inactive !")
//                    var result = tx.executeSql(
//                                'UPDATE conference SET state = ?',
//                                [Constants.CONFERENCE_INACTIVE])

//                    if (conferenceId !== undefined) {
//                        console.log("set conference active with name : " + conferenceId)
//                        tx.executeSql(
//                                    'UPDATE conference SET state = ? WHERE id = ?',
//                                    [Constants.CONFERENCE_ACTIVE, conferenceId])
//                    }
//                })

//                setActiveConferenceInGlobalModel()
//            } catch (err) {
//                console.log("Error activating conference in database: " + err)
//            }

//        }

//        function deleteConferenceFromDatabase(conferenceId) {
//            try {
//                var db = Database.getOpenDatabase()
//                db.transaction(function (tx) {
//                    var result = tx.executeSql(
//                                'DELETE FROM conference WHERE id = ?',
//                                [conferenceId])
//                    console.log("deleted conference with id : " + conferenceId)
//                })
//            } catch (err) {
//                console.log("Error deleting conference in database: " + err)
//            }

//        }

        function reloadModelFromDatabase(model) {
            model.clear()
            try {
                // TODO move to js function class
                var db = Database.getOpenDatabase()
                db.transaction(function (tx) {
                    var results = tx.executeSql(
                                'SELECT id,name,year,url,homeUrl,startDate,endDate,state,content FROM conference order by state desc, name asc')
                    var hasSelected = false



                    for (var i = 0; i < results.rows.length; i++) {
                        var row = results.rows.item(i)
                        console.log("result : " + row.id + ", " + row.name + ", " + row.state)

                        var confId = row.id
                        var confName = row.name
                        var confState = row.state
                        var stateLabel = (confState !== Constants.CONFERENCE_INACTIVE ? qsTr("active conference") : qsTr(
                                                                "available conferences"))
                        if (confState !== Constants.CONFERENCE_INACTIVE) {
                            hasSelected = true
                        }

                        model.append({
                                         name: confId,
                                         label: confName,
                                         state: confState,
                                         stateLabel: stateLabel
                                     })
                    }

                    console.log("selected ? : " + hasSelected)
                    if (!hasSelected) {
                        model.insert(0, {
                                         name: "noConf",
                                         label: qsTr(
                                                    "please select conference"),
                                         state: Constants.CONFERENCE_ACTIVE,
                                         stateLabel: "active conference"
                                     })
                    }
                })
            } catch (err) {
                console.log("Error creating table in database: " + err)
            }
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
//            loaded = true;
//        }

        Component.onCompleted: {
//            dukeconBackend.initDataResultAvailable.connect(initDataResultHandler);
//            dukeconBackend.imageResourcesResultAvailable.connect(imageResourcesResultHandler);
//            dukeconBackend.conferenceDataResultAvailable.connect(conferenceDataResultHandler);
//            dukeconBackend.speakerImageResultAvailable.connect(speakerImageResultHandler);
//            dukeconBackend.subLoadingLabelAvailable.connect(subLoadingLabelResultHandler)
            //dukeconBackend.loadingDataFinished.connect(loadingDataFinishedResultHandler)
//            dukeconBackend.requestError.connect(errorResultHandler);

            Database.initApplicationTables()
            reloadModelFromDatabase(conferencesListModel)
            setActiveConferenceInGlobalModel()
            loaded = true;
        }

    }

    ConferenceUpdater {
        id: conferenceUpdater
        onLoadingFinished: {
            console.log("loadig finished !");
            flickable.reloadModelFromDatabase(conferencesListModel)
            flickable.setActiveConferenceInGlobalModel()
            page.loaded = true;
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
