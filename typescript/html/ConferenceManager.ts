class ConferenceManager {

    private conference: IConference;
    private trackMap: Map<ITrack>;
    private audienceMap: Map<IAudience>;
    private locationMap: Map<ILocation>;
    private eventMap: Map<IEvent>;

    private sortByOrder = (leftSide: IOrder, rightSide: IOrder): number => {
        if (leftSide.order < rightSide.order) return -1;
        if (leftSide.order > rightSide.order) return 1;
        return 0;
    }

    constructor(conference: IConference) {
        this.conference = conference;
        this.trackMap = new Map();
        this.audienceMap = new Map();
        this.locationMap = new Map();
        this.eventMap = new Map();
    }

    getName(): string {
        return this.conference.name;
    }

    convertToDate(dateString: string): Date {
        if (dateString !== null && dateString.length > 0) {
            return new Date(Date.parse(dateString));
        }
        return null;
    }

    trimToEmpty(value: string): string {
        if (value === null || value === undefined) {
            return "";
        }
        return value;
    }

    getEventsForTrack(selectedDay: string, id: string): Array<IEvent> {
        return this.getGenericEvents(selectedDay, id, trackIdFunction);
    }

    getEventsForAudience(selectedDay: string, id: string): Array<IEvent> {
        return this.getGenericEvents(selectedDay, id, audienceIdFunction);
    }

    getEventsForLocation(selectedDay: string, id: string): Array<IEvent> {
        return this.getGenericEvents(selectedDay, id, locationIdFunction);
    }

    getEventsForTime(selectedDay: string, startTime: string): Array<IEvent> {
        let events = this.conference.events.filter((event) => event.start === startTime);
        // TODO sorting - selectedDay ist implizit schon in startTime
        return events;
    }

    getLocationsForEventDayAsSelectBoxModelItems(selectedDay: string): Array<SelectBoxModelItem> {
        let result: Array<SelectBoxModelItem> = new Array();
        let data: Array<ILocation>;
        data = this.getLocationsForEventDay(selectedDay);
        data.forEach((location, index) => result.push(new SelectBoxModelItem(index, location.id, location.names.de)));
        return result;
    }

    getTracksForEventDayAsSelectBoxModelItems(selectedDay: string): Array<SelectBoxModelItem> {
        let result: Array<SelectBoxModelItem> = new Array();
        let data: Array<ITrack>;
        data = this.getTracksForEventDay(selectedDay);
        data.forEach((track, index) => result.push(new SelectBoxModelItem(index, track.id, track.names.de)));
        return result;
    }

    getAudiencesForEventDayAsSelectBoxModelItems(selectedDay: string): Array<SelectBoxModelItem> {
        let result: Array<SelectBoxModelItem> = new Array();
        let data: Array<IAudience>;
        data = this.getAudiencesForEventDay(selectedDay);
        data.forEach((audience, index) => result.push(new SelectBoxModelItem(index, audience.id, audience.names.de)));
        return result;
    }

    getStartTimesForEventDayAsSelectBoxModelItems(selectedDay: string): Array<SelectBoxModelItem> {
        let result: Array<SelectBoxModelItem> = new Array();
        let data: Array<string>;
        data = this.getStartTimesForEventDay(selectedDay);
        console.log("numb. of audiences found : " + data.length);
        data.forEach((day, index) => result.push(new SelectBoxModelItem(index, day, this.extractTime(day) + " Uhr")));
        console.log("numb. of result audiences : " + result.length);
        return result;
    }

    getStartTimesForEventDay(selectedDay: string): Array<string> {
        let startTimes: Array<string> = new Array();

        this.conference.events.forEach((event) => {
            let day = this.extractDay(event.start);
            let startDayTime = event.start;
            if (day === selectedDay && startTimes.indexOf(startDayTime) < 0) {
                startTimes.push(startDayTime);
            }
        });

        return startTimes.sort();
    }

    getDaysOfConference(): Array<string> {
        let days: Array<string> = new Array();

        this.conference.events.forEach((event) => {
            let day = this.extractDay(event.start);
            if (days.indexOf(day) < 0) {
                days.push(day);
            }
        });

        return days.sort();
    }

    isSingleDayConference(): boolean {
        return (this.getDaysOfConference().length == 1);
    }

    getAudiencesForEventDay(selectedDay: string): Array<IAudience> {
        let audienceIds: Array<string> = new Array();
        let audiences: Array<IAudience> = new Array();

        this.conference.events
            .filter(event => event.audienceId !== undefined) // only events that have a audience id
            .forEach(event => {
                let day = this.extractDay(event.start);
                if (day === selectedDay && audienceIds.indexOf(event.audienceId) < 0) {
                    audienceIds.push(event.audienceId);
                }
            })

        let audienceMap = this.getAudienceMap();

        audienceIds.forEach((audienceId) => audiences.push(audienceMap.get(audienceId)));

        return audiences.sort(this.sortByOrder);
    }

    getTracksForEventDay(selectedDay: string): Array<ITrack> {
        let trackIds: Array<string> = new Array();
        let tracks: Array<ITrack> = new Array();

        this.conference.events
            .filter(event => event.trackId !== undefined) // only events that have a track id
            .forEach(event => {
                let day = this.extractDay(event.start);
                if (day === selectedDay && trackIds.indexOf(event.trackId) < 0) {
                    trackIds.push(event.trackId);
                }
            })

        let trackMap = this.getTrackMap();

        trackIds.forEach((trackId) => tracks.push(trackMap.get(trackId)));

        return tracks.sort(this.sortByOrder);
    }

    getLocationsForEventDay(selectedDay: string): Array<ILocation> {
        let locationIds: Array<string> = new Array();
        let locations: Array<ILocation> = new Array();

        this.conference.events.forEach((event) => {
            let day = this.extractDay(event.start);
            if (day === selectedDay && locationIds.indexOf(event.locationId) < 0) {
                locationIds.push(event.locationId);
            }
        });

        let locationMap = this.getLocationMap();

        locationIds.forEach((locationId) => locations.push(locationMap.get(locationId)));

        return locations.sort(this.sortByOrder);
    }

    getEventsForDayAndLocation(selectedDay: string, locationId: string): Array<IEvent> {
        let eventIds: Array<string> = new Array();
        let events: Array<IEvent> = new Array();

        this.conference.events.forEach((event) => {
            let day = this.extractDay(event.start);
            if (day === selectedDay && locationId === event.locationId && eventIds.indexOf(event.id) < 0) {
                eventIds.push(event.id);
            }
        });

        let eventMap = this.getEventMap();

        eventIds.forEach((eventId) => events.push(eventMap.get(eventId)));

        return events.sort((leftSide, rightSide): number => {
            if (leftSide.start > rightSide.start) return 1;
            if (leftSide.start < rightSide.start) return -1;
            return 0;
        });
    }

    getSpeakerByIds(ids: string[]): Array<Speaker> {
        let speakers = this.conference.speakers.filter(speaker => {
            return (ids.indexOf(speaker.id) > -1);
        }).map(sp => new Speaker(sp))
        return speakers;
    }

    getSpeakerPhotoIdUrls(baseUrl: string): Array<string> {
        let speakerPhotoIds = this.conference.speakers
            .filter(speaker => speaker.photoId != null)
            .filter(speaker => speaker.photoId != "")
            .map(speaker => baseUrl + speaker.photoId);
        return speakerPhotoIds;
    }

    getEventById(eventId: string): EventTalk {
        let event = this.conference.events.filter(event => event.id === eventId)[0];
        return new EventTalk(event);
    }

    getSpeakersForEvent(eventId: string): Array<Speaker> {
        let event = this.getEventById(eventId);
        return this.getSpeakerByIds(event.speakerIds);
    }

    // TODO consolidate language specfici access
    getLocationName(locationId: string, language: string): string {
        let names = this.getLocationMap().get(locationId).names;
        if ("de" === language) {
            return names.de;
        } else {
            return names.en;
        }
    }

    getAudienceName(audienceId: string, language: string): string {
        let names = this.getAudienceMap().get(audienceId).names;
        if ("de" === language) {
            return names.de;
        } else {
            return names.en;
        }
    }

    getTrackName(trackId: string, language: string): string {
        let names = this.getTrackMap().get(trackId).names;
        if ("de" === language) {
            return names.de;
        } else {
            return names.en;
        }
    }

    /**
     * id : the id that the function has to match to select the event
     * idFunction : is a function definition that resturs the specific id from the event 
     */
    getGenericEvents(selectedDay: string, id: string, idFunction: Function): Array<IEvent> {
        let ids: Array<string> = new Array();
        let events: Array<IEvent> = new Array();

        this.conference.events.forEach((event) => {
            let day = this.extractDay(event.start);
            if (day === selectedDay && id === idFunction(event) && ids.indexOf(event.id) < 0) {
                ids.push(event.id);
            }
        });

        let eventMap = this.getEventMap();

        ids.forEach((eventId) => events.push(eventMap.get(eventId)));

        return events.sort((leftSide, rightSide): number => {
            if (leftSide.start > rightSide.start) return 1;
            if (leftSide.start < rightSide.start) return -1;
            return 0;
        });
    }

    // TODO move into IEvent -> convert to class
    private extractDay(startString: string): string {
        return startString.substring(0, 10)
    }

    private extractTime(startString: string): string {
        return startString.substring(11);
    }

    getTrackMap(): Map<ITrack> {
        this.conference.metaData.tracks.forEach((track) => this.trackMap.add(track.id, track));
        return this.trackMap;
    }

    getAudienceMap(): Map<IAudience> {
        this.conference.metaData.audiences.forEach((audience) => this.audienceMap.add(audience.id, audience));
        return this.audienceMap;
    }

    getLocationMap(): Map<ILocation> {
        this.conference.metaData.locations.forEach((location) => this.locationMap.add(location.id, location));
        return this.locationMap;
    }

    getEventMap(): Map<IEvent> {
        this.conference.events.forEach((event) => this.eventMap.add(event.id, event));
        return this.eventMap;
    }

    // TODO wohl obsolet!! wird via canvas gemacht
    fetchSpeakerImage(callback: Function): void {
        let httpRequest: XMLHttpRequest = new XMLHttpRequest();

        // https://apachecon.dukecon.org/acna/2018/rest/image-resources.json
        // https://apachecon.dukecon.org/javaland/2018/rest/image-resources.json

        //  https://programm.javaland.eu/2018/rest/speaker/images/54b7e39e34aabbdf3c6a6e10e24c7821
        // 
        httpRequest.open('GET', 'https://programm.javaland.eu/2018/rest/speaker/images/54b7e39e34aabbdf3c6a6e10e24c7821');
        //        httpRequest.setRequestHeader('Content-Type', 'application/json;charset=utf-8');
        httpRequest.timeout = 5000; // 5 seconds timeout
        httpRequest.onreadystatechange = () => {
            if (httpRequest.readyState === XMLHttpRequest.DONE) {
                if (httpRequest.status == 200 && httpRequest.responseText != "undefined") {
                    let data = httpRequest.responseText;

                    console.log("return status : " + httpRequest.status);
                    console.log("loaded image data : " + data)
                    //                    console.log("loaded image data : " + btoa(data));

                    //                    this.conferenceData = conferenceData;

                    console.log("calling callback !");
                    callback(httpRequest.status, data); // TODO FIX callback
                    console.log("calling callback done!");

                } else {
                    console.log("data : " + httpRequest.response + " " + httpRequest.responseURL + " " + httpRequest.responseText);
                    callback(httpRequest.status, null);
                }
            }
        };
        httpRequest.onerror = (ev: Event) => {
            console.log("error code : " + httpRequest.status);
            console.log("event : " + ev.currentTarget);
        }
        httpRequest.send();
    }


}
