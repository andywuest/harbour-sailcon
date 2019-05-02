// .pragma library

Qt.include("constants.js")

function getOpenDatabase() {
    var db = LocalStorage.openDatabaseSync(
                "DukeConApp", "1.0",
                "Database for the DukeConApp Conference data!", 10000000)
    return db
}

// drops all application tables
function resetApplication() {
    try {
        var db = getOpenDatabase()
        console.log("Dropping all tables of the application!")
        db.transaction(function (tx) {
            tx.executeSql('DROP TABLE IF EXISTS conference')
            tx.executeSql('DROP TABLE IF EXISTS talk')
            tx.executeSql('DROP TABLE IF EXISTS conference_resources')
        })
    } catch (err) {
        console.log("Error deleting tables for application in database : " + err)
    }
}

// initializes all application tables
function initApplicationTables() {
    try {
        var db = getOpenDatabase()
        console.log("Creating all tables of the application if they do not yet exist!")
        db.transaction(function (tx) {
            tx.executeSql(
                        'CREATE TABLE IF NOT EXISTS conference'
                        + ' (id text, name text, year text, url text, homeUrl text, startDate text, endDate text, state integer, content text, etag text, PRIMARY KEY(id))')
            tx.executeSql(
                        'CREATE TABLE IF NOT EXISTS talk'
                        + ' (talkId INTEGER NOT NULL, favorite BOOLEAN NOT NULL DEFAULT false, rated BOOLEAN NOT NULL DEFAULT false, rating INTEGER)')
            tx.executeSql(
                        'CREATE TABLE IF NOT EXISTS conference_resources'
                        + ' (conferenceId text, resourceId text, resourceType text, etag text, content text, PRIMARY KEY (conferenceId, resourceId))')
        })
    } catch (err) {
        console.log("Error creating tables for application in database : " + err)
    }
}

function getPersistedConferenceIds() {
    var result = []
    try {
        var db = getOpenDatabase()
        db.transaction(function (tx) {
            var results = tx.executeSql('SELECT id FROM conference')
            for (var i = 0; i < results.rows.length; i++) {
                result.push(results.rows.item(i).id)
            }
        })
    } catch (err) {
        console.log("Error creating row in database: " + err)
    }
    console.log("Persisted conference ids : " + result)
    return result
}

// provides the tag for the given conferenceId, if available
function getETagForConferenceId(conferenceId) {
    var eTag = null
    try {
        var db = getOpenDatabase()
        db.transaction(function (tx) {
            var results = tx.executeSql(
                        'SELECT id,etag FROM conference where id = ?',
                        [conferenceId])
            if (results.rows.length === 1) {
                var resultRow = results.rows.item(0)
                eTag = resultRow.etag
                console.log('Found one conference ' + resultRow.id + ' with etag : ' + eTag)
            } else {
                console.log("nothing found for " + data.id)
            }
        })
    } catch (err) {
        console.log("Error getting etag for conference id: " + err)
    }
    return eTag
}

// persists the conference data - either insert or update
function persistConferenceData(data, newContent, eTag) {
    var result = ""
    try {
        var db = getOpenDatabase()
        console.log("trying to insert row for " + data.id + ", " + data.name)

        var numberOfPersistedConferences = 0;

        db.transaction(function (tx) {
            var results = tx.executeSql('SELECT COUNT(*) as count FROM conference');
            numberOfPersistedConferences = results.rows.item(0).count;
        })

        console.log("number of persisted conferences : " + numberOfPersistedConferences)

        db.transaction(function (tx) {
            // mark the first conference directly as active
            var initialState = (numberOfPersistedConferences === 0 ? CONFERENCE_ACTIVE : CONFERENCE_INACTIVE);
            tx.executeSql(
                        'INSERT OR REPLACE INTO conference(id, name, year, url, homeUrl, startDate, endDate, state, content, etag) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
                        [data.id, data.name, data.year, data.url, data.homeUrl, data.startDate, data.endDate, initialState, newContent, eTag])
        })
        result = qsTr("Conference data stored.")
    } catch (err) {
        result = qsTr("Failed to store conference data.")
        console.log(result + err)
    }
    return result
}

function deleteConferenceFromDatabase(conferenceId) {
    try {
        var db = Database.getOpenDatabase()
        db.transaction(function (tx) {
            var result = tx.executeSql(
                        'DELETE FROM conference WHERE id = ?',
                        [conferenceId])
            console.log("deleted conference with id : " + conferenceId)
        })
    } catch (err) {
        console.log("Error deleting conference in database: " + err)
    }
}

function loadConferenceFromDatabase(conferenceId) {
    var result = {};
    try {
        var db = Database.getOpenDatabase()
        db.transaction(function (tx) {
            var dbResult = tx.executeSql(
                        'SELECT id,name,year,url,homeUrl,startDate,endDate,state,content FROM conference WHERE id = ?',
                        [conferenceId])
            // create same object as from json response
            if (dbResult.rows.length === 1) {
                var resultRow = dbResult.rows.item(0);
                result.id = resultRow.id;
                result.year = resultRow.year;
                result.name = resultRow.name;
                result.startDate = resultRow.startDate;
                result.endDate = resultRow.endDate;
                result.url = resultRow.url;
                result.content = resultRow.content;
                console.log("loading conference data from database for conference with id : " + conferenceId);
            } else {
                console.log("failed loading conference data from database for conference with id : " + conferenceId);
            }
        })
    } catch (err) {
        console.log("Error deleting conference in database: " + err)
    }
    return result;
}

// persists the conference images - either insert or update
function persistConferenceImage(conferenceId, resourceType, newContent, eTag, resourceId) {
    var result = ""
    try {
        var db = getOpenDatabase();

        // eTag may contain leading / trailing double quotes
        //eTag = eTag.replace('"', '');

        console.log("[conference_resource] trying to insert row for images " + conferenceId + ", " + resourceId + ", etag : " + eTag);

        // TODO debugging - remove me later
        db.transaction(function (tx) {
            var results = tx.executeSql(
                        'SELECT * FROM conference_resources order by rowid desc')
            if (results.rows.length > 0) {
                console.log("conference_resources column count : " + results.rows.length);
                for (var i = 0; i < results.rows.length; i++) {
                    var row = results.rows.item(i);
                    console.log("[conference_resource] pk is : " + row.conferenceId + "/" + row.resourceId + "/" + row.resourceType);
                }
            }
        })

        // insert
        db.transaction(function (tx) {
          tx.executeSql(
                'INSERT OR REPLACE INTO conference_resources (conferenceId, resourceId, resourceType, etag, content) VALUES (?, ?, ?, ?, ?)',
                [conferenceId, resourceId, resourceType, eTag, newContent])
          })
          result = qsTr("Conference images stored. " + resourceId)
    } catch (err) {
        result = qsTr("Failed to store conference images.")
        console.log("[conference_resource]" + result + err)
    }
    return result
}

function loadConferenceImage(conferenceId, resourceId) {
    var resultImageData = {};
    try {
        var db = getOpenDatabase()
        console.log("trying to retrieve images for conferenceId/resourceId " + conferenceId + "/" + resourceId);

        // TODO move to js function class
        db.transaction(function (tx) {

//            var results1 = tx.executeSql('SELECT * from conference_resources');
//            for (var i = 0; i < results1.rows.length; i++) {
//                console.log("result [images] : " + results1.rows.item(i).id + ", " + results1.rows.item(i).conferenceId + ", " + results1.rows.item(i).resourceId)
//            }

            // TODO add constraints to table
            var results = tx.executeSql(
                        'SELECT content, etag FROM conference_resources WHERE conferenceId = ? AND resourceId = ?', [conferenceId, resourceId])

            if (results.rows.length > 0) {
                resultImageData.eTag = results.rows.item(0).etag;
                var jsonData = results.rows.item(0).content;
                if (("" + jsonData).substring(0,4) === "data") {
                    resultImageData.content = jsonData;
                } else {
                    // conference logo is stored as json (TODO fix and extract the plain DATA)
                    var jsonObj = JSON.parse(jsonData);
                    // console.log(jsonObj.conferenceImage);
                    if (jsonObj.conferenceImage) {
//                        console.log('Found conference image ! Image : ' + jsonObj.conferenceImage)
                        resultImageData.content = jsonObj.conferenceImage;
                    }
                }
            } else {
                console.log("no image found for conferenceId : " + conferenceId)
            }
        })
    } catch (err) {
        console.log("Failed to load conference images. " + err)
    }
    return resultImageData;
}

// 'CREATE TABLE IF NOT EXISTS conference_resources (id INTEGER PRIMARY KEY ASC, conferenceId text, resourceType text, resourceId text, etag text, data text)')
