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

import "utils.js" as Utils
import "jfs2016.js" as Data
import "logic.js" as Logic

Page {
    id: page
    SilicaListView {
        id: listView
        model: ListModel {
            id: dayAndTimeListModel
        }
        anchors.fill: parent
        header: PageHeader {
            title: qsTr("Day : ")
        }
        delegate: BackgroundItem {
            id: delegate

            Label {
                x: Theme.paddingLarge
                text: "" + date
                anchors.verticalCenter: parent.verticalCenter
                color: delegate.highlighted ? Theme.highlightColor : Theme.primaryColor
            }
            onClicked: {
                console.log("Clicked " + index)
                console.log("iteM : " + listView.model.get(index))
                console.log("iteM : " + listView.model.get(index).date)
                console.log("iteM : " + listView.model.get(index).index)
            }

        }
        VerticalScrollDecorator {}

        Component.onCompleted: {
            var days = Utils.determineDays(Data.javaforum2016.events), i;
            for (i = 0; i < days.length; i++) {
                dayAndTimeListModel.append(Logic.buildDateAndTimeEntry(i, days[i], "TODO"));
            }
        }

    }


}
