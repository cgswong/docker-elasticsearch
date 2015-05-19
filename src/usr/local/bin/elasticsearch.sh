#! /bin/bash
# #################################################################
# NAME: elasticsearch.sh
# DESC: Elasticsearch startup file.
# #################################################################

# Fail immediately if anything goes wrong and return the value of the last command to fail/run
set -eo pipefail

# Set environment
ES_CLUSTER_NAME=${ES_CLUSTER_NAME:-"escluster01"}
ES_CFG_FILE="/var/lib/elasticsearch/config/elasticsearch.yml"

# Download the config file if given a URL
if [ ! "$(ls -A ${ES_CFG_URL})" ]; then
  curl --location --silent --insecure --output ${ES_CFG_FILE} ${ES_CFG_URL}
  if [ $? -ne 0 ]; then
    echo "[ES] Unable to download file ${ES_CFG_URL}."
    exit 1
  fi
fi

# Process environment variables
for VAR in `env`; do
  if [[ $VAR =~ ^ES_ && ! $VAR ~= ^ES_CFG_FILE && ! $VAR ~= ^ES_CFG_URL ]]; then
    ES_CONFIG_VAR=`echo "$VAR" | sed -r "s/ES_(.*)=.*/\1/g" | tr '[:upper:]' '[:lower:]' | tr _ .`
    ES_ENV_VAR=`echo "$VAR" | sed -r "s/(.*)=.*/\1/g"`

    if egrep -q "(^|^#)$ES_CONFIG_VAR" $ES_CFG_FILE; then
      sed -r -i "s\\(^|^#)$ES_CONFIG_VAR=.*$\\$ES_CONFIG_VAR=${!ES_ENV_VAR}\\g" $ES_CFG_FILE
    else
      echo "$ES_CONFIG_VAR=${!ES_ENV_VAR}" >> $ES_CFG_FILE
    fi
  fi
done

# if `docker run` first argument start with `--` the user is passing launcher arguments
if [[ $# -lt 1 ]] || [[ "$1" == "--"* ]]; then
  /opt/elasticsearch/bin/elasticsearch \
    --config=${ES_CFG_FILE} \
    "$@"
fi

# As argument is not `elasticsearch`, assume user want to run his own process, for example a `bash` shell to explore this image
exec "$@"
