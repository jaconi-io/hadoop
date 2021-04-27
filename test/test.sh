#!/usr/bin/env sh

# Wait for Hadoop to become available.
dockerize -wait tcp://namenode:9000 -timeout 30s

# Create a /test directory.
hdfs dfs -mkdir /test

# Write some test data into /test/data.
echo "Some arbitrary test data..." | hdfs dfs -put - /test/data

# Ensure the operations were actually performed on HDFS.
hdfs dfs -test -e hdfs://namenode:9000/test/data
