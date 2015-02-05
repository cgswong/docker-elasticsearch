## ElasticSearch Dockerfile

This repository contains a **Dockerfile** of [ElasticSearch](http://www.elasticsearch.org/) for [Docker](https://www.docker.com/)'s [automated build](https://registry.hub.docker.com/u/cgswong/elasticsearch/) published to the public [Docker Hub Registry](https://registry.hub.docker.com/).

It is usually the back-end for a Logstash instance with Kibana as the frontend. Current version used is 1.4.2.


### Base Docker Image

* [cgswong/java:oracleJDK8](https://registry.hub.docker.com/u/cgswong/java/) which is based on [cgswong/min-jessie](https://registry.hub.docker.com/u/cgswong/min-jessie/)


### Installation

1. Install [Docker](https://www.docker.com/).

2. Download [automated build](https://registry.hub.docker.com/u/cgswong/elasticsearch/) from public [Docker Hub Registry](https://registry.hub.docker.com/): `docker pull cgswong/elasticsearch`

   (alternatively, you can build an image from Dockerfile: `docker build -t="cgswong/elasticsearch" github.com/cgswong/docker-elasticsearch`)


### Usage
To start a basic container using the default etcd KV store and ephemeral storage:

```sh
source /etc/environment
docker run --rm --name %p -p 9200:9200 -p 9300:9300 -e KV_HOST=${COREOS_PUBLIC_IPV4} cgswong/elasticsearch
etcdctl set /es/host ${COREOS_PUBLIC_IPV4}
```

To clean up after stopping the container: `etcdctl rm /es/host --with-value ${COREOS_PUBLIC_IPV4}`

Consul equivalent:

```sh
source /etc/environment
docker run --rm --name %p -p 9200:9200 -p 9300:9300 -e KV_HOST=${COREOS_PUBLIC_IPV4} -e KV_TYPE=consul cgswong/elasticsearch
curl -X PUT -d ${COREOS_PUBLIC_IPV4} http://${COREOS_PUBLIC_IPV4}:8500/v1/kv/es/host
```

To clean up after stopping the container: `curl -X DELETE http://${COREOS_PUBLIC_IPV4}:8500/v1/kv/es/host/${COREOS_PUBLIC_IPV4}`

Within the container the data (`/esvol/data`), log (`/esvol/logs`) and config (`/esvol/config`) directories are exposed as volumes so to start a default container with attached persistent/shared storage for data:

```sh
source /etc/environment
mkdir -p /es/data
docker run --rm --name %p -v /es/data:/esvol/data -p 9200:9200 -p 9300:9300 -e KV_HOST=${COREOS_PUBLIC_IPV4} cgswong/elasticsearch
etcdctl set /es/host ${COREOS_PUBLIC_IPV4}
```

The cleanup process remains the same, along with the equivalent for the consul version as previously shown. Attaching persistent storage ensures that the data is retained across container restarts (with some obvious caveats). At this time though, given the state of maturity in this space, I would recommend this be done via a data container (hosting an AWS S3 bucket or other externalized persistent storage) in a production environment.

### Using an Elasticsearch Cluster
Multiple Elasticsearch containers can be launched (or stopped) and the cluster will dynamically resize. **Caution: Note that this process is still in testing and is not robust enough for any type of usage.**

### Changing Defaults
A few environment variables can be passed via the Docker `-e` flag to do some further configuration:

  - ES_CLUSTER: Sets the cluster name (defaults to `es_cluster01`)
  - KV_TYPE: Sets the type of KV store to use as the backend. Options are etcd (default) and consul.
  - KV_PORT: Sets the port used in connecting to the KV store which defaults to 4001 for etcd and 8500 for consul.

**Note: The startup procedures previously shown assume you are using CoreOS (with either etcd or consul as your KV store). If you are not using CoreOS then simply substitute the `source /etc/environment` and `${COREOS_PUBLIC_IPV4}` statements with the appropriate OS specific equivalents.**
