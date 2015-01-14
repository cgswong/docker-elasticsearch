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
# 2014/12/04 cgwong v0.2.1: User more universal useradd/groupadd commands.
# 2015/01/08 cgwong v0.3.1: Updated to ES 1.4.2.
# 2015/01/14 cgwong v0.4.0: More variable usage. Use curl instead of wget for download.
# ################################################################

FROM dockerfile/java:oracle-java7
MAINTAINER Stuart Wong <cgs.wong@gmail.com>

# Setup environment
ENV ES_VERSION 1.4.2
ENV ES_BASE /opt
ENV ES_HOME ${ES_BASE}/elasticsearch
ENV ES_FILE_CONF ${ES_HOME}/conf/elasticsearch.yml
ENV ES_USER elasticsearch
ENV ES_GROUP elasticsearch
ENV ES_EXEC /usr/local/bin/elasticsearch.sh

# Install Elasticsearch
##RUN wget -qO - http://packages.elasticsearch.org/GPG-KEY-elasticsearch | sudo apt-key add -
##RUN echo "deb http://packages.elasticsearch.org/elasticsearch/${ES_VERSION}/debian stable main" >> /etc/apt/sources.list
##RUN apt-get -y update && apt-get -y install elasticsearch
RUN mkdir -p ${ES_BASE}
WORKDIR ${ES_BASE}
RUN curl -s https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-${ES_VERSION}.tar.gz | tar zx -C ${ES_BASE} \
  && ln -s elasticsearch-${ES_VERSION} elasticsearch

# Configure environment
RUN groupadd -r ${ES_GROUP} \
  && useradd -M -r -d ${ES_HOME} -g ${ES_GROUP} -c "Elasticsearch Service User" -s /bin/false ${ES_USER} \
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
COPY elasticsearch.sh ${ES_EXEC}
RUN chmod +x ${ES_EXEC}
ENTRYPOINT ["$ES_EXEC"]
