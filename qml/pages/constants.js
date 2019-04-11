.pragma library

var loggingEnabled = true;
var CONFERENCE_INACTIVE = 0;
var CONFERENCE_ACTIVE = 1;

var HTTP_OK = 200;
var HTTP_NOT_MODIFIED = 304;

var RETURN_CODE_OK = 0;
var RETURN_CODE_NOT_MODIFIED = 1;
var RETURN_CODE_ERROR = 2;

var VERSION = "0.1"

// default endpoint for the conferences (basically the starting point)
// var CONFERENCES_URL = 'https://latest.dukecon.org/conferences';
// var SINGLE = false;
// dukecon_server demo conference - start with 'mvn spring-boot:run -Dserver.port=8083'
// you need to add you local ip address to make sure the vb image can access the server
var CONFERENCES_URL = 'http://192.168.123.128:8083/rest/conferences';
var SINGLE = true;
