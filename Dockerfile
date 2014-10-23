# ################################################################
# NAME: Dockerfile
# DESC: Docker file to create Elasticsearch container.
#
# LOG:
# yyyy/mm/dd [name] [version]: [notes]
# 2014/10/15 cgwong [v0.1.0]: Initial creation.
# ################################################################

FROM dockerfile/java:oracle-java7
MAINTAINER Stuart Wong <cgs.wong@gmail.com>

# Setup environment
##ENV ES_VERSION 1.4.0.Beta1
##ENV ES_VERSION 1.3.4
ENV ES_VERSION 1.3
ENV ES_DIR_BASE /opt/elasticsearch
ENV ES_FILE_CONF ${ES_DIR_BASE}/conf/elasticsearch.yml

# Install Elasticsearch
RUN wget -qO - http://packages.elasticsearch.org/GPG-KEY-elasticsearch | sudo apt-key add -
RUN echo "deb http://packages.elasticsearch.org/elasticsearch/${ES_VERSION}/debian stable main" >> /etc/apt/sources.list
RUN apt-get -y update && apt-get -y install elasticsearch

# Expose persistent Elasticsearch configuration storage area
RUN mkdir -p ${ES_DIR_BASE}/{data1,data2,log,plugin,work,conf} && chown -R elasticsearch:elasticsearch ${ES_DIR_BASE}
VOLUME ["${ES_DIR_BASE}"]

# Mount elasticsearch.yml config
COPY conf/elasticsearch.yml ${ES_FILE_CONF}

# Define working directory.
WORKDIR ${ES_DIR_BASE}

# Listen for connections on HTTP port/interface: 9200
EXPOSE 9200
# Listen for cluster connections on port/interface: 9300
EXPOSE 9300

# Start container
USER elasticsearch
COPY elasticsearch.sh /usr/local/bin/elasticsearch.sh
ENTRYPOINT ["/usr/local/bin/elasticsearch.sh"]
