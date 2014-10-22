# ################################################################
# NAME: Dockerfile
# DESC: Docker file to create Elasticsearch container.
#
# LOG:
# yyyy/mm/dd [name] [version]: [notes]
# 2014/10/15 cgwong [v0.1.0]: Initial creation.
# ################################################################

FROM dockerfile/java:oracle_java7
MAINTAINER Stuart Wong <cgs.wong@gmail.com>

# Install Elasticsearch
##ENV ES_VERSION 1.4.0.Beta1
##ENV ES_VERSION 1.3.4
ENV ES_VERSION 1.3
ENV ES_BASE_DIR /opt/elasticsearch
##WORKDIR /tmp
##RUN wget https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-$ES_VERSION.deb
##RUN dpkg -i elasticsearch-$ES_VERSION.deb
RUN wget -qO - http://packages.elasticsearch.org/GPG-KEY-elasticsearch | sudo apt-key add -
RUN echo "deb http://packages.elasticsearch.org/elasticsearch/${ES_VERSION}/debian stable main" >> /etc/apt/sources.list
RUN apt-get -y update && apt-get -y install elasticsearch

# Expose persistent Elasticsearch configuration storage area
RUN mkdir -p ${ES_BASE_DIR}/{data,log,plugin,work,conf} && chown -R elasticsearch:elasticsearch ${ES_BASE_DIR}
VOLUME ["/opt/elasticsearch"]

# Mount elasticsearch.yml config
COPY config/elasticsearch.yml ${ES_BASE_DIR}/conf/elasticsearch.yml

# Define working directory.
WORKDIR ${ES_BASE_DIR}

# Listen for connections on HTTP port/interface: 9200
EXPOSE 9200
# Listen for cluster connections on port/interface: 9300
EXPOSE 9300

# Start container
USER elasticsearch
CMD ["/usr/share/elasticsearch/bin/elasticsearch"]
##CMD /usr/share/elasticsearch/bin/elasticsearch -p /var/run/elasticsearch/elasticsearch.pid -Des.default.config=$CONF_FILE -Des.default.path.home=$ES_HOME -Des.default.path.logs=$LOG_DIR -Des.default.path.data=$DATA_DIR -Des.default.path.work=$WORK_DIR -Des.default.path.conf=$CONF_DIR
