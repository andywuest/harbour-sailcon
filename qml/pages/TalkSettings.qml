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
import QtQuick.LocalStorage 2.0
import Sailfish.Silica 1.0

import "../js/logic.js" as Logic

Page {
    id: eventPage
    property string eventId
    property bool ratingEnabled : false
    property bool favorite : false
    property int rating : 2

    function openConnection() {
        var db = LocalStorage.openDatabaseSync('harbour-sailcon', '', 'Talk Data', 5000);

        if (db.version === '') {
            db.changeVersion('', '1.0', function(txn) {
                txn.executeSql('CREATE TABLE talk (talkId INTEGER NOT NULL, favorite BOOLEAN NOT NULL DEFAULT false, rated BOOLEAN NOT NULL DEFAULT false, rating INTEGER)')
            });
        }

        return db;
    }

    function loadTalkData(talkId) {
        var db = openConnection();

        console.log('loading talk data ');

        db.transaction(function(tx) {
            var rs = tx.executeSql('SELECT * FROM talk WHERE talkId = ?', [talkId]);

            if (rs.rows.length > 0) {
                var row = rs.rows.item(0);
                console.log(" favorite : " + row.favorite);
                console.log(" rated : " + row.rated + ", rated === true" + (row.rated === true) + ", " + (row.rated === false));
                console.log(" rating : " + row.rating);
                favorite = row.favorite;
                ratingEnabled = row.rated;
                rating = row.rating;

                // update the UI component state
                markFavoriteSwitch.checked = favorite;
                rateTalkSwitch.checked = ratingEnabled;
                slider.enabled = ratingEnabled;
                slider.value = rating;

            } else {
                console.log("talkid " + talkId + " not found");
            }

        });
    }

    function storeTalkData(talkId, favorite, rated, rating) {
        var db = openConnection();

        db.transaction(function(tx) {
            var rs = tx.executeSql('SELECT * FROM talk WHERE talkId = ?', [talkId]);

            console.log("values : " + talkId + ", " + favorite + ", " + rated + ", " + rating )

            if (rs.rows.length === 0) {
                tx.executeSql('INSERT INTO talk VALUES (?, ?, ?, ?)', [talkId, favorite, rated, rating]);
            } else if (rs.rows.length === 1) {
                tx.executeSql('UPDATE talk SET favorite = ?, rated = ?, rating = ? WHERE talkId = ?', [favorite, rated, rating, talkId])
            }

        });
    }

    Component.onCompleted: {
        loadTalkData(eventId);
    }

    // To enable PullDownMenu, place our content in a SilicaFlickable
    SilicaFlickable {
        anchors.fill: parent

        // Tell SilicaFlickable the height of its content.
        contentHeight: column.height

        // Place our content in a Column.  The PageHeader is always placed at the top
        // of the page, followed by our content.
        Column {
            id: column

            width: eventPage.width
            spacing: Theme.paddingLarge
            PageHeader {
                title: qsTr("Talk Settings")
            }

            TextSwitch {
                id: markFavoriteSwitch
                text: "Mark Talk"
                description: "Mark the talk as favorite"
                onCheckedChanged: {
                    storeTalkData(eventId, markFavoriteSwitch.checked, rateTalkSwitch.checked, slider.value);
                }
            }

            TextSwitch {
                id: rateTalkSwitch
                text: "Rate talk"
                description: "Allows rating of the talk"
                onCheckedChanged: {
                    ratingEnabled = checked
                    slider.enabled = ratingEnabled
                    console.log(" active " +  checked);
                    storeTalkData(eventId, markFavoriteSwitch.checked, rateTalkSwitch.checked, slider.value);
                }
            }

            // an interactive slider with a 0-100 range that steps by 1 when slided.
            Slider {

                id: slider
                label: "Talk rating"
                width: parent.width
                minimumValue: 0
                maximumValue: 4
                enabled: ratingEnabled
                stepSize: 1
                valueText: Logic.rating[value]
                // highlighted: ratingEnabled
                visible: ratingEnabled

                onSliderValueChanged: {
                    storeTalkData(eventId, markFavoriteSwitch.checked, rateTalkSwitch.checked, slider.value);
                }
            }

        }
    }
}
