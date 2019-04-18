class ConferenceData implements IConferenceData {
    id: string;
    name: string;
    year: string;
    url: string;
    homeUrl: string;
    homeTitle: string;
    startDate: string;
    endDate: string;
    conferenceUrl: string;  // the calculated url that returns the conference data as json
    conferenceData: string; // the json string of all the conference data

    constructor(data: IConferenceData) {
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
    private determineConferenceDataURL(): string {
        // https://latest.dukecon.org/jfs/2017/rest/conferences/jfs2017
        let url: string = "https://latest.dukecon.org/";
        url += this.id.replace(new RegExp("\\d", "g"), "") + "/";  // add id
        url += this.year + "/";
        url += "rest/conferences/" + this.id;

        console.log("Conference data url is : " + url);

        return url;
    }

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

    private fetchConferenceData(callback: Function): void {
        let httpRequest: XMLHttpRequest = new XMLHttpRequest();

        httpRequest.open('GET', this.determineConferenceDataURL());
        httpRequest.setRequestHeader('Content-Type', 'application/json;charset=utf-8');
        httpRequest.timeout = 5000; // 5 seconds timeout
        httpRequest.onreadystatechange = () => {
            if (httpRequest.readyState == XMLHttpRequest.DONE) {
                if (httpRequest.status == 200 && httpRequest.responseText != "undefined") {
                    let conferenceData = httpRequest.responseText;

                    console.log("return status : " + httpRequest.status);
                    console.log("loaded conference data : " + conferenceData)

                    this.conferenceData = conferenceData;

                    console.log("calling callback !");
                    callback(httpRequest.status, this.conferenceData);
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

    public getConferenceManager(): ConferenceManager {
        //    this.fetchConferenceDataPromiseAsync();
        let manager: ConferenceManager;
        this.fetchConferenceData((statusCode: number, conferenceData: string) => {
            console.log("status code was : " + statusCode)
            if (conferenceData !== null) {
                manager = new ConferenceManager(<IConference> JSON.parse(conferenceData));
            }
        });

        return manager;
    }

}
