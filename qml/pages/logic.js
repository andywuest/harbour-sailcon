
function buildEntry(index) {

    var myElement = {
        title: "DukeCon Hacking Session" + index,
        startTime: "Montag, 07.03.2016 09:00 (40 min)",
        location: "Tagungsraum Dambali (Hotel Matamba)",
        category: "Community Aktivitäten"
    }

    return myElement;
}


function buildDateEntry(index, dateValue) {

    var myElement = {
        index : index,
        date : "" + dateValue
    }

    return myElement;

}

function buildTypeEntry(index, typeValue) {

    var myElement = {
        index : index,
        type : typeValue
    }

    return myElement;

}

function buildTrackEntry(index, trackValue) {

    var myElement = {
        index : index,
        track : trackValue
    }

    return myElement;

}

function buildTalkEntry(index, talkValue) {

    var myElement = {
        index: index,
        talk : talkValue
    }

    return myElement;

}

function buildTimeEntry(index, timeValue) {

    var myElement = {
        index: index,
        time : timeValue
    }

    return myElement;
}




function buildDateAndTimeEntry(index, dateValue, timeValue) {

    var myElement = {
        index : index,
        date : dateValue,
        time : timeValue
    }

    return myElement;

}

var types = [
        {
                id: 1,
                type: "Location"
            },
            {
                id: 2,
                type: "Audience"
            },
            {
                id: 3,
                type: "Track"
            },
            {
                id: 4,
                type: "Time"
            }

        ];


var rating = [ 'Bad', 'Medium', 'Good', 'Very Good', 'Excellent' ];
