class UrlService {

    getConferenceDataUrl(conferencesUrl: string, conferenceData: IConferenceData, single: boolean): string {
        // https://latest.dukecon.org/jfs/2017/rest/conferences/jfs2017
        // http://localhost:8083/rest/conferences/javaland2016
        let urlPrefix = this.getBasePath(conferencesUrl, conferenceData, single);
        if (single) {
            let url: string = urlPrefix + "/" + conferenceData.id;
            console.log("Conference data url is : " + url);
            return url;
        } else {
            let url: string = urlPrefix + "rest/conferences/" + conferenceData.id;
            console.log("Conference data url is : " + url);
            return url;
        }
    }

    getConferenceImagesUrl(conferencesUrl: string, conferenceData: IConferenceData, single: boolean): string {
        // https://latest.dukecon.org/javaland/2018/rest/image-resources.json
        let url: string = this.getBasePath(conferencesUrl, conferenceData, single) + "rest/image-resources.json";
        console.log("Conference images url is : " + url);
        return url;
    }

    getSpeakerImagesUrl(conferencesUrl: string, conferenceData: IConferenceData, single: boolean): string {
        // https://programm.javaland.eu/2019/rest/speaker/images/d15f234b7a5fe0b72b5a3e21d72a7445
        let url: string = this.getBasePath(conferencesUrl, conferenceData, single) + "rest/speaker/images/";
        console.log("Speaker images base url is : " + url);
        return url;
    }

    private getBasePath(conferencesUrl: string, conferenceData: IConferenceData, single: boolean): string {
        let url: string = conferencesUrl;
        if (!single) {
            url += conferenceData.id.replace(new RegExp("\\d", "g"), "") + "/";  // add id
            url += conferenceData.year + "/";
        }
        return url;
    }

}