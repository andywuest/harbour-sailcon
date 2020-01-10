import QtQuick 2.0
import Sailfish.Silica 1.0

// derifed from PodcastItem.qml of gpodder

ListItem {
    id: linkItem

    contentHeight: Theme.itemSizeSmall // entry height - also spacing

    anchors {
        left: parent.left
        right: parent.right
    }

    Image {
        id: linkImage

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

    Label {
        id: titleLabel
        anchors {
            left: linkImage.right
            leftMargin: Theme.paddingLarge
            rightMargin: Theme.paddingMedium
            verticalCenter: parent.verticalCenter
        }

        truncationMode: TruncationMode.Fade
        text: type
    }

}

