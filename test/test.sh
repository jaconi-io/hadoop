#!/usr/bin/env sh

hdfs dfsadmin -report
hdfs dfs -mkdir /test
echo "Some arbitrary test data..." | hdfs dfs -put - /test/data

# Ensure the operations were actually performed on HDFS:
hdfs dfs -test -e hdfs://namenode:9000/test/data
