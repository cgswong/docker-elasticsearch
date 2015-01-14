#! /bin/bash
# #################################################################
# NAME: elasticsearch.sh
# DESC: Elasticsearch startup file.
#
# LOG:
# yyyy/mm/dd [user] [version]: [notes]
# 2014/10/23 cgwong v0.1.0: Initial creation
# 2014/11/07 cgwong v0.1.1: Use config file switch.
# 2014/11/10 cgwong v0.2.0: Added environment variables.
# #################################################################

# Set environment
##ES_DIR_BASE=/opt/elasticsearch
ES_BASE=/opt
ES_HOME=${ES_BASE}/elasticsearch
ES_FILE_CONF=${ES_HOME}/conf/elasticsearch.yml
ES_CLUSTER_NAME=${ES_CLUSTER_NAME:-"es_cluster01"}
##ES_DIR_LOG=${ES_DIR_LOG:-"$ES_HOME/logs"}
##ES_DIR_CONF=${ES_DIR_CONF:-"$ES_HOME/conf"}
##ES_DIR_DATA=${ES_DIR_DATA:-"$ES_HOME/data"}
##ES_DIR_WORK=${ES_DIR_WORK:-"$ES_HOME/work"}

# Set cluster name as provided
if [ ! -z ${ES_CLUSTER_NAME} ]; then
  sed -e "s/ES_CLUSTER_NAME/${ES_CLUSTER_NAME}/" -i $ES_FILE_CONF
fi

##sed -e "s/#gateway.recover_after_time: 5m/gateway.recover_after_time: 5m/" -i $ES_FILE_CONF
##sed -e "s/#discovery.zen.ping.multicast.enabled: false/discovery.zen.ping.multicast.enabled: false/" -i $ES_FILE_CONF
##sed -e "s/#discovery.zen.ping.unicast.hosts: ["host1", "host2:port"]/#discovery.zen.ping.unicast.hosts: ["host1", "host2:port"]/" -i $ES_FILE_CONF
##sed -e "s/#bootstrap.mlockall: true/bootstrap.mlockall: true/" -i $ES_FILE_CONF

# if `docker run` first argument start with `--` the user is passing launcher arguments
if [[ $# -lt 1 ]] || [[ "$1" == "--"* ]]; then
##  /usr/share/elasticsearch/bin/elasticsearch \
  ${ES_HOME}/bin/elasticsearch \
    -Des.default.config=$ES_FILE_CONF \
##    -Des.default.path.logs=$ES_DIR_LOG \
##    -Des.default.path.data=$ES_DIR_DATA \
##    -Des.default.path.work=$ES_DIR_WORK \
##    -Des.default.path.conf=$ES_DIR_CONF "$@"
##  ${ES_HOME}/bin/elasticsearch \
    "$@"
fi

# As argument is not Elasticsearch, assume user want to run his own process, for sample a `bash` shell to explore this image
exec "$@"
