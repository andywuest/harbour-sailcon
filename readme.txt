# generate or remove license header -via maven plugin
mvn license:format
mvn license:remove

# checkout dukecon_server - in directory impl run
mvn spring-boot:run -Dserver.port=8083

curl http://localhost:8083/rest/conferences
curl http://localhost:8083/rest/conferences/javaland2016
curl http://localhost:8083/rest/speaker/images



