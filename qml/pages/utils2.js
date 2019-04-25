"use strict";
// TODO rename 
var ITrack = /** @class */ (function () {
    function ITrack() {
    }
    return ITrack;
}());
// TODO rename 
var ILocation = /** @class */ (function () {
    function ILocation() {
    }
    return ILocation;
}());
var EventTalk = /** @class */ (function () {
    function EventTalk(eventTalk) {
        this.id = eventTalk.id;
        this.trackId = eventTalk.trackId;
        this.locationId = eventTalk.locationId;
        this.start = eventTalk.start;
        this.end = eventTalk.end;
        this.title = eventTalk.title;
        this.speakerIds = eventTalk.speakerIds;
        this.languageId = eventTalk.languageId;
        this.demo = eventTalk.demo;
        this.simultan = eventTalk.simultan;
        this.veryPopular = eventTalk.veryPopular;
        this.fullyBooked = eventTalk.fullyBooked;
        this.numberOfFavorites = eventTalk.numberOfFavorites;
        this.keywords = eventTalk.keywords;
        this.documents = eventTalk.documents;
        this.audienceId = eventTalk.audienceId;
        this.typeId = eventTalk.typeId;
        this.abstractText = eventTalk.abstractText;
    }
    EventTalk.prototype.isDocumentsPresent = function () {
        return (this.isDefined(this.documents) &&
            (this.isDefined(this.documents.slides)
                || this.isDefined(this.documents.manuscript)
                || this.isDefined(this.documents.other)));
    };
    EventTalk.prototype.isDefined = function (value) {
        return (value !== undefined && value !== null);
    };
    return EventTalk;
}());
var Speaker = /** @class */ (function () {
    function Speaker(speaker) {
        this.id = speaker.id;
        this.name = speaker.name;
        this.firstname = speaker.firstname;
        this.lastname = speaker.lastname;
        this.company = speaker.company;
        this.website = speaker.website;
        this.twitter = speaker.twitter;
        this.xing = speaker.xing;
        this.linkedin = speaker.linkedin;
        this.bio = speaker.bio;
        this.photoId = speaker.photoId;
        this.eventIds = speaker.eventIds;
        this.facebook = speaker.facebook;
    }
    Speaker.prototype.isWebLinkPresent = function () {
        return (this.isDefined(this.xing)
            || this.isDefined(this.website)
            || this.isDefined(this.twitter)
            || this.isDefined(this.linkedin)
            || this.isDefined(this.facebook));
    };
    Speaker.prototype.isDefined = function (value) {
        return (value !== undefined && value !== null);
    };
    return Speaker;
}());
var SelectBoxModelItem = /** @class */ (function () {
    function SelectBoxModelItem(index, internalId, label) {
        this.index = index;
        this.internalId = internalId;
        this.label = label;
    }
    SelectBoxModelItem.prototype.getIndex = function () {
        return this.index;
    };
    SelectBoxModelItem.prototype.getLabel = function () {
        return this.label;
    };
    SelectBoxModelItem.prototype.getInternalId = function () {
        return this.internalId;
    };
    return SelectBoxModelItem;
}());
var Map = /** @class */ (function () {
    function Map() {
        this.items = {};
    }
    Map.prototype.add = function (key, value) {
        this.items[key] = value;
    };
    Map.prototype.has = function (key) {
        return key in this.items;
    };
    Map.prototype.get = function (key) {
        return this.items[key];
    };
    return Map;
}());
var ConferenceData = /** @class */ (function () {
    function ConferenceData(data) {
        this.id = data.id;
        this.name = data.name;
        this.year = data.year;
        this.url = data.url;
        this.homeUrl = data.homeUrl;
        this.homeTitle = data.homeTitle;
        this.startDate = data.startDate;
        this.endDate = data.endDate;
    }
    // deprecated
    ConferenceData.prototype.determineConferenceDataURL = function () {
        // https://latest.dukecon.org/jfs/2017/rest/conferences/jfs2017
        var url = "https://latest.dukecon.org/";
        url += this.id.replace(new RegExp("\\d", "g"), "") + "/"; // add id
        url += this.year + "/";
        url += "rest/conferences/" + this.id;
        console.log("Conference data url is : " + url);
        return url;
    };
    /*
        private fetchConferenceDataPromise(): string {
            return new HttpRequest().get({url: 'https://latest.dukecon.org/jfs/2017/rest/conferences/jfs2017', timeout: 5000})
                .then(res => {
                    console.log("aaaaaaaaaaaaaaaaaaa conference data response : " + res.string)
                    return res.string;
                })
                .catch(error => {
                    console.log("bbbbbbbbbbbbbbbbbb error : " + error);
                });
        }
        */
    /*
        public async fetchConferenceDataPromiseAsync() {
            let response = await this.fetchConferenceDataPromise();
            console.log("response was !" + response);
        }
        */
    ConferenceData.prototype.fetchConferenceData = function (callback) {
        var _this = this;
        var httpRequest = new XMLHttpRequest();
        httpRequest.open('GET', this.determineConferenceDataURL());
        httpRequest.setRequestHeader('Content-Type', 'application/json;charset=utf-8');
        httpRequest.timeout = 5000; // 5 seconds timeout
        httpRequest.onreadystatechange = function () {
            if (httpRequest.readyState == XMLHttpRequest.DONE) {
                if (httpRequest.status == 200 && httpRequest.responseText != "undefined") {
                    var conferenceData = httpRequest.responseText;
                    console.log("return status : " + httpRequest.status);
                    console.log("loaded conference data : " + conferenceData);
                    _this.conferenceData = conferenceData;
                    console.log("calling callback !");
                    callback(httpRequest.status, _this.conferenceData);
                    console.log("calling callback done!");
                }
                else {
                    console.log("data : " + httpRequest.response + " " + httpRequest.responseURL + " " + httpRequest.responseText);
                    callback(httpRequest.status, null);
                }
            }
        };
        httpRequest.onerror = function (ev) {
            console.log("error code : " + httpRequest.status);
            console.log("event : " + ev.currentTarget);
        };
        httpRequest.send();
    };
    ConferenceData.prototype.getConferenceManager = function () {
        //    this.fetchConferenceDataPromiseAsync();
        var manager;
        this.fetchConferenceData(function (statusCode, conferenceData) {
            console.log("status code was : " + statusCode);
            if (conferenceData !== null) {
                manager = new ConferenceManager(JSON.parse(conferenceData));
            }
        });
        return manager;
    };
    return ConferenceData;
}());
var ConferenceListManager = /** @class */ (function () {
    function ConferenceListManager() {
        this.conferences = new Array();
    }
    ConferenceListManager.prototype.getConferences = function () {
        return this.conferences;
    };
    ConferenceListManager.prototype.setConferences = function (conferences) {
        this.conferences = conferences;
    };
    ConferenceListManager.prototype.fetchConferences = function (url, callback) {
        var _this = this;
        var httpRequest = new XMLHttpRequest();
        console.log("conference Url : " + url);
        httpRequest.open('GET', url);
        httpRequest.setRequestHeader('Content-Type', 'application/json;charset=utf-8');
        httpRequest.timeout = 5000; // 5 seconds timeout
        httpRequest.onreadystatechange = function () {
            if (httpRequest.readyState === XMLHttpRequest.DONE) {
                if (httpRequest.status == 200 && httpRequest.responseText != "undefined") {
                    var conferenceList = JSON.parse(httpRequest.responseText);
                    console.log("return status : " + httpRequest.status);
                    console.log("loaded conferences : ");
                    var sortedConferenceList = conferenceList.sort(function (leftSide, rightSide) {
                        if (leftSide.startDate > rightSide.startDate)
                            return -1;
                        if (leftSide.startDate < rightSide.startDate)
                            return 1;
                        return 0;
                    });
                    _this.setConferences(sortedConferenceList);
                    sortedConferenceList.forEach(function (conference) { return console.log("conf(sorted) : " + conference.name + ", year " + conference.year); });
                    console.log("calling callback !");
                    callback(httpRequest.status, sortedConferenceList);
                    console.log("calling callback done!");
                }
                else {
                    console.log("data : " + httpRequest.response + " " + httpRequest.responseURL + " " + httpRequest.responseText);
                    callback(httpRequest.status, null);
                }
            }
        };
        httpRequest.onerror = function (ev) {
            console.log("error code : " + httpRequest.status);
            console.log("event : " + ev.currentTarget);
        };
        httpRequest.send();
    };
    return ConferenceListManager;
}());
var ConferenceManager = /** @class */ (function () {
    function ConferenceManager(conference) {
        this.sortByOrder = function (leftSide, rightSide) {
            if (leftSide.order < rightSide.order)
                return -1;
            if (leftSide.order > rightSide.order)
                return 1;
            return 0;
        };
        this.conference = conference;
        this.trackMap = new Map();
        this.audienceMap = new Map();
        this.locationMap = new Map();
        this.eventMap = new Map();
    }
    ConferenceManager.prototype.getName = function () {
        return this.conference.name;
    };
    ConferenceManager.prototype.convertToDate = function (dateString) {
        if (dateString !== null && dateString.length > 0) {
            return new Date(Date.parse(dateString));
        }
        return null;
    };
    ConferenceManager.prototype.trimToEmpty = function (value) {
        if (value === null || value === undefined) {
            return "";
        }
        return value;
    };
    ConferenceManager.prototype.getEventsForTrack = function (selectedDay, id) {
        return this.getGenericEvents(selectedDay, id, trackIdFunction);
    };
    ConferenceManager.prototype.getEventsForAudience = function (selectedDay, id) {
        return this.getGenericEvents(selectedDay, id, audienceIdFunction);
    };
    ConferenceManager.prototype.getEventsForLocation = function (selectedDay, id) {
        return this.getGenericEvents(selectedDay, id, locationIdFunction);
    };
    ConferenceManager.prototype.getEventsForTime = function (selectedDay, startTime) {
        var events = this.conference.events.filter(function (event) { return event.start === startTime; });
        // TODO sorting - selectedDay ist implizit schon in startTime
        return events;
    };
    ConferenceManager.prototype.getLocationsForEventDayAsSelectBoxModelItems = function (selectedDay) {
        var result = new Array();
        var data;
        data = this.getLocationsForEventDay(selectedDay);
        data.forEach(function (location, index) { return result.push(new SelectBoxModelItem(index, location.id, location.names.de)); });
        return result;
    };
    ConferenceManager.prototype.getTracksForEventDayAsSelectBoxModelItems = function (selectedDay) {
        var result = new Array();
        var data;
        data = this.getTracksForEventDay(selectedDay);
        data.forEach(function (track, index) { return result.push(new SelectBoxModelItem(index, track.id, track.names.de)); });
        return result;
    };
    ConferenceManager.prototype.getAudiencesForEventDayAsSelectBoxModelItems = function (selectedDay) {
        var result = new Array();
        var data;
        data = this.getAudiencesForEventDay(selectedDay);
        data.forEach(function (audience, index) { return result.push(new SelectBoxModelItem(index, audience.id, audience.names.de)); });
        return result;
    };
    ConferenceManager.prototype.getStartTimesForEventDayAsSelectBoxModelItems = function (selectedDay) {
        var _this = this;
        var result = new Array();
        var data;
        data = this.getStartTimesForEventDay(selectedDay);
        console.log("numb. of audiences found : " + data.length);
        data.forEach(function (day, index) { return result.push(new SelectBoxModelItem(index, day, _this.extractTime(day) + " Uhr")); });
        console.log("numb. of result audiences : " + result.length);
        return result;
    };
    ConferenceManager.prototype.getStartTimesForEventDay = function (selectedDay) {
        var _this = this;
        var startTimes = new Array();
        this.conference.events.forEach(function (event) {
            var day = _this.extractDay(event.start);
            var startDayTime = event.start;
            if (day === selectedDay && startTimes.indexOf(startDayTime) < 0) {
                startTimes.push(startDayTime);
            }
        });
        return startTimes.sort();
    };
    ConferenceManager.prototype.getDaysOfConference = function () {
        var _this = this;
        var days = new Array();
        this.conference.events.forEach(function (event) {
            var day = _this.extractDay(event.start);
            if (days.indexOf(day) < 0) {
                days.push(day);
            }
        });
        return days.sort();
    };
    ConferenceManager.prototype.isSingleDayConference = function () {
        return (this.getDaysOfConference().length == 1);
    };
    ConferenceManager.prototype.getAudiencesForEventDay = function (selectedDay) {
        var _this = this;
        var audienceIds = new Array();
        var audiences = new Array();
        this.conference.events
            .filter(function (event) { return event.audienceId !== undefined; }) // only events that have a audience id
            .forEach(function (event) {
            var day = _this.extractDay(event.start);
            if (day === selectedDay && audienceIds.indexOf(event.audienceId) < 0) {
                audienceIds.push(event.audienceId);
            }
        });
        var audienceMap = this.getAudienceMap();
        audienceIds.forEach(function (audienceId) { return audiences.push(audienceMap.get(audienceId)); });
        return audiences.sort(this.sortByOrder);
    };
    ConferenceManager.prototype.getTracksForEventDay = function (selectedDay) {
        var _this = this;
        var trackIds = new Array();
        var tracks = new Array();
        this.conference.events
            .filter(function (event) { return event.trackId !== undefined; }) // only events that have a track id
            .forEach(function (event) {
            var day = _this.extractDay(event.start);
            if (day === selectedDay && trackIds.indexOf(event.trackId) < 0) {
                trackIds.push(event.trackId);
            }
        });
        var trackMap = this.getTrackMap();
        trackIds.forEach(function (trackId) { return tracks.push(trackMap.get(trackId)); });
        return tracks.sort(this.sortByOrder);
    };
    ConferenceManager.prototype.getLocationsForEventDay = function (selectedDay) {
        var _this = this;
        var locationIds = new Array();
        var locations = new Array();
        this.conference.events.forEach(function (event) {
            var day = _this.extractDay(event.start);
            if (day === selectedDay && locationIds.indexOf(event.locationId) < 0) {
                locationIds.push(event.locationId);
            }
        });
        var locationMap = this.getLocationMap();
        locationIds.forEach(function (locationId) { return locations.push(locationMap.get(locationId)); });
        return locations.sort(this.sortByOrder);
    };
    ConferenceManager.prototype.getEventsForDayAndLocation = function (selectedDay, locationId) {
        var _this = this;
        var eventIds = new Array();
        var events = new Array();
        this.conference.events.forEach(function (event) {
            var day = _this.extractDay(event.start);
            if (day === selectedDay && locationId === event.locationId && eventIds.indexOf(event.id) < 0) {
                eventIds.push(event.id);
            }
        });
        var eventMap = this.getEventMap();
        eventIds.forEach(function (eventId) { return events.push(eventMap.get(eventId)); });
        return events.sort(function (leftSide, rightSide) {
            if (leftSide.start > rightSide.start)
                return 1;
            if (leftSide.start < rightSide.start)
                return -1;
            return 0;
        });
    };
    ConferenceManager.prototype.getSpeakerByIds = function (ids) {
        var speakers = this.conference.speakers.filter(function (speaker) {
            return (ids.indexOf(speaker.id) > -1);
        }).map(function (sp) { return new Speaker(sp); });
        return speakers;
    };
    ConferenceManager.prototype.getSpeakerPhotoIdUrls = function (baseUrl) {
        var speakerPhotoIds = this.conference.speakers
            .filter(function (speaker) { return speaker.photoId !== undefined; })
            .filter(function (speaker) { return speaker.photoId !== null; })
            .filter(function (speaker) { return speaker.photoId !== ""; })
            .map(function (speaker) { return baseUrl + speaker.photoId; })
            .filter(function (elem, index, self) {
            return index === self.indexOf(elem);
        });
        return speakerPhotoIds;
    };
    ConferenceManager.prototype.getEventById = function (eventId) {
        var event = this.conference.events.filter(function (event) { return event.id === eventId; })[0];
        return new EventTalk(event);
    };
    ConferenceManager.prototype.getSpeakersForEvent = function (eventId) {
        var event = this.getEventById(eventId);
        return this.getSpeakerByIds(event.speakerIds);
    };
    // TODO consolidate language specfici access
    ConferenceManager.prototype.getLocationName = function (locationId, language) {
        var names = this.getLocationMap().get(locationId).names;
        if ("de" === language) {
            return names.de;
        }
        else {
            return names.en;
        }
    };
    ConferenceManager.prototype.getAudienceName = function (audienceId, language) {
        var names = this.getAudienceMap().get(audienceId).names;
        if ("de" === language) {
            return names.de;
        }
        else {
            return names.en;
        }
    };
    ConferenceManager.prototype.getTrackName = function (trackId, language) {
        var names = this.getTrackMap().get(trackId).names;
        if ("de" === language) {
            return names.de;
        }
        else {
            return names.en;
        }
    };
    /**
     * id : the id that the function has to match to select the event
     * idFunction : is a function definition that resturs the specific id from the event
     */
    ConferenceManager.prototype.getGenericEvents = function (selectedDay, id, idFunction) {
        var _this = this;
        var ids = new Array();
        var events = new Array();
        this.conference.events.forEach(function (event) {
            var day = _this.extractDay(event.start);
            if (day === selectedDay && id === idFunction(event) && ids.indexOf(event.id) < 0) {
                ids.push(event.id);
            }
        });
        var eventMap = this.getEventMap();
        ids.forEach(function (eventId) { return events.push(eventMap.get(eventId)); });
        return events.sort(function (leftSide, rightSide) {
            if (leftSide.start > rightSide.start)
                return 1;
            if (leftSide.start < rightSide.start)
                return -1;
            return 0;
        });
    };
    // TODO move into IEvent -> convert to class
    ConferenceManager.prototype.extractDay = function (startString) {
        return startString.substring(0, 10);
    };
    ConferenceManager.prototype.extractTime = function (startString) {
        return startString.substring(11);
    };
    ConferenceManager.prototype.getTrackMap = function () {
        var _this = this;
        this.conference.metaData.tracks.forEach(function (track) { return _this.trackMap.add(track.id, track); });
        return this.trackMap;
    };
    ConferenceManager.prototype.getAudienceMap = function () {
        var _this = this;
        this.conference.metaData.audiences.forEach(function (audience) { return _this.audienceMap.add(audience.id, audience); });
        return this.audienceMap;
    };
    ConferenceManager.prototype.getLocationMap = function () {
        var _this = this;
        this.conference.metaData.locations.forEach(function (location) { return _this.locationMap.add(location.id, location); });
        return this.locationMap;
    };
    ConferenceManager.prototype.getEventMap = function () {
        var _this = this;
        this.conference.events.forEach(function (event) { return _this.eventMap.add(event.id, event); });
        return this.eventMap;
    };
    // TODO wohl obsolet!! wird via canvas gemacht
    ConferenceManager.prototype.fetchSpeakerImage = function (callback) {
        var httpRequest = new XMLHttpRequest();
        // https://apachecon.dukecon.org/acna/2018/rest/image-resources.json
        // https://apachecon.dukecon.org/javaland/2018/rest/image-resources.json
        //  https://programm.javaland.eu/2018/rest/speaker/images/54b7e39e34aabbdf3c6a6e10e24c7821
        // 
        httpRequest.open('GET', 'https://programm.javaland.eu/2018/rest/speaker/images/54b7e39e34aabbdf3c6a6e10e24c7821');
        //        httpRequest.setRequestHeader('Content-Type', 'application/json;charset=utf-8');
        httpRequest.timeout = 5000; // 5 seconds timeout
        httpRequest.onreadystatechange = function () {
            if (httpRequest.readyState === XMLHttpRequest.DONE) {
                if (httpRequest.status == 200 && httpRequest.responseText != "undefined") {
                    var data = httpRequest.responseText;
                    console.log("return status : " + httpRequest.status);
                    console.log("loaded image data : " + data);
                    //                    console.log("loaded image data : " + btoa(data));
                    //                    this.conferenceData = conferenceData;
                    console.log("calling callback !");
                    callback(httpRequest.status, data); // TODO FIX callback
                    console.log("calling callback done!");
                }
                else {
                    console.log("data : " + httpRequest.response + " " + httpRequest.responseURL + " " + httpRequest.responseText);
                    callback(httpRequest.status, null);
                }
            }
        };
        httpRequest.onerror = function (ev) {
            console.log("error code : " + httpRequest.status);
            console.log("event : " + ev.currentTarget);
        };
        httpRequest.send();
    };
    return ConferenceManager;
}());
function createConferenceData(data) {
    var conferenceData = new ConferenceData(data);
    return conferenceData;
}
;
function createConferenceManager(data) {
    var manager = new ConferenceManager(data);
    return manager;
}
;
function createConferenceListManager() {
    return new ConferenceListManager();
}
;
function createUrlService(conferencesUrl, single) {
    return new UrlService(conferencesUrl, single);
}
;
function createDownloadService() {
    return new DownloadService();
}
function createDownloadData() {
    return new DownloadData();
}
var UrlService = /** @class */ (function () {
    function UrlService(conferencesUrl, single) {
        this.conferencesUrl = conferencesUrl;
        this.single = single;
    }
    UrlService.prototype.getConferenceDataUrl = function (conferenceData) {
        // https://latest.dukecon.org/jfs/2017/rest/conferences/jfs2017
        // http://localhost:8083/rest/conferences/javaland2016
        var urlPrefix = this.getBasePath(conferenceData);
        if (this.single) {
            var url = urlPrefix + "/" + conferenceData.id;
            console.log("Conference data url is : " + url);
            return url;
        }
        else {
            var url = urlPrefix + "rest/conferences/" + conferenceData.id;
            console.log("Conference data url is : " + url);
            return url;
        }
    };
    UrlService.prototype.getConferenceImagesUrl = function (conferenceData) {
        // https://latest.dukecon.org/javaland/2018/rest/image-resources.json
        // http://localhost:8083/rest/image-resources/javaland/2016/
        if (this.single) {
            var url = this.conferencesUrl.replace(new RegExp("/conferences", "g"), "");
            url += "/image-resources/" + conferenceData.id + "/" + conferenceData.year + "/";
            return url;
        }
        else {
            var url = this.getBasePath(conferenceData) + "rest/image-resources.json";
            console.log("Conference images url is : " + url);
            return url;
        }
    };
    UrlService.prototype.getSpeakerImagesUrl = function (conferenceData) {
        // https://programm.javaland.eu/2019/rest/speaker/images/d15f234b7a5fe0b72b5a3e21d72a7445
        // http://localhost:8083/rest/speaker/images
        if (this.single) {
            var url = this.conferencesUrl.replace(new RegExp("/conferences", "g"), "");
            url += "/speaker/images/";
            return url;
        }
        else {
            var url = this.getBasePath(conferenceData) + "rest/speaker/images/";
            console.log("Speaker images base url is : " + url);
            return url;
        }
    };
    UrlService.prototype.getBasePath = function (conferenceData) {
        var url = this.conferencesUrl;
        if (!this.single) {
            url += conferenceData.id.replace(new RegExp("\\d", "g"), "") + "/"; // add id
            url += conferenceData.year + "/";
        }
        return url;
    };
    return UrlService;
}());
/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
var DownloadData = /** @class */ (function () {
    function DownloadData() {
        this.contentType = "application/json;charset=utf-8"; // by default json
        this.timeout = 5000; // 5 seconds timeout
    }
    return DownloadData;
}());
/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
var DownloadService = /** @class */ (function () {
    function DownloadService() {
    }
    DownloadService.prototype.execute = function (data, callback) {
        var httpRequest = new XMLHttpRequest();
        console.log("trying to fetch data from : " + data.url);
        httpRequest.open('GET', data.url);
        httpRequest.setRequestHeader('Content-Type', data.contentType);
        if (data.eTag) {
            httpRequest.setRequestHeader('If-None-Match', data.eTag);
        }
        httpRequest.timeout = data.timeout;
        httpRequest.onreadystatechange = function () {
            if (httpRequest.readyState === XMLHttpRequest.DONE) {
                if (httpRequest.status && httpRequest.status == 200 && httpRequest.responseText != "undefined") {
                    console.log("return status : " + httpRequest.status);
                    console.log("Resposne Headers : " + httpRequest.getAllResponseHeaders());
                    console.log("Resposne ETag : " + httpRequest.getResponseHeader("ETag"));
                    console.log("return responseText : " + httpRequest.responseText.substring(0, 200));
                    console.log("executing success callback !");
                    callback(0, httpRequest);
                    console.log("executing success done !");
                }
                else if (httpRequest.status && httpRequest.status === 304) {
                    callback(1, httpRequest);
                }
                else {
                    console.log("executing failure callback - data : " + httpRequest.response + " " + httpRequest.responseURL + " " + httpRequest.responseText);
                    callback(2, httpRequest);
                }
            }
        };
        httpRequest.onerror = function (ev) {
            console.log("error code : " + httpRequest.status);
            console.log("event : " + ev.currentTarget);
        };
        try {
            httpRequest.send();
        }
        catch (error) {
            callback(3, error);
        }
    };
    //  var url = currentPhotoId;
    //        var xhr = new XMLHttpRequest();
    //        xhr.open('GET', url, true);
    //        xhr.responseType = 'arraybuffer';
    //        xhr.onreadystatechange = function() {
    //            if (xhr.readyState === XMLHttpRequest.DONE) {
    //                if (xhr.status === 200) {
    //                    var response = new Uint8Array(xhr.response);
    //                    var raw = "";
    //                    for (var i = 0; i < response.byteLength; i++) {
    //                        raw += String.fromCharCode(response[i]);
    //                    }
    //
    //                    console.log("image fetched !");
    //
    //                    var image = 'data:image/png;base64,' +Constants.base64Encode(raw);
    //                            //
    //                    img.source = image;
    //                    fetchImages(photoIdUrls);
    //                }
    //            }
    //        }
    //        xhr.send();
    DownloadService.prototype.executeBinary = function (data, callback) {
        var httpRequest = new XMLHttpRequest();
        console.log("trying to fetch data from : " + data.url);
        httpRequest.open('GET', data.url);
        httpRequest.responseType = 'arraybuffer';
        // httpRequest.setRequestHeader('Content-Type', data.contentType);
        if (data.eTag) {
            httpRequest.setRequestHeader('If-None-Match', data.eTag);
        }
        httpRequest.timeout = data.timeout;
        httpRequest.onreadystatechange = function () {
            if (httpRequest.readyState === XMLHttpRequest.DONE) {
                if (httpRequest.status && httpRequest.status == 200 && httpRequest.responseText != "undefined") {
                    console.log("return status : " + httpRequest.status);
                    console.log("Resposne Headers : " + httpRequest.getAllResponseHeaders());
                    console.log("Resposne ETag : " + httpRequest.getResponseHeader("ETag"));
                    console.log("return responseText : " + httpRequest.responseText.substring(0, 200));
                    console.log("executing success callback !");
                    var response = new Uint8Array(httpRequest.response);
                    var raw = "";
                    for (var i = 0; i < response.byteLength; i++) {
                        raw += String.fromCharCode(response[i]);
                    }
                    callback(0, httpRequest, raw);
                    console.log("executing success done !");
                }
                else if (httpRequest.status && httpRequest.status === 304) {
                    callback(1, httpRequest);
                }
                else {
                    console.log("executing failure callback - data : " + httpRequest.response + " " + httpRequest.responseURL + " " + httpRequest.responseText);
                    callback(2, httpRequest);
                }
            }
        };
        httpRequest.onerror = function (ev) {
            console.log("error code : " + httpRequest.status);
            console.log("event : " + ev.currentTarget);
        };
        try {
            httpRequest.send();
        }
        catch (error) {
            callback(3, error);
        }
    };
    return DownloadService;
}());
// function that provides locationId for the event
var locationIdFunction = function (event) { return event.locationId; };
var audienceIdFunction = function (event) { return event.audienceId; };
var trackIdFunction = function (event) { return event.trackId; };
/// <reference path="dukeConModel" />
/// <reference path="SelectBoxModelItem" />
/// <reference path="Map" />
/// <reference path="ConferenceData" />
/// <reference path="ConferenceListManager" />
/// <reference path="ConferenceManager" />
/// <reference path="DukeConServiceFactories" />
/// <reference path="UrlService" />
/// <reference path="DownloadData" />
/// <reference path="DownloadService" />
/// <reference path="Functions" />
// aggregation of all the modules needed for the server!
