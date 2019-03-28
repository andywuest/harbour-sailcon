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

import "logic.js" as Logic

Page {
    id: page

    //signal selectedIndexSignal(string index)

    SilicaListView {
        id: list
        anchors.fill: parent
        width: parent.width
        height: parent.height
        header: PageHeader {
            //     title: qsTr("Nested Page")
        }
        model: ListModel {
            id: myJSModel
        }

        delegate: Item {
            width: parent.width
            height: Theme.itemSizeMedium
            anchors {
                left: parent.left
                right: parent.right
                margins: Theme.paddingLarge
            }

            /*
            Image {
                id: "idImage"
                source: "image://theme/icon-s-time"
            }
            */

            Label {
                id: itemHeader
                text: title
                font.pixelSize: Theme.fontSizeMedium
                anchors {
                    left: parent.left
                    right: parent.right
                }
            }
            Label {
                id: itemStartTime
                text: startTime
                font.pixelSize: Theme.fontSizeTiny
                anchors {
                    left: parent.left
                    right: parent.right
                    top: itemHeader.bottom
                }
            }
            Label {
                id: itemLocation
                text: location
                font.pixelSize: Theme.fontSizeTiny
                anchors {
                    left: parent.left
                    right: parent.right
                    top: itemStartTime.bottom
                }
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    var value = list.model.get(index).value
                    console.log(index + " with " + value)
                    //page.selectedIndexSignal(" " + index);
                    pageStack.push(Qt.resolvedUrl("TalkOld.qml"), { selectedIndex: "" + index});
                }
            }
        }
        Component.onCompleted: {
            for (var i = 0; i <= 100; i++) {

                /*
                var myElement = {
                    title: "DukeCon Hacking Session" + i,
                    startTime: "Montag, 07.03.2016 09:00 (40 min)",
                    location: "Tagungsraum Dambali (Hotel Matamba)",
                    category: "Community Aktivitäten"
                }
                */
                myJSModel.append(Logic.buildEntry(i));
            }
        }
        VerticalScrollDecorator {
        }
    }
}
