
import QtQuick 2.0
import Sailfish.Silica 1.0

Column {
    id: columnSpeaker

    function addSocialLink(socialType, socialUrl) {
        if (socialUrl) {
           console.log("social link added " + socialUrl);
//           socialLinkModel.append({type: socialType, url: socialUrl});
            socialLinkModel.append({type: socialType, url: socialUrl});
        }
    }

    function addDocumentLink(documentType, documentUrl) {
        if (documentUrl) {
           console.log("document link added " + documentUrl);
//           socialLinkModel.append({type: socialType, url: socialUrl});
            documentLinkModel.append({type: documentType, url: documentUrl});
//            documentLinkModel.append({type: documentType, url: documentUrl});
//            documentLinkModel.append({type: documentType, url: documentUrl});
        }
    }


//     property variant speakerModel;

    property string defaultSpeakerImage: "../../images/UnknownUser.png";

    property alias labelSpeakerName: labelSpeakerName.text
    property alias labelSpeakerCompany: labelSpeakerCompany.text
    property alias imageSpeaker: imageSpeaker.source
    property alias labelSpeakerBio: labelSpeakerBio.text

//    property alias sectionHeaderWebLinks : sectionHeaderWebLinks.visible
//    property alias labelTwitter: labelTwitter.text
//    property alias labelWebsite: labelWebsite.text
//    property alias labelLinkedin: labelLinkedin.text
//    property alias labelXing: labelXing.text

//    property alias sectionHeaderDocuments: sectionHeaderDocuments.visible
//    property alias labelSlides: labelSlides.text
//    property alias labelManuscript: labelManuscript.text
//    property alias labelOther: labelOther.text


    visible: true
    width: parent.width
    spacing: Theme.paddingMedium

    ListModel {
        id: socialLinkModel
    }

    ListModel {
        id: documentLinkModel
    }


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
        visible: socialGrid.model.count > 0
        text: "Links"
        font.pixelSize: Theme.fontSizeExtraSmall
    }

    SilicaGridView {
        id: socialGrid

        function adjustGridDimensions() {
                            var columns = [5, 4, 3]
                            var adjusted = false
                            for (var i = 0; i < columns.length; i++) {
                                if (!adjusted && /*Screen.width*/ parent.width / columns[i] >= 130) {
                                    socialGrid.cellWidth = /* Screen.width*/ parent.width / columns[i]
                                    socialGrid.height = socialGrid.cellHeight * Math.ceil(socialLinkModel.count / columns[i])
                                    adjusted = true
                                }
                            }
                        }

        width: parent.width
        height: 130 * Math.ceil(socialLinkModel.count / 2)
        cellWidth: Screen.width / 2
        cellHeight: 130
        quickScroll: false
        interactive: false
        model: socialLinkModel

        Component.onCompleted: adjustGridDimensions()

        delegate: Item {
            width: socialGrid.cellWidth
            height: socialGrid.cellHeight

            Image {
                source: "../../images/social_" + type + ".svg";
                width: parent.width - 30
                height: parent.height - 30
                anchors {
                    centerIn: parent
                }
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    Qt.openUrlExternally(socialGrid.model.get(index).url);
                }
            }

        }
    }




    SectionHeader {
        id: sectionHeaderDocuments
        visible: documentGrid.model.count > 0
        text: qsTr("Documents")
        font.pixelSize: Theme.fontSizeExtraSmall
    }

    SilicaGridView {
        id: documentGrid

        function adjustGridDimensions() {
                            var columns = [5, 4, 3]
                            var adjusted = false
                            for (var i = 0; i < columns.length; i++) {
                                if (!adjusted && /*Screen.width*/ parent.width / columns[i] >= 218) {
                                    documentGrid.cellWidth = /* Screen.width*/ parent.width / columns[i]
                                    documentGrid.height = documentGrid.cellHeight * Math.ceil(documentLinkModel.count / columns[i])
                                    adjusted = true
                                }
                            }
                        }

        width: parent.width
        height: 130 * Math.ceil(documentLinkModel.count / 2)
        cellWidth: Screen.width / 2
        cellHeight: 130
        quickScroll: false
        interactive: false
        model: documentLinkModel
        y: Theme.horizontalPageMargin

        Component.onCompleted: adjustGridDimensions()

        delegate: Item {
            width: documentGrid.cellWidth
            height: documentGrid.cellHeight

                Image {
                    id: icon
                    source: "../../images/social_twitter.svg";
                    width: 100
                    height: 100
                    anchors.top: parent.top
                    anchors.horizontalCenter: parent.horizontalCenter
//                    anchors {
//                        horizontalCenter: parent
//                    }
                }

                Label {
                    text: "Type"
                    font.pixelSize: Theme.fontSizeTiny
                    anchors.top: icon.bottom
                    anchors.horizontalCenter: icon.horizontalCenter
//                    anchors {
//                        centerIn: parent
//                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        Qt.openUrlExternally(documentGrid.model.get(index).url);
                    }
                }


        }
    }


//    Label {
//        id: labelSlides
//        width: parent.width
//        font.pixelSize: Theme.fontSizeExtraSmall
//        wrapMode: Text.Wrap
//        visible: labelSlides.text.length > 0
//    }

//    Label {
//        id: labelManuscript
//        width: parent.width
//        font.pixelSize: Theme.fontSizeExtraSmall
//        wrapMode: Text.Wrap
//        visible: labelManuscript.text.length > 0
//    }

//    Label {
//        id: labelOther
//        width: parent.width
//        font.pixelSize: Theme.fontSizeExtraSmall
//        wrapMode: Text.Wrap
//        visible: labelOther.text.length > 0
//    }




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
