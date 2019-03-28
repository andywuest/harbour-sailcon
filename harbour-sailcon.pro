# NOTICE:
#
# Application name defined in TARGET has a corresponding QML filename.
# If name defined in TARGET is changed, the following needs to be done
# to match new name:
#   - corresponding QML filename must be changed
#   - desktop icon filename must be changed
#   - desktop filename must be changed
#   - icon definition filename in desktop file must be changed
#   - translation filenames have to be changed


# The name of your application
TARGET = harbour-sailcon

CONFIG += sailfishapp

SOURCES += src/harbour-sailcon.cpp

OTHER_FILES += qml/harbour-sailcon.qml \
    qml/cover/CoverPage.qml \
    qml/pages/FirstPage.qml \
    qml/pages/SecondPage.qml \
    qml/pages/qmldir \
    rpm/harbour-sailcon.changes.in \
    rpm/harbour-sailcon.spec \
    rpm/harbour-sailcon.yaml \
    images/jfs.png \
    translations/*.ts \
    harbour-sailcon.desktop

SAILFISHAPP_ICONS = 86x86 108x108 128x128 256x256

# to disable building translations every time, comment out the
# following CONFIG line
#CONFIG += \
#    sailfishapp_i18n \
#    sailfishapp_i18n_idbased

# German translation is enabled as an example. If you aren't
# planning to localize your app, remember to comment out the
# following TRANSLATIONS line. And also do not forget to
# modify the localized app name in the the .desktop file.
TRANSLATIONS += \
    translations/harbour-sailcon-de.ts

DISTFILES += \
    qml/pages/Third.qml \
    qml/pages/logic.js \
    qml/pages/Talk.qml \
    qml/pages/TalkSettings.qml \
    qml/pages/utils.js \
    qml/pages/jfs2016.js \
    qml/pages/ExploreByDay.qml \
    qml/pages/ExploreByDayAndTime.qml \
    qml/pages/ExplorationTypeSelection.qml \
    qml/pages/ExploreByTrack.qml \
    qml/pages/Talks.qml \
    qml/pages/utils2.js \
    qml/pages/ExploreByTime.qml \
    qml/pages/ExploreByLocation.qml \
    qml/pages/ExploreByAudience.qml \
    qml/pages/TalkOld.qml \
    qml/pages/SelectConference.qml \
    qml/pages/LoadingIndicator.qml \
    qml/pages/GlobalDataModel.qml \
    qml/pages/qmldir \
    qml/pages/TODO.txt \
    qml/pages/constants.js \
    images/j.png \
    images/UnknownUser.png \
    images/social_xing.svg \
    qml/components/AppNotification.qml \
    qml/components/AppNotificationItem.qml \
    qml/pages/database.js \
    qml/pages/About.qml \
    qml/components/LabelText.qml \
    qml/components/Speaker.qml \
    qml/pages/Settings.qml \
    qml/components/DownloadProgressIndicator.qml


qmldir.files = qml/pages/qmldir

images.files = images
images.path = /usr/share/$${TARGET}

INSTALLS += images
