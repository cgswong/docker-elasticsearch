docker-elasticsearch
====================

Docker container for Elasticsearch. It is usually the back-end for a Logstash instance with Kibana as the frontend.
This image exposes the HTTP interface on port 9200 and the cluster interface on port 9300. The data is stored in `/var/lib/elasticsearch` which is exposed as a volume.

## Running The Server

Build and run the docker image:

```
git clone https://github.com/cgswong/docker-elasticsearch.git
docker build .
docker run -p 9200:9200 <image id>
```
