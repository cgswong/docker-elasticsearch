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
# 2015/02/02 cgwong v1.0.1: Simplified directories and variables.
# #################################################################

# Fail immediately if anything goes wrong and return the value of the last command to fail/run
set -eo pipefail

# Set environment
ES_HOME=/opt/elasticsearch
ES_VOL=/esvol
ES_CONF=${ES_CONF:-"$ES_VOL/config/elasticsearch.yml"}
ES_CLUSTER=${ES_CLUSTER:-"es_cluster01"}
ES_PORT=${ES_PORT:-"9200"}

KV_TYPE=${KV_TYPE:-etcd}
KV_HOST=${KV_HOST:-172.17.8.101}
KV_PORT=${KV_PORT:-4001}
KV_URL=${KV_HOST}:${KV_PORT}

echo "[elasticsearch] booting container. KV store: $KV_TYPE"

if [ "$KV_TYPE" == "etcd" ]; then
  # Etcd as KV store
  curl -X PUT -d "$ES_CLUSTER" http://${KV_URL}/v2/keys/es/cluster
  #curl -X PUT -d "$ES_PORT" http://${KV_URL}/v2/keys/es/host
else
  # Assume it's consul KV otherwise
  curl -X PUT -d "$ES_CLUSTER" http://${KV_URL}/v1/kv/es/cluster
  #curl -X PUT -d "$ES_PORT" http://${KV_URL}/v1/kv/es/host?cas=

fi
#sed -ie "s/-backend etcd -node 127.0.0.1:4001/-backend ${KV_TYPE} -node ${KV_URL}/" /etc/supervisor/conf.d/confd.conf

# Try to make initial configuration
confd -onetime -backend $KV_TYPE -node $KV_URL -config-file /etc/confd/conf.d/elasticsearch.yml.toml

# if `docker run` first argument start with `--` the user is passing launcher arguments
if [[ $# -lt 1 ]] || [[ "$1" == "--"* ]]; then
#  /usr/bin/supervisord -c /etc/supervisor/supervisord.conf
  su -s /bin/bash $ES_USER -c \
    ${ES_HOME}/bin/elasticsearch \
    -Des.default.config=$ES_CONF \
    "$@"
fi

# As argument is not Elasticsearch, assume user want to run his own process, for sample a `bash` shell to explore this image
exec "$@"
