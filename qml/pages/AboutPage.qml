
import QtQuick 2.1
import Sailfish.Silica 1.0
import QtQuick.LocalStorage 2.0

import "../components/thirdparty"

import "../js/constants.js" as Constants
import "../js/database.js" as Database

// from code reader
// https://raw.githubusercontent.com/monich/sailfish-barcode/master/qml/components/LabelText.qml

Page {
    id: aboutPage

    SilicaFlickable {
        id: aboutPageFlickable
        anchors.fill: parent
        contentHeight: aboutColumn.height

        PullDownMenu {
            MenuItem {
                text: qsTr("Reset Database")
                onClicked: {
                    Database.resetApplication();
                    Database.initApplicationTables();
                }
            }
        }

        Column {
            PageHeader {
                //: About page title - header
                //% "About SailCon"
                title: qsTr("About SailCon")
            }

            id: aboutColumn
            anchors { left: parent.left; right: parent.right }
            height: childrenRect.height

            LabelText {
                anchors {
                    left: parent.left
                    margins: Theme.paddingLarge
                }
                //: About page title - about text title
                //% "About SailCon"
                label: qsTr("About SailCon")
                //: About page text - about text
                //% "This is app is a native Sailfish OS client for DukeCon. SailCon is open source and licensed under the GPL v3."
                text: qsTr("This is app is a native Sailfish OS client for DukeCon. SailCon is open source and licensed under the GPL v3.")
                separator: true
            }

            LabelText {
                anchors {
                    left: parent.left
                    margins: Theme.paddingLarge
                }
                //: About page version label
                //% "Version"
                label: qsTr("Version")
                text: Constants.VERSION
                separator: true
            }

            LabelText {
                anchors {
                    left: parent.left
                    margins: Theme.paddingLarge
                }
                //: About page author label
                //% "Author"
                label: qsTr("Author")
                text: "Andreas Wüst"
                separator: true
            }

            BackgroundItem {
                id: clickableUrl
                contentHeight: labelUrl.height
                height: contentHeight
                width: aboutPageFlickable.width
                anchors {
                    left: parent.left
                }

                LabelText {
                    id: labelUrl
                    anchors {
                        left: parent.left
                        margins: Theme.paddingLarge
                    }
                    //: About page about source label
                    //% "Source code"
                    label: qsTr("Source code")
                    text: "https://github.com/andywuest/harbour-sailcon"
                    color: clickableUrl.highlighted ? Theme.highlightColor : Theme.primaryColor
                }
                onClicked: Qt.openUrlExternally(labelUrl.text);
            }
        }
    }

    VerticalScrollDecorator { flickable: aboutPageFlickable }
}
