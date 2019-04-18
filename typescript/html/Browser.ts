/// <reference path="DukeConServer" />
/// <reference path="Data" />

"use strict";

let printConferenceListFunction = (statusCode: number, conferenceList: Array<IConferenceData>) => {
    console.log("status code was : " + statusCode)
    if (conferenceList !== null) {
        conferenceList.forEach((conf) => console.log("confx : " + conf.name + " " + conf.startDate));
    }
};

let printSpeakerImageFunction = (statusCode: number, data: String) => {
    console.log("status code was : " + statusCode + "data : " + data)
    if (data !== null) {
        console.log("speaker image : " + data);
        document.getElementById("testimage").setAttribute("src", "data:image/png;base64," + data);
    }
};

interface RequestGetOptions {
    url: string;
    timeout: number;
    //body: string;
}

let fetchConferenceData = (statusCode: number, conferenceList: Array<IConferenceData>) => {
    console.log("status code was : " + statusCode)
    if (conferenceList !== null && conferenceList.length > 0) {
        let data = conferenceList.pop();
        let conferenceData = new ConferenceData(data);
        let conferenceManager = conferenceData.getConferenceManager();
        console.log("conference manager !" + conferenceManager);

    }
};

let conferenceListManager = new ConferenceListManager();
conferenceListManager.fetchConferences(printConferenceListFunction);

conferenceListManager.fetchConferences(fetchConferenceData);

console.log("ende");


let manager = new ConferenceManager(<IConference> javaforum2016);

manager.fetchSpeakerImage(printSpeakerImageFunction);

console.log("using manager : " + manager.getTrackMap().get("1").names.de);
console.log(manager.getDaysOfConference());
console.log("start Times : " + manager.getStartTimesForEventDay(manager.getDaysOfConference()[0]));

let days = manager.getDaysOfConference();
days.forEach((day) => console.log("day : " + day));

let locations = manager.getLocationsForEventDay(manager.getDaysOfConference()[0]);
locations.forEach((location) => console.log("location: " + location.names.de + " " + location.order + " " + location.id));

let events = manager.getEventsForDayAndLocation(manager.getDaysOfConference()[0], locations[2].id);
events.forEach((event) => console.log("event: " + event.start + " " + event.locationId + " " + event.title));

let tracks = manager.getTracksForEventDay(manager.getDaysOfConference()[0]);
tracks.forEach((track) => console.log("track: " + track.names.de + " " + track.order + " " + track.id));

let events2 = manager.getGenericEvents(manager.getDaysOfConference()[0], locations[2].id, locationIdFunction);
events2.forEach((event) => console.log("locations2: " + event.start + " " + event.locationId + " " + event.title));

let events3 = manager.getGenericEvents(manager.getDaysOfConference()[0], tracks[1].id, trackIdFunction);
events3.forEach((event) => console.log("tracks3: " + event.start + " " + tracks[1].names.de + " " + event.trackId + " " + event.title));

console.log("audiences for day 1");
let audiences = manager.getAudiencesForEventDay(manager.getDaysOfConference()[0]);
audiences.forEach((audience) => console.log("track: " + audience.names.de + " " + audience.order + " " + audience.id));

// console.log("audiences for day 2");
// audiences = manager.getAudiencesForEventDay(manager.getDaysOfConference()[1]);
// audiences.forEach((audience) => console.log("track: " + audience.names.de + " " + audience.order + " " + audience.id));


console.log("generic events");
let events4 = manager.getGenericEvents(manager.getDaysOfConference()[0], audiences[0].id, audienceIdFunction);
events4.forEach((event) => console.log("audiences4: " + event.start + " " + audiences[0].names.de + " " + event.trackId + " " + event.title));


let result = manager.getStartTimesForEventDayAsSelectBoxModelItems(manager.getDaysOfConference()[0]);
result.forEach((data) => console.log("data : " + data.getIndex() + ", " + data.getLabel()));

//console.log("event : " + manager.getEventById("497148").title);

//let speakers = manager.getSpeakerByIds(manager.getEventById("497148").speakerIds);
// speakers.forEach((speaker) => console.log("speaker : " + speaker.name));

//console.log("XXXXXXXXXXXXXXXXXXXXXX " + conferenceListManager.getConferences());
//console.log("dataurl: " + createUrlService().getConferenceDataUrl(<IConference> javaforum2016));
//console.log("imageurl: " + createUrlService().getConferenceImagesUrl(<IConference> javaforum2016);
