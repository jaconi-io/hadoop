FROM debian:10 AS builder

ENV HADOOP_VERSION 2.10.1
ENV DEBIAN_FRONTEND noninteractive

# Install security updates and build dependencies.
RUN apt-get update \
 && apt-get --assume-yes upgrade \
 && apt-get --assume-yes install --no-install-recommends ca-certificates curl gnupg \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# Download Apache Hadoop from the closest mirror and verify the download.
RUN curl --location "https://www.apache.org/dyn/mirrors/mirrors.cgi?action=download&filename=hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz" --output "hadoop-${HADOOP_VERSION}.tar.gz" \
 && curl "https://downloads.apache.org/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz.asc" --output "hadoop-${HADOOP_VERSION}.tar.gz.asc" \
 && curl "https://downloads.apache.org/hadoop/common/KEYS" --output "KEYS" \
 && gpg --import KEYS \
 && gpg --verify "hadoop-${HADOOP_VERSION}.tar.gz.asc" "hadoop-${HADOOP_VERSION}.tar.gz" \
 && tar --extract --gzip --file "hadoop-${HADOOP_VERSION}.tar.gz" \
 && mv "hadoop-${HADOOP_VERSION}" "hadoop"

FROM openjdk:8-jre

COPY --from=builder /hadoop /opt/hadoop

ENV PATH /opt/hadoop/bin:${PATH}

ENTRYPOINT [ "hdfs" ]
