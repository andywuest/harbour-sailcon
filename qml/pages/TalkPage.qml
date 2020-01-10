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

// import "jfs2016.js" as Data
import "../js/utils2.js" as Utils2
import "../js/database.js" as Database
import "../js/constants.js" as Constants

Page {
    id: eventPage
    property string eventId
    property string eventTitle
    property string eventAbstractText
    property string eventSpeaker
    property string eventTalkLocation
    property string eventTalkAudience
    property string eventTalkTime
    property string eventTalkTrack

    // To enable PullDownMenu, place our content in a SilicaFlickable
    SilicaFlickable {
        anchors {
            fill: parent
            bottomMargin: Theme.paddingMedium
        }

        //        anchors.fill: parent
        //        anchors.

        // Tell SilicaFlickable the height of its content.
        contentHeight: column.height

        // Place our content in a Column.  The PageHeader is always placed at the top
        // of the page, followed by our content.
        Column {
            id: column
            x: Theme.horizontalPageMargin
            width: parent.width - 2 * x
            spacing: Theme.paddingSmall
            PageHeader {
                title: qsTr("Selected Talk")
            }

            SectionHeader {
                text: qsTr("Talk Data")
            }

            Label {
                id: labelTalkTime
                text: eventTalkTime
                font.pixelSize: Theme.fontSizeExtraSmall
            }

            Label {
                id: labelTalkLocation
                text: eventTalkLocation
                font.pixelSize: Theme.fontSizeExtraSmall
            }

            Label {
                id: labelTalkAudience
                text: eventTalkAudience
                font.pixelSize: Theme.fontSizeExtraSmall
            }

            Label {
                id: labelTalkTrack
                text: eventTalkTrack
                font.pixelSize: Theme.fontSizeExtraSmall
            }

            SectionHeader {
                text: qsTr("Abstract")
            }

            Label {
                id: labelTitle
                //                x: Theme.horizontalPageMargin
                width: parent.width // - 2*x

                text: eventTitle
                font.pixelSize: Theme.fontSizeMedium
                wrapMode: Text.Wrap
                //                onSelectedIndexSignal:  console.log("signal received : " + index)

                //eventLabel.text
                //                color: Theme.secondaryHighlightColor
                //                font.pixelSize: Theme.fontSizeExtraLarge
            }


            // TODO hier noch ein summary label mit uhrzeit location einfuegen
            Label {
                id: labelAbstract
                //                x: Theme.horizontalPageMargin
                //                width: parent.width - 2*x
                width: parent.width // - 2*x
                text: eventAbstractText
                font.pixelSize: Theme.fontSizeExtraSmall
                wrapMode: Text.Wrap
            }

            SectionHeader {
                text: qsTr("Speakers")
            }

            // TODO dynamic amount of speaker - not just two fixed ones
            Speaker {
                id: speaker1
                visible: false
                width: parent.width
            }

            Speaker {
                id: speaker2
                visible: false
                width: parent.width
            }

            Button {
                text: "Show settings"
                //                anchors {
                //                    top: column.bottom
                //                    horizontalCenter: parent.horizontalCenter
                //                    margins: Theme.paddingMedium
                //                }
                // horizontalCenter: parent.horizontalCenter
                onClicked: pageStack.push(Qt.resolvedUrl("TalkSettings.qml"), {
                                              eventId: eventId
                                          })
            }
        }

        VerticalScrollDecorator {
        }

        function populateSpeaker(manager, targetSpeaker, conferenceSpeaker, event) {
            targetSpeaker.labelSpeakerName = conferenceSpeaker.name
            targetSpeaker.labelSpeakerCompany = manager.trimToEmpty(
                        conferenceSpeaker.company)
            targetSpeaker.labelSpeakerBio = manager.trimToEmpty(
                        conferenceSpeaker.bio)
            if (conferenceSpeaker.photoId !== undefined) {
                var img = Database.loadConferenceImage(
                            GlobalDataModel.conferenceJsonData.id,
                            conferenceSpeaker.photoId).content
                if (img !== undefined) {
                    targetSpeaker.imageSpeaker = img
                } else {
                    targetSpeaker.imageSpeaker = targetSpeaker.defaultSpeakerImage
                }
            } else {
                targetSpeaker.imageSpeaker = targetSpeaker.defaultSpeakerImage
            }

            // TODO isWebLinkPresent() methode im speaker kann entferntn werden !!! im ts code
            Constants.SUPPORTED_SOCIAL_TYPES.forEach(function (element) {
                targetSpeaker.addSocialLink(element, conferenceSpeaker[element])
            })

            Constants.SUPPORTED_DOCUMENT_TYPES.forEach(function (element) {
                targetSpeaker.addDocumentLink(element, event.documents[element])
            })

            targetSpeaker.visible = true
        }

        Component.onCompleted: {
            var manager = Utils2.createConferenceManager(
                        GlobalDataModel.conferenceJsonData)
            var event = manager.getEventById(eventId)
            var speakers = manager.getSpeakersForEvent(eventId)

            console.log("talk: event : " + event.title)
            eventTitle = event.title
            eventAbstractText = event.abstractText
            var startTime = manager.convertToDate(event.start)
            //            var dateTime2 = new Date(2001, 5, 21, 14, 13, 09)
            // locale name : Qt.locale().name
            // eventTalkTime = qsTr("Starting time: ") + Qt.formatDateTime(dateTime, qsTr('dd.MM.yyyy hh:mm'));
            // eventTalkTime = qsTr("Starting time: ") + Qt.formatDateTime(dateTime, qsTr('dd MMM yyyy, hh:mm'));
            eventTalkTime = qsTr("Starting time: ") + Qt.formatDateTime(
                        startTime, qsTr('dd MMM yyyy, hh:mm'))
            eventTalkLocation = qsTr("Location: ") + manager.getLocationName(
                        event.locationId)
            eventTalkAudience = qsTr("Audience: ") + manager.getAudienceName(
                        event.audienceId)
            eventTalkTrack = qsTr("Track: ") + manager.getTrackName(
                        event.trackId)

            if (speakers[0] !== undefined) {
                populateSpeaker(manager, speaker1, speakers[0], event)
            }

            if (speakers[1] !== undefined) {
                populateSpeaker(manager, speaker0, speakers[1], event)
            }
        }
    }
}
