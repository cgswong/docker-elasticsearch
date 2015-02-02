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
To start a basic container with ephemeral storage:

```sh
docker run -d -p 9200:9200 -p 9300:9300 --name elasticsearch cgswong/elasticsearch
```

To start a container with attached persistent/shared storage

  1. Create a mountable data directory `<data-dir>` on the host with a `data` directory. The base directory `/esvol` is exposed as a volume within the container with data stored in `/esvol/data`.

  2. Create an Elasticsearch config file at `<data-dir>`/config/elasticsearch.yml. A sample file is:

    ```yml
    path:
      logs: /opt/esvol/log
      data: /opt/esvol/data
    ```

  3. Start the container by mounting the data directory and specifying the custom configuration file:

    ```sh
    docker run -d -p 9200:9200 -p 9300:9300 -v <data-dir>:/esvol --name elasticsearch cgswong/elasticsearch /opt/elasticsearch/bin/elasticsearch -Des.config=/esvol/config/elasticsearch.yml
    ```

After a few seconds, open `http://<host>:9200` to see the result.

### Changing Defaults
Various environment variables can be passed to do configuration without attaching persistent storage to pass in a configuration file:

  - ES_CLUSTER_NAME: Sets the cluster name (defaults to `es_cluster01`)
  - ES_PORT_9200_TCP_ADDR: Sets the node name. This is automatically set when using a linked container, otherwise defaults to as set by Elasticsearch (i.e. random Marvel character).
  - KV_URL: Sets the IP and port combination for the **consul** backend using **confd**. The format is <IP>:<PORT>.

The KV_URL is used for automatic configuration and reloading whenever configuration changes are made. _The latter is still a work in progress_.

```sh
docker run -d -p 9200:9200 -p 9300:9300 -e ES_CLUSTER_NAME=es_test01 --name elasticsearch cgswong/elasticsearch
```
