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
# 2015/01/28 cgwong v0.3.0: Updated variables.
# 2015/01/29 cgwong v0.5.0: Enabled previous variables.
# 2015/01/30 cgwong v1.0.0: Use confd and consul for configuration.
# #################################################################

# Fail immediately if anything goes wrong and return the value of the last command to fail/run
set -eo pipefail

# Set environment
ES_BASE=/opt
ES_HOME=${ES_BASE}/elasticsearch
ES_VOL=${ES_BASE}/esvol
ES_CONF=${ES_CONF:-"$ES_VOL/config/elasticsearch.yml"}
ES_CLUSTER_NAME=${ES_CLUSTER_NAME:-"es_cluster01"}
ES_PORT_9200_TCP_ADDR=${ES_PORT_9200_TCP_ADDR:-"9200"}
ES_DIR_LOG=${ES_DIR_LOG:-"$ES_VOL/logs"}
ES_DIR_DATA=${ES_DIR_DATA:-"$ES_VOL/data"}
ES_DIR_WORK=${ES_DIR_WORK:-"$ES_VOL/work"}

# Set varibles as provided
[ ! -z ${ES_PORT_9200_TCP_ADDR} ] && sed -e "s/#node.name: ES_PORT_9200_TCP_ADDR/node.name: ${ES_PORT_9200_TCP_ADDR}/" -i $ES_CONF

[ ! -z ${ES_RECOVER_TIME} ] && sed -e "s/#gateway.recover_after_time: 5m/gateway.recover_after_time: ${ES_RECOVER_TIME}/" -i $ES_CONF
[ ! -z ${ES_MULTICAST} ] && sed -e "s/#discovery.zen.ping.multicast.enabled: false/discovery.zen.ping.multicast.enabled: ${ES_MULTICAST}/" -i $ES_CONF
[ ! -z ${ES_UNICAST_HOSTS} ] && sed -e "s/#discovery.zen.ping.unicast.hosts: [\"host1\", \"host2:port\"]/discovery.zen.ping.unicast.hosts: ${ES_UNICAST_HOSTS}/" -i $ES_CONF

# Try to make initial configuration every 5 seconds until successful
until confd -onetime -backend consul -node $COREOS_PUBLIC_IPV4:8500 -config-file /etc/confd/conf.d/elasticsearch.yml.toml; do
    echo "[ES] waiting for confd to create initial Elasticsearch configuration"
    sleep 5
done

# Put a continual polling `confd` process into the background to watch for changes every 10 seconds
confd -interval 10 -backend consul -node $COREOS_PUBLIC_IPV4:8500 -config-file /etc/confd/conf.d/elasticsearch.yml.toml &
echo "[ES] confd is now monitoring consul for changes..."

# if `docker run` first argument start with `--` the user is passing launcher arguments
if [[ $# -lt 1 ]] || [[ "$1" == "--"* ]]; then
  su -s /bin/bash $ES_USER -c \
    '${ES_HOME}/bin/elasticsearch \
    -Des.default.config=$ES_CONF \
    -Des.default.path.logs=$ES_DIR_LOG \
    -Des.default.path.data=$ES_DIR_DATA \
    -Des.default.path.work=$ES_DIR_WORK \
    "$@"'
fi

# As argument is not Elasticsearch, assume user want to run his own process, for sample a `bash` shell to explore this image
exec "$@"
