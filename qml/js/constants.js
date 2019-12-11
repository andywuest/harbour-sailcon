.pragma library

var loggingEnabled = true;
var CONFERENCE_INACTIVE = 'INACTIVE';
var CONFERENCE_ACTIVE = 'ACTIVE';

var HTTP_OK = 200;
var HTTP_NOT_MODIFIED = 304;

var RETURN_CODE_OK = 0;
var RETURN_CODE_NOT_MODIFIED = 1;
var RETURN_CODE_ERROR = 2;

var VERSION = "0.1.0"

var CONFERENCE_LOGO = 'conferenceImage';

// default endpoint for the conferences (basically the starting point)
var CONFERENCES_URL = 'https://latest.dukecon.org/conferences';
var SINGLE = true;
// dukecon_server demo conference - start with 'mvn spring-boot:run -Dserver.port=8083'
// you need to add you local ip address to make sure the vb image can access the server
//var CONFERENCES_URL = 'http://192.168.123.128:8083/rest/conferences';
//var SINGLE = true;

//FROM https://cdnjs.cloudflare.com/ajax/libs/Base64/1.0.1/base64.js
//function base64Encode (input) {
//    var chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=';
//    var str = String(input);
//    for (
//        // initialize result and counter
//        var block, charCode, idx = 0, map = chars, output = '';
//        str.charAt(idx | 0) || (map = '=', idx % 1);
//        output += map.charAt(63 & block >> 8 - idx % 1 * 8)
//        ) {
//        charCode = str.charCodeAt(idx += 3/4);
//        if (charCode > 0xFF) {
//            throw new Error("Base64 encoding failed: The string to be encoded contains characters outside of the Latin1 range.");
//        }
//        block = block << 8 | charCode;
//    }
//    return output;
//}
