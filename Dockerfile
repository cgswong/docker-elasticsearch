# ################################################################
# NAME: Dockerfile
# DESC: Docker file to create Elasticsearch container.
#
# LOG:
# yyyy/mm/dd [name] [version]: [notes]
# 2014/10/15 cgwong [v0.1.0]: Initial creation.
# 2014/11/07 cgwong v0.1.1: Changed plugin to plugins to match config file.
# 2014/11/10 cgwong v0.1.2: Updated comments and full version designation.
# 2014/12/03 cgwong v0.2.0: Corrected header comment. Switched to specific package download.
# ################################################################

FROM dockerfile/java:oracle-java7
MAINTAINER Stuart Wong <cgs.wong@gmail.com>

# Setup environment
ENV ES_VERSION 1.4.1
ENV ES_BASE /opt
ENV ES_HOME ${ES_BASE}/elasticsearch
ENV ES_FILE_CONF ${ES_HOME}/conf/elasticsearch.yml
ENV ES_USER elasticsearch
ENV ES_GROUP elasticsearch

# Install Elasticsearch
##RUN wget -qO - http://packages.elasticsearch.org/GPG-KEY-elasticsearch | sudo apt-key add -
##RUN echo "deb http://packages.elasticsearch.org/elasticsearch/${ES_VERSION}/debian stable main" >> /etc/apt/sources.list
##RUN apt-get -y update && apt-get -y install elasticsearch
RUN mkdir -p ${ES_BASE}
WORKDIR ${ES_BASE}
RUN wget https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-${ES_VERSION}.tar.gz \
  && tar zxf elasticsearch-${ES_VERSION}.tar.gz \
  && rm -f elasticsearch-${ES_VERSION}.tar.gz \
  && ln -s elasticsearch-${ES_VERSION} elasticsearch

# Configure environment
RUN addgroup --system ${ES_GROUP} --quiet \
  && adduser --system --home ${ES_HOME} --no-create-home --ingroup ${ES_GROUP} --disabled-password --shell /bin/false ${ES_USER} \
  && mkdir -p ${ES_HOME}/{data,log,plugins,work,conf} \
  && chown -R ${ES_USER}:${ES_GROUP} ${ES_HOME}
VOLUME ["${ES_HOME}"]

# Copy in elasticsearch config file
COPY conf/elasticsearch.yml ${ES_FILE_CONF}

# Define working directory.
WORKDIR ${ES_HOME}

# Listen for connections on HTTP port/interface: 9200
EXPOSE 9200
# Listen for cluster connections on port/interface: 9300
EXPOSE 9300

# Start container
USER ${ES_USER}
COPY elasticsearch.sh /usr/local/bin/elasticsearch.sh
ENTRYPOINT ["/usr/local/bin/elasticsearch.sh"]
