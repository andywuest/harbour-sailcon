import QtQuick 2.0
import Sailfish.Silica 1.0
// QTBUG-34418
import "."

import "thirdparty"
import "../js/constants.js" as Constants

Column {
    id: columnSpeaker

    function addSocialLink(socialType, socialUrl) {
        if (socialUrl) {
            var imageUrl = "../../../images/social_" + socialType + ".svg"
            if (socialType === 'website') {
                imageUrl = "../../../images/icon-launcher-browser.svg"
            }
            socialLinkListModel.append({
                                           type: Constants.LINK_NAME_MAP[socialType],
                                           url: socialUrl,
                                           image: imageUrl
                                       })
        }
    }

    //     property variant speakerModel;
    property string defaultSpeakerImage: "../../images/UnknownUser.png"

    property alias labelSpeakerName: labelSpeakerName.text
    property alias labelSpeakerCompany: labelSpeakerCompany.text
    property alias imageSpeaker: imageSpeaker.source
    property alias labelSpeakerBio: labelSpeakerBio.text

    visible: true
    width: parent.width
    spacing: Theme.paddingMedium

    ListModel {
        id: socialLinkListModel
    }

    Row {
        id: rowSpeakerImageAndName
        width: parent.width

        Image {
            id: imageSpeaker
            width: (parent.width / 2) - (2 * Theme.horizontalPageMargin)
            fillMode: Image.PreserveAspectFit
            source: ""
        }

        Column {
            spacing: Theme.paddingSmall
            x: (parent.width / 2) + Theme.horizontalPageMargin
            width: (parent.width / 2) - (2 * Theme.horizontalPageMargin)

            Label {
                id: labelSpeakerName
                x: Theme.horizontalPageMargin

                text: ""
                width: parent.width
                font.pixelSize: Theme.fontSizeMedium
                wrapMode: Text.Wrap
            }

            Label {
                id: labelSpeakerCompany
                x: Theme.horizontalPageMargin

                text: ""
                width: parent.width
                font.pixelSize: Theme.fontSizeExtraSmall
                wrapMode: Text.Wrap
            }
        }
    }

    Label {
        id: labelSpeakerBio
        width: parent.width
        text: ""
        font.pixelSize: Theme.fontSizeExtraSmall
        wrapMode: Text.Wrap
    }

    SectionHeader {
        id: sectionHeaderWebLinks
        visible: socialLinkListModel.count > 0
        text: qsTr("Links")
        font.pixelSize: Theme.fontSizeExtraSmall
    }

    Repeater {
        id: socialLinkList
        anchors.fill: parent

        model: socialLinkListModel

        delegate: LinkItem {
            onClicked: {
                console.log("url : " + socialLinkListModel.get(index).url)
                Qt.openUrlExternally(socialLinkListModel.get(index).url)
            }
        }
    }

    Separator {
        id: separator
        width: parent.width
        color: Theme.highlightColor
    }

}
