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
            fill: parent;
            bottomMargin: Theme.paddingMedium;
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
            width: parent.width - 2*x
            spacing: Theme.paddingSmall
            PageHeader {
                title: qsTr("Selected Talk")
            }

            SectionHeader {
                text: "Talk Data"
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
                text: "Abstract"
            }

            Label {
                id: labelTitle
//                x: Theme.horizontalPageMargin
                width: parent.width// - 2*x

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
                width: parent.width// - 2*x
                text: eventAbstractText
                font.pixelSize: Theme.fontSizeExtraSmall
                wrapMode: Text.Wrap
            }

            SectionHeader {
                text: "Speaker"
            }

                Speaker {
                    id: speaker1
                    visible: false;
                    width: parent.width// - 2*x

                    labelSpeakerName: "text1"
                    labelSpeakerBio: "bio1"
                    labelSpeakerCompany: "company1"
                    imageSpeaker: ""
                }


                Speaker {
                    id: speaker2
                    visible: false;

                    labelSpeakerName: "text2"
                    labelSpeakerBio: "bio2"
                    labelSpeakerCompany: "company2"
                    imageSpeaker: ""
                }


            Button {
                text: "Show settings"
//                anchors {
//                    top: column.bottom
//                    horizontalCenter: parent.horizontalCenter
//                    margins: Theme.paddingMedium
//                }
                // horizontalCenter: parent.horizontalCenter
                onClicked: pageStack.push(Qt.resolvedUrl("TalkSettings.qml"), { eventId: eventId})
            }


            // TODO show multiple speaker

            /*
            Label {
                id: labelSpeaker
                x: Theme.horizontalPageMargin

                width: parent.width - 2*x
                text: eventSpeaker
                font.pixelSize: Theme.fontSizeSmall
                wrapMode: Text.Wrap
            }

            Image {
                id:  imageSpeaker
                x: Theme.horizontalPageMargin
                 // source: "data:image/gif;base64,R0lGODlhEAAQAMQAAORHHOVSKudfOulrSOp3WOyDZu6QdvCchPGolfO0o/XBs/fNwfjZ0frl3/zy7////wAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACH5BAkAABAALAAAAAAQABAAAAVVICSOZGlCQAosJ6mu7fiyZeKqNKToQGDsM8hBADgUXoGAiqhSvp5QAnQKGIgUhwFUYLCVDFCrKUE1lBavAViFIDlTImbKC5Gm2hB0SlBCBMQiB0UjIQA7"
              //   source : "data:image/png;base64," + imageData
            }
            */

        }


        VerticalScrollDecorator {}

        Component.onCompleted: {
            var manager = Utils2.createConferenceManager(GlobalDataModel.conferenceJsonData);
            var event = manager.getEventById(eventId);
            var speakers = manager.getSpeakersForEvent(eventId);

//            var event = manager.getEventById(eventId);
//            var speakers = manager.getSpeakerByIds(event.speakerIds);
            console.log("talk: event : " + event.title);
            eventTitle = event.title;
            eventAbstractText = event.abstractText;
            var startTime = manager.convertToDate(event.start);
//            var dateTime2 = new Date(2001, 5, 21, 14, 13, 09)
            // locale name : Qt.locale().name
            // eventTalkTime = qsTr("Starting time: ") + Qt.formatDateTime(dateTime, qsTr('dd.MM.yyyy hh:mm'));
            // eventTalkTime = qsTr("Starting time: ") + Qt.formatDateTime(dateTime, qsTr('dd MMM yyyy, hh:mm'));
            eventTalkTime = qsTr("Starting time: ") + Qt.formatDateTime(startTime, qsTr('dd MMM yyyy, hh:mm'));
            eventTalkLocation = qsTr("Location: ") + manager.getLocationName(event.locationId);
            eventTalkAudience = qsTr("Audience: ") + manager.getAudienceName(event.audienceId);
            eventTalkTrack = qsTr("Track: ") + manager.getTrackName(event.trackId);

            // TODO company can be undefined

            if (speakers[0] !== undefined) {
                speaker1.labelSpeakerName = speakers[0].name;
                speaker1.labelSpeakerCompany = manager.trimToEmpty(speakers[0].company);
                speaker1.labelSpeakerBio = manager.trimToEmpty(speakers[0].bio);
                if (speakers[0].photoId !== undefined) {
                  var img = Database.loadConferenceImage(GlobalDataModel.conferenceJsonData.id, speakers[0].photoId).content
                  if (img !== undefined)   {
                    speaker1.imageSpeaker = img;
                  } else {
                      speaker1.imageSpeaker = speaker1.defaultSpeakerImage;
                  }
                } else {
                    speaker1.imageSpeaker = speaker1.defaultSpeakerImage;
                }

                speaker1.sectionHeaderWebLinks = speakers[0].isWebLinkPresent();
                speaker1.labelWebsite = manager.trimToEmpty(speakers[0].website);
                speaker1.labelTwitter = manager.trimToEmpty(speakers[0].twitter);
                speaker1.labelLinkedin = manager.trimToEmpty(speakers[0].linkedin);
                speaker1.labelXing = manager.trimToEmpty(speakers[0].xing);

                speaker1.sectionHeaderDocuments = event.isDocumentsPresent();
                speaker1.labelSlides = manager.trimToEmpty(event.documents.slides);
                speaker1.labelManuscript = manager.trimToEmpty(event.documents.manuscript);
                speaker1.labelOther = manager.trimToEmpty(event.documents.other);

                speaker1.visible = true;
            }

            if (speakers[1] !== undefined) {
                speaker2.labelSpeakerName = speakers[1].name;
                speaker2.labelSpeakerCompany = manager.trimToEmpty(speakers[1].company);
                speaker2.labelSpeakerBio = manager.trimToEmpty(speakers[1].bio);
                if (speakers[1].photoId !== undefined) {
                   speaker2.imageSpeaker = Database.loadConferenceImage(GlobalDataModel.conferenceJsonData.id, speakers[1].photoId).content;
                } else {
                    speaker2.imageSpeaker = speaker2.defaultSpeakerImage;
                }

                speaker2.sectionHeaderWebLinks = speakers[1].isWebLinkPresent();
                speaker2.labelWebsite = manager.trimToEmpty(speakers[1].website);
                speaker2.labelTwitter = manager.trimToEmpty(speakers[1].twitter);
                speaker2.labelLinkedin = manager.trimToEmpty(speakers[1].linkedin);
                speaker2.labelXing = manager.trimToEmpty(speakers[1].xing);

                speaker2.sectionHeaderDocuments = event.isDocumentsPresent();
                speaker2.labelSlides = manager.trimToEmpty(event.documents.slides);
                speaker2.labelManuscript = manager.trimToEmpty(event.documents.manuscript);
                speaker2.labelOther = manager.trimToEmpty(event.documents.other);

                speaker2.visible = true;
            }

//            var speakerText = ""
//            for (var i = 0; i < speakers.length; i++) {
//                speakerText += speakers[i].name + (speakers[i].company !== undefined ? " (" + speakers[i].company + ")" : "");
//                speakerText += "\n\n" + speakers[i].bio;
//                speakerText += "\n\n";
//            }

//            console.log("speaker Text : " + speakerText);

//            var image = Database.loadConferenceImage(GlobalDataModel.conferenceJsonData.id, speakers[0].photoId).content;
//            imageSpeaker.source = image;

//            eventSpeaker = speakerText;
        }

    }


}
