import QtQuick 2.1
import Sailfish.Silica 1.0
import "../components"

import "constants.js" as Constants

Page {
    id: settingsPage

    SilicaFlickable {
        id: settingsFlickable
        anchors.fill: parent

        // Tell SilicaFlickable the height of its content.
        contentHeight: column.height

        // Place our content in a Column.  The PageHeader is always placed at the top
        // of the page, followed by our content.
        Column {
            id: column

            width: settingsPage.width
            spacing: Theme.paddingLarge
            PageHeader {
                title: qsTr("Settings")
            }

            TextSwitch {
                id: downloadSpeakerImagesSwitch
                text: "Download speaker images"
                description: "Downloads the speaker images when fetching the conference data."
                onCheckedChanged: {
                    console.log("state changed");
                }
            }
        }
   }
}
