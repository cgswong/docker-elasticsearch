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

# Install Elasticsearch from Debian repository
RUN wget -qO - http://packages.elasticsearch.org/GPG-KEY-elasticsearch | sudo apt-key add -
RUN echo "deb http://packages.elasticsearch.org/elasticsearch/1.3/debian stable main" >> /etc/apt/sources.list
RUN apt-get -y update && apt-get -y install elasticsearch

# Create container volume for data storage
VOLUME /var/lib/elasticsearch/
USER elasticsearch
CMD source /etc/sysconfig/elasticsearch; /usr/share/elasticsearch/bin/elasticsearch -p /var/run/elasticsearch/elasticsearch.pid -Des.default.config=$CONF_FILE -Des.default.path.home=$ES_HOME -Des.default.path.logs=$LOG_DIR -Des.default.path.data=$DATA_DIR -Des.default.path.work=$WORK_DIR -Des.default.path.conf=$CONF_DIR

# HTTP interface
EXPOSE 9200
# Cluster interface
EXPOSE 9300
