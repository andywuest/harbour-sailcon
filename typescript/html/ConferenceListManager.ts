class ConferenceListManager {
    private conferences: Array<IConferenceData> = new Array();

    public getConferences(): Array<IConferenceData> {
        return this.conferences;
    }

    public setConferences(conferences: Array<IConferenceData>) {
        this.conferences = conferences;
    }

    public fetchConferences(url: string, callback: Function): void {
        let httpRequest: XMLHttpRequest = new XMLHttpRequest();

        console.log("conference Url : " + url);

        httpRequest.open('GET', url);
        httpRequest.setRequestHeader('Content-Type', 'application/json;charset=utf-8');
        httpRequest.timeout = 5000; // 5 seconds timeout
        httpRequest.onreadystatechange = () => {
            if (httpRequest.readyState === XMLHttpRequest.DONE) {
                if (httpRequest.status == 200 && httpRequest.responseText != "undefined") {
                    let conferenceList = (<Array<IConferenceData>> JSON.parse(httpRequest.responseText));

                    console.log("return status : " + httpRequest.status);
                    console.log("loaded conferences : ")

                    let sortedConferenceList = conferenceList.sort((leftSide, rightSide): number => {
                        if (leftSide.startDate > rightSide.startDate) return -1;
                        if (leftSide.startDate < rightSide.startDate) return 1;
                        return 0;
                    });

                    this.setConferences(sortedConferenceList);
                    sortedConferenceList.forEach((conference) => console.log("conf(sorted) : " + conference.name + ", year " + conference.year));

                    console.log("calling callback !");
                    callback(httpRequest.status, sortedConferenceList);
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