
// use / create dfsic.used namespace
function getTrackMap(conferenceData) {
    var tracks = conferenceData.metaData.tracks
    var trackMap = {

    }
    for (var i = 0; i < tracks.length; i++) {
        trackMap["" + tracks[i].id] = tracks[i]
    }

    return trackMap
}
;

function getAudienceMap(conferenceData) {
    var audiences = conferenceData.metaData.audiences
    var audienceMap = {

    }
    for (var i = 0; i < audiences.length; i++) {
        audienceMap[audiences[i].id] = audiences[i]
    }
    return audienceMap
}
;

function determineDays(events) {

    var mapOfDays = {
    }, i;

    for (var p in events) {
        console.log("P : " + p)
    }

    console.log("events obj : " + events);
    console.log("events : " + events.length)

    for (i = 0; i < events.length; i++) {
        var day = events[i].start.substring(0, 10)
        // insert as key, values is irrelevant
        mapOfDays[day] = ""
    }

    var days = []
    for (var property in mapOfDays) {
        days.push(property)
    }

    return days.sort()
}
;

function getTracksForEventDay(selectedDay, events, trackMap) {

    var mapOfTrackIds = {

    }, i;

    for (i = 0; i < events.length; i++) {
        var day = events[i].start.substring(0, 10)
        if (day === selectedDay) {
            var trackId = events[i].trackId
            // insert as key, values is irrelevant
            mapOfTrackIds[trackId] = ""
        }
    }

    var selectedTracks = []

    for (var property in mapOfTrackIds) {
        console.log(property)
        var track = trackMap["" + property]
        selectedTracks.push(track)
    }

    // sort by sort order of the audiences
    return selectedTracks.sort(function (a, b) {
        return a.order > b.order
    })
}
;

function getAudiencesForEventDay(selectedDay, events, audienceMap) {

    var mapOfAudienceIds = {

    }

    for (i = 0; i < events.length; i++) {
        var day = events[i].start.substring(0, 10)
        if (day === selectedDay) {
            var audienceId = events[i].audienceId
            // insert as key, values is irrelevant
            mapOfAudienceIds[audienceId] = ""
        }
    }

    var selectedAudiences = []

    for (var property in mapOfAudienceIds) {
        selectedAudiences.push(audienceMap[property])
    }

    // sort by sort order of the audiences
    return selectedAudiences.sort(function (a, b) {
        return a.order > b.order
    })
}

function getLocationsForEventDay(selectedDay, events, locationMap) {

    var mapOfLocationIds = {

    }

    for (i = 0; i < events.length; i++) {
        var day = events[i].start.substring(0, 10)
        if (day === selectedDay) {
            var locationId = events[i].locationId
            // insert as key, values is irrelevant
            mapOfLocationIds[locationId] = ""
        }
    }

    var selectedLocations = []

    for (var property in mapOfLocationIds) {
        selectedLocations.push(locationMap[property])
    }

    // sort by sort order of the location
    return selectedLocations.sort(function (a, b) {
        return a.order > b.order
    })
}
;

function getEventsForDayAndAudience(selectedDay, audience, events) {
    // due to events with two speakers
    var mapOfEvents = {

    }

    for (i = 0; i < events.length; i++) {
        var day = events[i].start.substring(0, 10)
        if (day === selectedDay && events[i].audienceId === audience.id) {
            mapOfEvents[events[i].id] = events[i]
        }
    }

    // use map to filter duplicates
    var selectedEvents = []
    for (var property in mapOfEvents) {
        selectedEvents.push(mapOfEvents[property])
    }

    // sort by sort order of the events
    return selectedEvents.sort(function (a, b) {
        return a.start > b.start
    })
}
;

function getEventsForDayAndTrack(selectedDay, track, events) {
    // due to events with two speakers
    var mapOfEvents = {

    }, i;

    for (i = 0; i < events.length; i++) {
        var day = events[i].start.substring(0, 10)
        if (day === selectedDay && events[i].trackId === track.id) {
            mapOfEvents[events[i].id] = events[i]
        }
    }

    // use map to filter duplicates
    var selectedEvents = []
    for (var property in mapOfEvents) {
        selectedEvents.push(mapOfEvents[property])
    }

    // sort by sort order of the events
    return selectedEvents.sort(function (a, b) {
        return a.start > b.start
    })
}
;

function getEventsForStartDayAndLocation(selectedDay, location, events) {

    // due to events with two speakers
    var mapOfEvents = {

    }

    for (i = 0; i < events.length; i++) {
        var day = events[i].start.substring(0, 10)
        if (day === selectedDay && events[i].locationId === location.id) {
            mapOfEvents[events[i].id] = events[i]
        }
    }

    // use map to filter duplicates
    var selectedEvents = []
    for (var property in mapOfEvents) {
        selectedEvents.push(mapOfEvents[property])
    }

    // sort by sort order of the location
    return selectedEvents.sort(function (a, b) {
        return a.start > b.start
    })
}
;

function getStartTimesForEventDay(selectedDay, events) {

    var mapOfStartTimes = {

    }

    for (i = 0; i < events.length; i++) {
        var day = events[i].start.substring(0, 10)
        if (day === selectedDay) {
            var startTime = events[i].start.substring(11)
            // insert as key, values is irrelevant
            mapOfStartTimes[startTime] = ""
        }
    }

    var startTimes = []
    for (var property in mapOfStartTimes) {
        startTimes.push(property)
    }

    return startTimes.sort()
}
;

function getEventsForStartTimesAndDay(selectedStartTime, selectedDay, events, locationMap) {

    var mapOfEvents = {

    }

    var eventStart = selectedDay + "T" + selectedStartTime

    for (i = 0; i < events.length; i++) {
        var currentEventStart = events[i].start

        if (currentEventStart === eventStart) {
            mapOfEvents[events[i].id] = events[i]
        }
    }

    // use map to filter duplicates
    var selectedEvents = []
    for (var property in mapOfEvents) {
        selectedEvents.push(mapOfEvents[property])
    }

    // sort by sort order of the location
    return selectedEvents.sort(function (a, b) {
        return locationMap[a.locationId].order > locationMap[b.locationId].order
    })
}
;
