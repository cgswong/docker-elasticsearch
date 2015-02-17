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
# 2015/02/12 cgwong v1.1.0: Put cluster value outside this code. Removed unneeded variables.
# #################################################################

# Fail immediately if anything goes wrong and return the value of the last command to fail/run
set -eo pipefail

# Set environment
ES_CLUSTER=${ES_CLUSTER:-"es01"}
ES_CONF=${ES_CONF:-"/esvol/config/elasticsearch.yml"}
ES_PORT=${ES_PORT:-"9200"}

# if `docker run` first argument start with `--` the user is passing launcher arguments
if [[ $# -lt 1 ]] || [[ "$1" == "--"* ]]; then
  /opt/elasticsearch/bin/elasticsearch \
    --config=${ES_CONF} \
    --cluster.name=${ES_CLUSTER} \
    "$@"
fi

# As argument is not Elasticsearch, assume user want to run his own process, for sample a `bash` shell to explore this image
exec "$@"
