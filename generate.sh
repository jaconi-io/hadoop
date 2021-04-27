#!/usr/bin/env sh

###
# Generate teamplates that make Hadoop configurable via environment variables.
###

generate() {
  echo "<?xml version=\"1.0\"?>"
  echo "<?xml-stylesheet type=\"text/xsl\" href=\"configuration.xsl\"?>"

  echo "<configuration>"
  for property in $(xmlstarlet select --template --match "/configuration/property/name" --value-of "." --output " " $1); do
    ENV=$(echo $property | tr "a-z" "A-Z" | tr "." "_" | tr "-" "_" | tr "[" "_" | tr "]" "_" )
    echo "{{- if .Env.$ENV }}"
    echo "  <property>"
    echo "    <name>$property</name>"
    echo "    <value>{{ .Env.$ENV }}</value>"
    echo "  </property>"
    echo "{{- end }}"
  done
  echo "</configuration>"
}

curl "https://hadoop.apache.org/docs/r${HADOOP_VERSION}/hadoop-project-dist/hadoop-common/core-default.xml" --output "core-default.xml"
generate "core-default.xml" > core-site.xml.tmpl

curl "https://hadoop.apache.org/docs/r${HADOOP_VERSION}/hadoop-project-dist/hadoop-hdfs/hdfs-default.xml" --output "hdfs-default.xml"
generate "core-default.xml" > hdfs-site.xml.tmpl

curl "https://hadoop.apache.org/docs/r${HADOOP_VERSION}/hadoop-yarn/hadoop-yarn-common/yarn-default.xml" --output "yarn-default.xml"
generate "core-default.xml" > yarn-site.xml.tmpl

curl "https://hadoop.apache.org/docs/r${HADOOP_VERSION}/hadoop-mapreduce-client/hadoop-mapreduce-client-core/mapred-default.xml" --output "mapred-default.xml"
generate "core-default.xml" > mapred-site.xml.tmpl
