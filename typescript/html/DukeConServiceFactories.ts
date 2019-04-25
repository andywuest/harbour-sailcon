
function createConferenceData(data: IConferenceData) {
    let conferenceData = new ConferenceData(data);
    return conferenceData;
};

function createConferenceManager(data: IConference) {
    let manager = new ConferenceManager(data);
    return manager;
};

function createConferenceListManager() {
    return new ConferenceListManager();
};

function createUrlService(conferencesUrl: string, single: boolean) {
    return new UrlService(conferencesUrl, single);
};

function createDownloadService() {
    return new DownloadService();
}

function createDownloadData() {
    return new DownloadData();
}
