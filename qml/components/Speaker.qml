
import QtQuick 2.0
import Sailfish.Silica 1.0

Column {
    id: columnSpeaker

//     property variant speakerModel;

    property string defaultSpeakerImage: "../../images/UnknownUser.png";

    property alias labelSpeakerName: labelSpeakerName.text
    property alias labelSpeakerCompany: labelSpeakerCompany.text
    property alias imageSpeaker: imageSpeaker.source
    property alias labelSpeakerBio: labelSpeakerBio.text

    property alias sectionHeaderWebLinks : sectionHeaderWebLinks.visible
    property alias labelTwitter: labelTwitter.text
    property alias labelWebsite: labelWebsite.text
    property alias labelLinkedin: labelLinkedin.text
    property alias labelXing: labelXing.text

    property alias sectionHeaderDocuments: sectionHeaderDocuments.visible
    property alias labelSlides: labelSlides.text
    property alias labelManuscript: labelManuscript.text
    property alias labelOther: labelOther.text


    visible: true
    width: parent.width
    spacing: Theme.paddingMedium

  //   bottom: Theme.paddingLarge

//     spacing: Theme.paddingMedium

    Row {
        id: rowSpeakerImageAndName
//        x: Theme.horizontalPageMargin
        width: parent.width// - 2*x
//        spacing: Theme.paddingLarge

        Image {
            id:  imageSpeaker
            width: (parent.width / 2) - (2 * Theme.horizontalPageMargin)
            fillMode: Image.PreserveAspectFit
            onStatusChanged:  {
                console.log("status changed !");
                if (imageSpeaker.status == Image.Ready) console.log('Loaded')
                   if (imageSpeaker.status == Image.Error) console.log('Error')
                   if (imageSpeaker.status == Image.Null) console.log('Null')
            }
              //x: Theme.horizontalPageMargin
            //y: Theme.horizontalPageMargin
        }

        Column {
            spacing: Theme.paddingSmall
            x: (parent.width / 2) + Theme.horizontalPageMargin
            width: (parent.width / 2) - (2 * Theme.horizontalPageMargin)

            Label {
               id: labelSpeakerName
               x: Theme.horizontalPageMargin

               width: parent.width
               font.pixelSize: Theme.fontSizeMedium
               wrapMode: Text.Wrap
            }

            Label {
                id: labelSpeakerCompany
                x: Theme.horizontalPageMargin

                width: parent.width
                font.pixelSize: Theme.fontSizeExtraSmall
                wrapMode: Text.Wrap
            }
        }
    }

    Label {
        id: labelSpeakerBio
//        x: Theme.horizontalPageMargin

        width: parent.width// - 2*x
        font.pixelSize: Theme.fontSizeExtraSmall
        wrapMode: Text.Wrap
    }

    SectionHeader {
        id: sectionHeaderWebLinks
        text: "Links"
        font.pixelSize: Theme.fontSizeExtraSmall
    }

    Label {
        id: labelTwitter
        width: parent.width
        font.pixelSize: Theme.fontSizeExtraSmall
        wrapMode: Text.Wrap
        visible: labelTwitter.text.length > 0
    }

    Label {
        id: labelWebsite
        width: parent.width
        font.pixelSize: Theme.fontSizeExtraSmall
        wrapMode: Text.Wrap
        visible: labelWebsite.text.length > 0
    }

    Label {
        id: labelLinkedin
        width: parent.width
        font.pixelSize: Theme.fontSizeExtraSmall
        wrapMode: Text.Wrap
        visible: labelLinkedin.text.length > 0
    }

    Label {
        id: labelXing
        width: parent.width
        font.pixelSize: Theme.fontSizeExtraSmall
        wrapMode: Text.Wrap
        visible: labelXing.text.length > 0
    }

//    Image {
//        id: imgXing
//        source: "../../images/social_xing.svg"
//    }


    SectionHeader {
        id: sectionHeaderDocuments
        text: qsTr("Documents")
        font.pixelSize: Theme.fontSizeExtraSmall
    }

    Label {
        id: labelSlides
        width: parent.width
        font.pixelSize: Theme.fontSizeExtraSmall
        wrapMode: Text.Wrap
        visible: labelSlides.text.length > 0
    }

    Label {
        id: labelManuscript
        width: parent.width
        font.pixelSize: Theme.fontSizeExtraSmall
        wrapMode: Text.Wrap
        visible: labelManuscript.text.length > 0
    }

    Label {
        id: labelOther
        width: parent.width
        font.pixelSize: Theme.fontSizeExtraSmall
        wrapMode: Text.Wrap
        visible: labelOther.text.length > 0
    }




//    Row {
//        id: rowSeparator
//        spacing: Theme.paddingLarge
//        width: parent.width
//        height: Theme.itemSizeMedium


        Separator {
            id: separator
            width:parent.width;
//            x: Theme.horizontalPageMargin
            color: Theme.highlightColor
//            bottom: Theme.paddingLarge
        }




//    }


//    property alias label: label.text
//    property alias text: text.text
//    property alias font: text.font
//    property alias separator: separator.visible
//    property alias color: text.color

//    spacing: Theme.paddingMedium

//    anchors {
//        right: parent.right
//        left: parent.left
//    }

//    Label {
//        id: label
//        anchors {
//            left: parent.left
//        }
//        width: parent.width
//        color: Theme.highlightColor
//        font.pixelSize: Theme.fontSizeExtraSmall
//    }
//    Label {
//        id: text
//        anchors {
//            left: parent.left
//        }
//        color: Theme.primaryColor
//        font.pixelSize: Theme.fontSizeSmall
//        wrapMode: Text.Wrap
//        width: parent.width - (2 * Theme.paddingLarge)
//    }
//    Separator {
//        id: separator
//        width:parent.width;
//        color: Theme.highlightColor
//    }

}
