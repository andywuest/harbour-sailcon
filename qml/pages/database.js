// .pragma library
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
                        + ' (id text primary key, name text, year text, url text, homeUrl text, startDate text, endDate text, state integer, content text, etag text)')
            tx.executeSql(
                        'CREATE TABLE IF NOT EXISTS talk'
                        + ' (talkId INTEGER NOT NULL, favorite BOOLEAN NOT NULL DEFAULT false, rated BOOLEAN NOT NULL DEFAULT false, rating INTEGER)')
            tx.executeSql(
                        'CREATE TABLE IF NOT EXISTS conference_resources (id INTEGER PRIMARY KEY ASC, conferenceId text, resourceType text, resourceId text, etag text, content text)')
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

// TODO rename singular
// persists the conference data - either insert or update
function persistConferenceData(data, newContent, eTag, responseETag) {
    var result = ""
    try {
        var db = getOpenDatabase()
        console.log("trying to insert row for " + data.id + ", " + data.name)

        var numberOfPersistedConferences = 0;

        // TODO debugging - remove me later
        db.transaction(function (tx) {
            var results = tx.executeSql(
                        'SELECT id,name,year,url,homeUrl,startDate,endDate,content FROM conference order by rowid desc')
            numberOfPersistedConferences = results.rows.length;
            for (var i = 0; i < results.rows.length; i++) {
                console.log("result : " + results.rows.item(
                                i).id + ", " + results.rows.item(i).name)
            }
        })

        console.log("number of persisted conferences : " + numberOfPersistedConferences)

        // TODO end
        if (eTag) {
            // if data was requested with an eTag - update
            db.transaction(function (tx) {
                tx.executeSql(
                            'UPDATE conference SET name = ?, year = ?, url = ?, homeUrl = ?, startDate = ?, endDate = ?, content = ?, etag = ? WHERE id = ?',
                            [data.name, data.year, data.url, data.homeUrl, data.startDate, data.endDate, newContent, responseETag, data.id])
            })
            result = qsTr("Conference data updated.")
            console.log(result + " id : " + data.id)
        } else {
            // insert
            db.transaction(function (tx) {
                // mark the first conference directly as active
                var initialState = (numberOfPersistedConferences === 0 ? 1 : 0);
                tx.executeSql(
                            'INSERT INTO conference VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
                            [data.id, data.name, data.year, data.url, data.homeUrl, data.startDate, data.endDate, initialState, newContent, responseETag])
            })
            result = qsTr("Conference data stored.")
        }
    } catch (err) {
        result = qsTr("Failed to store conference data.")
        console.log(result + err)
    }
    return result
}

// persists the conference images - either insert or update
function persistConferenceImages(data, resourceType, newContent, eTag, responseETag, resourceId) {
    var result = ""
    try {
        var db = getOpenDatabase()
        console.log("trying to insert row for images " + data.id + ", " + data.name)

        // TODO debugging - remove me later
//        db.transaction(function (tx) {
//            var results = tx.executeSql(
//                        'SELECT * FROM conference_resources order by rowid desc')
//            for (var i = 0; i < results.rows.length; i++) {
//                console.log("result : " + results.rows.item(
//                                i).id + ", " + results.rows.item(i).resourceType)
//            }
//        })

        // TODO debugging - remove me later
        db.transaction(function (tx) {
            var results = tx.executeSql(
                        'SELECT count(*) FROM conference_resources order by rowid desc')
            for (var i = 0; i < results.rows.length; i++) {
                console.log("count is : " + results.rows.item(i).id)
            }
        })


        // TODO end
        if (eTag) {
            // if data was requested with an eTag - update
//            db.transaction(function (tx) {
//                // TODO implement update
//                tx.executeSql(
//                            'UPDATE conference_resources SET name = ?, year = ?, url = ?, homeUrl = ?, startDate = ?, endDate = ?, content = ?, etag = ? WHERE id = ?',
//                            [data.name, data.year, data.url, data.homeUrl, data.startDate, data.endDate, newContent, responseETag, data.id])
//            })
            result = qsTr("Conference images updated.")
            console.log(result + " id : " + data.id)
        } else {
            // insert
            db.transaction(function (tx) {
                tx.executeSql(
                            'INSERT INTO conference_resources (conferenceId, resourceType, resourceId, etag, content) VALUES(?, ?, ?, ?, ?)',
                            [data.id, resourceType, resourceId, responseETag, newContent])
            })
            result = qsTr("Conference images stored. " + resourceId)
        }
    } catch (err) {
        result = qsTr("Failed to store conference images.")
        console.log(result + err)
    }
    return result
}


// TODO rename singular
function loadConferenceImages(conferenceId, resourceId) {
    var resultImage = null;
    try {
        var db = getOpenDatabase()
        console.log("trying to retrieve images for conferenceId " + conferenceId)

        // TODO move to js function class
        var db = Database.getOpenDatabase()
        db.transaction(function (tx) {

//            var results1 = tx.executeSql('SELECT * from conference_resources');
//            for (var i = 0; i < results1.rows.length; i++) {
//                console.log("result [images] : " + results1.rows.item(i).id + ", " + results1.rows.item(i).conferenceId + ", " + results1.rows.item(i).resourceId)
//            }

            // TODO add constraints to table
            var results = tx.executeSql(
                        'SELECT content FROM conference_resources WHERE conferenceId = ? AND resourceId = ?', [conferenceId, resourceId])

            if (results.rows.length > 0) {
                var resultRow = results.rows.item(0)
                console.log("image found : " + resultRow)
                var jsonData = resultRow.content;
                if (("" + jsonData).substring(0,4) === "data") {
                    resultImage = jsonData;
                } else {
                    // conference logo is stored as json (TODO fix and extract the plain DATA)
                    var jsonObj = JSON.parse(jsonData);
                    // console.log(jsonObj.conferenceImage);
                    if (jsonObj.conferenceImage) {
//                        console.log('Found conference image ! Image : ' + jsonObj.conferenceImage)
                        resultImage = jsonObj.conferenceImage;
                    }
                }
            } else {
                console.log("no image found for conferenceId : " + conferenceId)
            }
        })
    } catch (err) {
        console.log("Failed to load conference images. " + err)
    }
    return resultImage;
}


// 'CREATE TABLE IF NOT EXISTS conference_resources (id INTEGER PRIMARY KEY ASC, conferenceId text, resourceType text, resourceId text, etag text, data text)')
