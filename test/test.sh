#!/usr/bin/env sh

# Exit on error.
set -e

# Wait for Hadoop to become available.
dockerize -wait tcp://namenode:9000 -timeout 30s

# Create a /test directory (if it does not exists yet, due to a previous test run).
hdfs dfs -mkdir -p /test

# Write some test data into /test/data (overwriting any data from previous test runs).
echo "Some arbitrary test data..." | hdfs dfs -put -f - /test/data

# Ensure the operations were actually performed on HDFS.
hdfs dfs -test -s hdfs://namenode:9000/test/data

# Cleanup the test data.
hdfs dfs -rm -r -f /test
