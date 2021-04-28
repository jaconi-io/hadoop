#!/usr/bin/env sh

dockerize -template "/opt/hadoop/etc/hadoop/core-site.xml.tmpl:/opt/hadoop/etc/hadoop/core-site.xml"
dockerize -template "/opt/hadoop/etc/hadoop/hdfs-site.xml.tmpl:/opt/hadoop/etc/hadoop/hdfs-site.xml"
dockerize -template "/opt/hadoop/etc/hadoop/yarn-site.xml.tmpl:/opt/hadoop/etc/hadoop/yarn-site.xml"
dockerize -template "/opt/hadoop/etc/hadoop/mapred-site.xml.tmpl:/opt/hadoop/etc/hadoop/mapred-site.xml"

# When starting a namenode, make sure it is properly formatted.
if [ -eq "$@" "hdfs namenode" ]; then
  echo "TODO..."
fi

exec "$@"
