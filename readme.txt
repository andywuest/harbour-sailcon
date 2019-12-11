> ssh -p 2222 -i ~/SailfishOS/vmshare/ssh/private_keys/engine/mersdk mersdk@localhost
> cd /home/src1/projects/sailfishos/github/harbour-sailcon
> mb2 -t SailfishOS-2.2.0.29-armv7hl build


# generate or remove license header -via maven plugin
mvn license:format
mvn license:remove

# checkout dukecon_server - in directory impl run
mvn spring-boot:run -Dserver.port=8083

curl http://localhost:8083/rest/conferences
curl http://localhost:8083/rest/conferences/javaland2016
curl http://localhost:8083/rest/speaker/images

# image-resources.json
curl http://localhost:8083/rest/image-resources/javaland/2016/
# 
curl http://localhost:8083/rest/init/javaland/2016/


