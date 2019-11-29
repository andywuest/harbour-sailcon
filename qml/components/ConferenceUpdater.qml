import QtQuick 2.0
import Sailfish.Silica 1.0
import QtQuick.LocalStorage 2.0

// QTBUG-34418
import "."

import "../js/constants.js" as Constants

Item {
    id: conferenceUpdater

    signal subLoadingLabelChanged(string label)
    signal loadingFinished
    signal errorOccured(string errorMessage)

    function downloadConferenceData(data) {
        if (Constants.SINGLE) {
            dukeconBackend.downloadAllData(Constants.SINGLE, data.name)
            return
        }
    }

    Connections {
        target: dukeconBackend
        onSubLoadingLabelAvailable: {
            conferenceUpdater.subLoadingLabelChanged(reply)
        }
        onLoadingDataFinished: {
            conferenceUpdater.loadingFinished()
        }
        onRequestError: {
            conferenceUpdater.errorOccured(errorMessage)
        }
    }
}
