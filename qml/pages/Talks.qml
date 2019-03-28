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

// QTBUG-34418
import "."

import "utils.js" as Utils
//import "jfs2016.js" as Data
import "logic.js" as Logic
import "utils2.js" as Utils2

Page {
    id: page
    property string selectedDate
    property string trackId
    property string timeId
    property string locationId
    property string audienceId

    SilicaListView {
        id: listView
        model: ListModel {
            id: talkListModel
        }
        anchors.fill: parent
        header: PageHeader {
            title: qsTr("Talks")
        }
        delegate: BackgroundItem {
            id: delegate

            // https://sailfishos.org/develop/docs/silica/sailfish-application-pitfalls.html/

            width: parent.width
            height: Theme.itemSizeMedium
            anchors {
//                left: parent.left
//                leftMargin: Theme.horizontalPageMargin
//                right: parent.right
//                rightMargin: Theme.horizontalPageMargin

                //left: parent.left
                //right: parent.right
                margins: Theme.paddingLarge
            }

            /*
            Label {
                x: Theme.paddingLarge
                text: "" + talk.title
                anchors.verticalCenter: parent.verticalCenter
                color: delegate.highlighted ? Theme.highlightColor : Theme.primaryColor
            }
            */

            Label {
                id: itemHeader
                text: title
                truncationMode: TruncationMode.Fade
                font.pixelSize: Theme.fontSizeSmall
                anchors {
                    left: parent.left
                    leftMargin: Theme.horizontalPageMargin
                    right: parent.right
                    rightMargin: Theme.horizontalPageMargin
                    // top: itemHeader.bottom
                    //verticalCenter: parent.verticalCenter

                                /*
                    leftMargin: Theme.horizontalPageMargin
                    rightMargin: Theme.horizontalPageMargin
                    verticalCenter: parent.verticalCenter
                    */
                    //left: parent.left
                    //right: parent.right
                }
            }

            Label {
                id: itemLocationTime
                text: resolveLocationName(locationId) + " " + resolveTime(start) + " - " + resolveTime(end) + " " + qsTr("Uhr");
                font.pixelSize: Theme.fontSizeTiny
                anchors {
                    left: parent.left
                    leftMargin: Theme.horizontalPageMargin
                    right: parent.right
                    rightMargin: Theme.horizontalPageMargin
                    top: itemHeader.bottom
                }
            }


            Label {
                id: itemStartTime
                text: "Zielgruppe: " + resolveAudience(audienceId)
                font.pixelSize: Theme.fontSizeTiny
                anchors {
                    /*
                    left: parent.left
                    right: parent.right
                    top: itemHeader.bottom
                    */
                    left: parent.left
                    leftMargin: Theme.horizontalPageMargin
                    right: parent.right
                    rightMargin: Theme.horizontalPageMargin
                    top: itemLocationTime.bottom
                    // verticalCenter: parent.verticalCenter
                }
            }


//            // Label for Location Name
//            Label {
//                id: itemLocation
//                text:  resolveLocationName(locationId);
//                font.pixelSize: Theme.fontSizeTiny
//                anchors {
//                    /*
//                    left: parent.left
//                    right: parent.right
//                    top: itemStartTime.bottom
//                    */
//                    left: parent.left
//                    leftMargin: Theme.horizontalPageMargin
//                    right: parent.right
//                    rightMargin: Theme.horizontalPageMargin
//                    top: itemStartTime.bottom
//                    // verticalCenter: parent.verticalCenter
//                }
//            }

            onClicked: {
                console.log("Talks clicked " + index)
                var selectedItem = listView.model.get(index);
                console.log("iteM id : " + selectedItem.id)
                console.log("iteM title : " + selectedItem.title)
                console.log("iteM abstract : " + selectedItem.abstractText)
                pageStack.push(Qt.resolvedUrl("Talk.qml"), {
                                   eventId: id
                               });
            }

            function resolveAudience(audienceId) {
                var manager = Utils2.createConferenceManager(GlobalDataModel.conferenceJsonData);
                var audienceMap = manager.getAudienceMap();
                var audience = audienceMap.get(audienceId);
                return audience.names["en"];
            }

            function resolveTime(dateTime) {
                console.log(dateTime);
                var date = new Date(dateTime);
                var time = date.toLocaleTimeString(Qt.locale(), "HH:mm");
                console.log(time);
                return time;
            }

            function resolveLocationName(locationId) {
                var manager = Utils2.createConferenceManager(GlobalDataModel.conferenceJsonData);
                var locationMap = manager.getLocationMap();
                var location = locationMap.get(locationId);
                return location.names["de"];
            }

        }

        VerticalScrollDecorator {}

        Component.onCompleted: {
            var manager = Utils2.createConferenceManager(GlobalDataModel.conferenceJsonData), sbModelItem;

            console.log("timeId : '" + timeId + "', trackId : '" + trackId + "'");

            if (trackId !== undefined && trackId !== null && trackId !== "") {
                console.log("via track");
                sbModelItem = manager.getEventsForTrack(selectedDate, trackId);
            } else if (timeId !== undefined && timeId !== null && timeId !== "") {
                console.log("via time");
                sbModelItem = manager.getEventsForTime(selectedDate, timeId);
            } else if (locationId !== undefined && locationId !== null && locationId !== "") {
                console.log("via location");
                sbModelItem = manager.getEventsForLocation(selectedDate, locationId);
            } else if (audienceId !== undefined && audienceId !== null && audienceId !== "") {
                console.log("via audience");
                sbModelItem = manager.getEventsForAudience(selectedDate, audienceId);
            }

            sbModelItem.forEach(function(element) {
                talkListModel.append(element);
            });




//            var track = {
//               id : trackId
//            };

//            var talks = Utils.getEventsForDayAndTrack(selectedDate, track, Data.javaforum2016.events), i;
//            for (i = 0; i < talks.length; i++) {
//                talkListModel.append(Logic.buildTalkEntry(i, talks[i]));
//            }


        }



    }


}
