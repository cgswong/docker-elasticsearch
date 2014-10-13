docker-elasticsearch
====================

Docker container for Elasticsearch. Logstash is the leading open source log management server. It is usually backed with Elasticsearch as the datastore, and Kibana is the frontend. This is the Elasticsearch Docker container in that architecture, or any other requiring Elasticsearch.


## Running The Server

Build and run the docker image:

```
git clone https://github.com/cgswong/docker-elasticsearch.git
docker build .
docker run -p 9200:9200 <image id>
```
