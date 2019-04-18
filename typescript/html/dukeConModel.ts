interface IConferenceData {
    id: string;
    name: string;
    year: string;
    url: string;
    homeUrl: string;
    homeTitle: string;
    startDate: string;
    endDate: string;
}

interface IConference {
    id: string;
    name: string;
    url: string;
    homeUrl: string;
    metaData: IMetaData;
    events: IEvent[];
    speakers: ISpeaker[];
}

interface IMetaData {
    audiences: IAudience[];
    eventTypes: IEventType[];
    languages: ILanguage[];
    defaultLanguage: IDefaultLanguage;
    tracks: ITrack[];
    locations: ILocation[];
    defaultIcon: string;
    //    conferenceId: string;
}

interface IAudience {
    id: string;
    order: number;
    names: INames;
    icon: string;
}

interface INames {
    de: string;
    en: string;
}

interface IEventType {
    id: string;
    order: number;
    names: INames;
    icon: string;
}

interface ILanguage {
    id: string;
    order: number;
    names: INames;
    icon: string;
}

interface IDefaultLanguage {
    id: string;
    code: string;
    order: number;
    names: INames;
    icon: string;
}

interface IOrder {
    order: number;
}

// TODO rename 
class ITrack implements IOrder {
    id: string;
    order: number;
    names: INames;
    icon: string;
}

// TODO rename 
class ILocation implements IOrder {
    id: string;
    order: number;
    names: INames;
    icon: string;
    capacity: number;
}

interface IEvent {
    id: string;
    trackId: string;
    locationId: string;
    start: string;
    end: string;
    title: string;
    speakerIds: string[];
    languageId: string;
    demo: boolean;
    simultan: boolean;
    veryPopular: boolean;
    fullyBooked: boolean;
    numberOfFavorites: number;
    keywords: IKeywords;
    documents: IDocuments;
    audienceId: string;
    typeId: string;
    abstractText: string;
}

interface IKeywords {
    de: string[];
    en: string[];
}

interface IDocuments {
    slides: string;
    manuscript: any;
    other: string;
}

interface ISpeaker {
    id: string;
    name: string;
    firstname: string;
    lastname: string;
    company: string;
    website: string;
    twitter: string;
    xing: string;
    linkedin: string;
    bio: string;
    photoId: string;
    eventIds: string[];
    facebook: string;
}

class EventTalk implements IEvent {

    constructor(eventTalk: IEvent) {
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

    id: string;
    trackId: string;
    locationId: string;
    start: string;
    end: string;
    title: string;
    speakerIds: string[];
    languageId: string;
    demo: boolean;
    simultan: boolean;
    veryPopular: boolean;
    fullyBooked: boolean;
    numberOfFavorites: number;
    keywords: IKeywords;
    documents: IDocuments;
    audienceId: string;
    typeId: string;
    abstractText: string;

    isDocumentsPresent(): boolean {
        return (this.isDefined(this.documents) &&
            (this.isDefined(this.documents.slides)
                || this.isDefined(this.documents.manuscript)
                || this.isDefined(this.documents.other)));
    }

    private isDefined(value: any): boolean {
        return (value !== undefined && value !== null);
    }

}

class Speaker implements ISpeaker {

    constructor(speaker: ISpeaker) {
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

    id: string;
    name: string;
    firstname: string;
    lastname: string;
    company: string;
    website: string;
    twitter: string;
    xing: string;
    linkedin: string;
    bio: string;
    photoId: string;
    eventIds: string[];
    facebook: string;

    isWebLinkPresent(): boolean {
        return (this.isDefined(this.xing)
            || this.isDefined(this.website)
            || this.isDefined(this.twitter)
            || this.isDefined(this.linkedin)
            || this.isDefined(this.facebook));
    }

    private isDefined(value: string): boolean {
        return (value !== undefined && value !== null);
    }

}
