class UrlService {

    private conferencesUrl: string;
    private single: boolean;

    constructor(conferencesUrl: string, single: boolean) {
        this.conferencesUrl = conferencesUrl;
        this.single = single;
    }

    getConferenceDataUrl(conferenceData: IConferenceData): string {
        // https://latest.dukecon.org/jfs/2017/rest/conferences/jfs2017
        // http://localhost:8083/rest/conferences/javaland2016
        let urlPrefix = this.getBasePath(conferenceData);
        if (this.single) {
            let url: string = urlPrefix + "/" + conferenceData.id;
            console.log("Conference data url is : " + url);
            return url;
        } else {
            let url: string = urlPrefix + "rest/conferences/" + conferenceData.id;
            console.log("Conference data url is : " + url);
            return url;
        }
    }

    getConferenceImagesUrl(conferenceData: IConferenceData): string {
        // https://latest.dukecon.org/javaland/2018/rest/image-resources.json
        // http://localhost:8083/rest/image-resources/javaland/2016/
        if (this.single) {
            let url: string = this.conferencesUrl.replace(new RegExp("/conferences", "g"), "")
            url += "/image-resources/" + conferenceData.id.replace(new RegExp("\\d", "g"), "") + "/" + conferenceData.year + "/";
            return url;
        } else {
            let url: string = this.getBasePath(conferenceData) + "rest/image-resources.json";
            console.log("Conference images url is : " + url);
            return url;
        }
    }

    getSpeakerImagesUrl(conferenceData: IConferenceData): string {
        // https://programm.javaland.eu/2019/rest/speaker/images/d15f234b7a5fe0b72b5a3e21d72a7445
        // http://localhost:8083/rest/speaker/images
        if (this.single) {
            let url: string = this.conferencesUrl.replace(new RegExp("/conferences", "g"), "")
            url += "/speaker/images/";
            return url;
        } else {
            let url: string = this.getBasePath(conferenceData) + "rest/speaker/images/";
            console.log("Speaker images base url is : " + url);
            return url;
        }
    }

    private getBasePath(conferenceData: IConferenceData): string {
        let url: string = this.conferencesUrl;
        if (!this.single) {
            url += conferenceData.id.replace(new RegExp("\\d", "g"), "") + "/";  // add id
            url += conferenceData.year + "/";
        }
        return url;
    }

}