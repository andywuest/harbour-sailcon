import QtQuick 2.0
import Sailfish.Silica 1.0

// derifed from PodcastItem.qml of gpodder

ListItem {
    id: linkItem

    contentHeight: Theme.itemSizeMedium

    anchors {
        left: parent.left
        right: parent.right
    }

    Image {
        id: cover
        visible: true// !updating && coverart

        anchors {
            left: parent.left
            leftMargin: Theme.paddingMedium
            verticalCenter: parent.verticalCenter
        }

        sourceSize.width: width
        sourceSize.height: height

        width: Theme.iconSizeMedium
        height: Theme.iconSizeMedium

        source: image
    }

//    Rectangle {
//        anchors.fill: cover
//        visible: !updating && !coverart
//        color: Theme.rgba(Theme.highlightColor, 0.5)

//        clip: true

//        Label {
//            anchors.centerIn: parent

//            font.pixelSize: parent.height * 0.8
//            text: title[0]
//            color: Theme.highlightColor
//        }
//    }

//    BusyIndicator {
//        anchors.centerIn: cover
//        visible: updating
//        running: visible
//    }

    Label {
        id: titleLabel
        anchors {
            left: cover.right
            // leftMargin: Theme.paddingMedium
            leftMargin: Theme.paddingLarge
            rightMargin: Theme.paddingMedium
//            right: downloadsLabel.left
            verticalCenter: parent.verticalCenter
        }

        truncationMode: TruncationMode.Fade
        text: type
        // color: (newEpisodes || podcastItem.highlighted) ? Theme.highlightColor : Theme.primaryColor
    }

//    Label {
//        id: downloadsLabel
//        anchors {
//            right: parent.right
//            rightMargin: Theme.paddingMedium
//            verticalCenter: parent.verticalCenter
//        }

//        color: titleLabel.color
//        text: '' // 'downloaded ? downloaded : ''
//    }
}

