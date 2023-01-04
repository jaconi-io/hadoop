**This project is unmaintained!**

# hadoop

A docker image for [Apache Hadoop](https://hadoop.apache.org/).

## Configuration

Apache Hadoop is usually configured using up to four XML configuration files:

* [core-site.xml](https://hadoop.apache.org/docs/current/hadoop-project-dist/hadoop-common/core-default.xml)
* [hdfs-site.xml](https://hadoop.apache.org/docs/current/hadoop-project-dist/hadoop-hdfs/hdfs-default.xml)
* [mapred-site.xml](https://hadoop.apache.org/docs/current/hadoop-mapreduce-client/hadoop-mapreduce-client-core/mapred-default.xml)
* [yarn-site.xml](https://hadoop.apache.org/docs/current/hadoop-yarn/hadoop-yarn-common/yarn-default.xml)

Mounting all these into a container is tedious. Therefore we exclusively use environment variables to configure Apache
Hadoop in this container.

If you want to set, for example, `fs.defaultFS` in `core-site.xml` you would set the environment variable
`FS_DEFAULTFS` instead. This even works for dynamic properties like `ipc.8020.callqueue.impl`. Just set
`IPC_8020_CALLQUEUE_IMPL`.

## Testing

To test your changes, run

```
docker compose build
docker compose run sut
```
