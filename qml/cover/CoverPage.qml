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

// QTBUG-34418
import "../pages/."

import "../pages/utils2.js" as Utils2
import "../pages/database.js" as Database

CoverBackground {

    id: coverPage

    Image {
        id: backgroundImage
        source: updateConferenceImage();
        fillMode: Image.PreserveAspectFit;
        //fillMode: Image.PreserveAspectCrop;
        //fillMode: Image.Tile;
        verticalAlignment: Image.AlignVCenter;
        horizontalAlignment: Image.AlignHCenter;
        anchors.fill: parent;
        opacity: 0.15
        transformOrigin: Item.Center
        rotation: 45
       // transform: Rotation { origin.x: backgroundImage.paintedWidth / 2; origin.y: backgroundImage.paintedHeight / 2; angle: 45}
    }

    Label {
        id: label
        anchors {
            margins: Theme.paddingLarge
            top: parent.top
        }
        x: Theme.horizontalPageMargin
        text: qsTr(getConferenceName());
        font.pixelSize: Theme.fontSizeTiny
    }

//    CoverActionList {
//        id: coverAction

//        CoverAction {
//            iconSource: "image://theme/icon-cover-previous"
//        }

//        CoverAction {
//            iconSource: "image://theme/icon-cover-pause"
//        }

//        CoverAction {
//            iconSource: "image://theme/icon-cover-next"
//        }
//    }

    onVisibleChanged: {
        console.log("onvisiblechanged cover");
        updateConferenceImage();
    }

    Component.onCompleted: {
        console.log("completed cover");
        updateConferenceImage();
    }

    function getConferenceName() {
        var manager = Utils2.createConferenceManager(GlobalDataModel.conferenceJsonData);
        return (manager.getName() === undefined ? "" : manager.getName());
    }

    function updateConferenceImage() {
        var manager = Utils2.createConferenceManager(GlobalDataModel.conferenceJsonData);
        var image = Database.loadConferenceImages(GlobalDataModel.conferenceJsonData.id, 'logo');
        // if no image could be found - reset the image - may be changed to a nice default image
        backgroundImage.source = (image !== null ? image : "");
    }

}

