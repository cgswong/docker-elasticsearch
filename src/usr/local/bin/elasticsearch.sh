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
# 2015/03/05 cgwong v1.2.0: Download config file function.
# 2015/03/17 cgwong v1.3.0: Fix download URL, and exit on error.
# #################################################################

# Fail immediately if anything goes wrong and return the value of the last command to fail/run
set -eo pipefail

# Set environment
ES_HOME="/opt/elasticsearch"
ES_CLUSTER=${ES_CLUSTER:-"es01"}
ES_CFG_FILE=${ES_CFG_FILE:-"/esvol/config/elasticsearch.yml"}
ES_PORT=${ES_PORT:-"9200"}
ES_DISCOVERY=${ES_DISCOVERY:-"none"}

# Download the config file if given a URL
if [ ! "$(ls -A ${ES_CFG_URL})" ]; then
  curl -Ls -o ${ES_CFG_FILE} ${ES_CFG_URL}
  [ $? -ne 0 ] && echo "[elasticsearch] Unable to download file ${ES_CFG_URL}." && exit 1
fi

# Setup for AWS discovery, installing plugins silently, waiting 2 minutes to download before failing
if [ "$ES_DISCOVERY" != "none" && ! -z $AWS_ACCESS_KEY && ! -z $AWS_SECRET_KEY && ! -z $AWS_S3_BUCKET ]; then
  ${ES_HOME}/bin/plugin -install elasticsearch/elasticsearch-cloud-aws --silent --timeout 2m
  [ $? -ne 0 ] && echo "[elasticsearch] Plugin (AWS) installation failed." && exit 1
  echo "[elasticsearch] Installed AWS plugin."

  # Don't need these but are useful for monitoring/managing ES via UI
  ${ES_HOME}/bin/plugin -install lukas-vlcek/bigdesk --silent --timeout 2m
  [ $? -ne 0 ] && echo "[elasticsearch] Plugin (BigDesk) installation failed."
  ${ES_HOME}/bin/plugin -install mobz/elasticsearch-head --silent --timeout 2m
  [ $? -ne 0 ] && echo "[elasticsearch] Plugin (ES HEad) installation failed."

  # Update ES config for AWS discovery
  sed -ie "s/#cloud.aws.access_key: AWS_ACCESS_KEY/cloud.aws.access_key: ${AWS_ACCESS_KEY}" $ES_CFG_FILE
  sed -ie "s/#cloud.aws.secret_key: AWS_SECRET_KEY/cloud.aws.secret_key: ${AWS_SECRET_KEY}" $ES_CFG_FILE
  sed -ie "s/#cloud.node.auto_attributes: true/cloud.node.auto_attributes: true" $ES_CFG_FILE
  sed -ie "s/#discovery.type: ec2/discovery.type: ec2" $ES_CFG_FILE
  sed -ie "s/#gateway.type: s3/gateway.type: s3" $ES_CFG_FILE
  sed -ie "s/#repositories.s3.bucket: \"AWS_S3_BUCKET\"/repositories.s3.bucket: \"$AWS_S3_BUCKET\"" $ES_CFG_FILE
  #sed -ie "s/#network.public_host: _ec2_/network.public_host: _ec2_" $ES_CFG_FILE
fi

# if `docker run` first argument start with `--` the user is passing launcher arguments
if [[ $# -lt 1 ]] || [[ "$1" == "--"* ]]; then
  ${ES_HOME}/bin/elasticsearch \
    --config=${ES_CFG_FILE} \
    --cluster.name=${ES_CLUSTER} \
    "$@"
fi

# As argument is not Elasticsearch, assume user want to run his own process, for sample a `bash` shell to explore this image
exec "$@"
