
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

function createUrlService() {
    return new UrlService();
};

function createDownloadService() {
    return new DownloadService();
}

function createDownloadData() {
    return new DownloadData();
}
