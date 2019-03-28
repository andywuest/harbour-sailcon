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

// import "jfs2016.js" as Data
import "logic.js" as Logic
import "utils2.js" as Utils2

Page {
    id: page
    property string selectedDate

    SilicaListView {
        id: listView
        model: ListModel {
            id: audienceListModel
        }
        anchors.fill: parent
        header: PageHeader {
            title: qsTr("Time Selection")
        }
        delegate: BackgroundItem {
            id: delegate

            Label {
                x: Theme.paddingLarge
                text: label
                anchors.verticalCenter: parent.verticalCenter
                color: delegate.highlighted ? Theme.highlightColor : Theme.primaryColor
            }
            onClicked: {
                console.log("Clicked " + index)
                var selectedItem = listView.model.get(index);
                console.log("item by audience : " + selectedItem)
                console.log("item label : " + selectedItem.label)
                console.log("item internalId : " + selectedItem.internalId)
                console.log("item index : " + selectedItem.index)
                pageStack.push(Qt.resolvedUrl("Talks.qml"), {
                                   selectedDate: selectedDate,
                                   audienceId : selectedItem.internalId
                               });
            }

        }
        VerticalScrollDecorator {}

        Component.onCompleted: {
            var manager = Utils2.createConferenceManager(GlobalDataModel.conferenceJsonData);
            var sbModelItem = manager.getAudiencesForEventDayAsSelectBoxModelItems(selectedDate);
            sbModelItem.forEach(function(element) {
                audienceListModel.append(element);
            });
        }

    }


}
