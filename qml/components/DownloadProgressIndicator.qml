/*
    Copyright (C) 2017-19 Sebastian J. Wolf

    This file is part of Piepmatz.

    Piepmatz is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    Piepmatz is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with Piepmatz. If not, see <http://www.gnu.org/licenses/>.
*/
import QtQuick 2.0
import Sailfish.Silica 1.0

Item {

    id: downloadProgressIndicator

    property bool withOverlay: true

    width: parent.width
    height: parent.height
    Rectangle {
        id: downloadProgressOverlay
        color: "black"
        opacity: 0.7
        width: parent.width
        height: parent.height
        visible: downloadProgressIndicator.withOverlay
    }

    Column {
        width: parent.width
        height: downloadProgressLabel.height + downloadProgressBusyIndicator.height + Theme.paddingMedium
        spacing: Theme.paddingMedium
        anchors.verticalCenter: parent.verticalCenter

        Label {
            id: downloadProgressLabel
            font.pixelSize: Theme.fontSizeMedium
            text: qsTr("Loading...")
        }

        Label {
            id: downloadConferenceDataLabel
            font.pixelSize: Theme.fontSizeMedium
            text: qsTr("Loading conference data")
        }

        Label {
            id: downloadConferenceImageLabel
            font.pixelSize: Theme.fontSizeMedium
            text: qsTr("Loading conference image")
        }

        Label {
            id: downloadSpeakerImagesLabel
            font.pixelSize: Theme.fontSizeMedium
            text: qsTr("Loading speaker images 3/23")
        }


        BusyIndicator {
            id: downloadProgressBusyIndicator
            anchors.horizontalCenter: parent.horizontalCenter
            running: downloadProgressIndicator.visible
            size: BusyIndicatorSize.Large
        }
    }

}
