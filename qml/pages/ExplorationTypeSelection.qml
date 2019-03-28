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

Page {
    id: page
    property string selectedDate

    SilicaListView {
        id: listView
        model: ListModel {
            id: typeListModel
        }
        anchors.fill: parent
        header: PageHeader {
            title: qsTr("Exploration Type")
        }
        delegate: BackgroundItem {
            id: delegate

            Label {
                x: Theme.paddingLarge
                text: "" + type.type
                anchors.verticalCenter: parent.verticalCenter
                color: delegate.highlighted ? Theme.highlightColor : Theme.primaryColor
            }
            onClicked: {
                console.log("Clicked " + index)
                console.log("iteM type selection : " + listView.model.get(index))
                console.log("iteM : " + listView.model.get(index).type)
                console.log("iteM : " + listView.model.get(index).id)
                console.log("iteM : " + listView.model.get(index).type.type)
                console.log("iteM : " + listView.model.get(index).type.id)
                var selectedId = listView.model.get(index).type.id;
                if (selectedId === 1) {
                    pageStack.push(Qt.resolvedUrl("ExploreByLocation.qml"), { selectedDate: selectedDate });
                } else if (selectedId === 2) {
                  pageStack.push(Qt.resolvedUrl("ExploreByAudience.qml"), { selectedDate: selectedDate });
                } else if (selectedId === 3) {
                  pageStack.push(Qt.resolvedUrl("ExploreByTrack.qml"), { selectedDate: selectedDate });
                } else if (selectedId === 4) {
                    pageStack.push(Qt.resolvedUrl("ExploreByTime.qml"), { selectedDate: selectedDate });
                } else {
                    console.log("other option not yet defined !");
                }
            }

        }
        VerticalScrollDecorator {}

        Component.onCompleted: {
            var types = Logic.types, i;
            for (i = 0; i < types.length; i++) {
                typeListModel.append(Logic.buildTypeEntry(i, types[i]));
            }
        }

    }


}
