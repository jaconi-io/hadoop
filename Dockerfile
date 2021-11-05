FROM openjdk:8-jre AS builder

ARG HADOOP_VERSION=3.3.1
ENV DOCKERIZE_VERSION v0.6.1
ENV DEBIAN_FRONTEND noninteractive

COPY generate.sh generate.sh

# Install security updates and build dependencies.
RUN apt-get update \
 && apt-get --assume-yes upgrade \
 && apt-get --assume-yes install --no-install-recommends xmlstarlet \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# Download Apache Hadoop from the closest mirror and verify the download. Download dockerize. Generate templates.
RUN curl --location "https://www.apache.org/dyn/mirrors/mirrors.cgi?action=download&filename=hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz" --output "hadoop-${HADOOP_VERSION}.tar.gz" \
  && curl "https://downloads.apache.org/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz.asc" --output "hadoop-${HADOOP_VERSION}.tar.gz.asc" \
  && curl "https://downloads.apache.org/hadoop/common/KEYS" --output "KEYS" \
  && gpg --import KEYS \
  && gpg --verify "hadoop-${HADOOP_VERSION}.tar.gz.asc" "hadoop-${HADOOP_VERSION}.tar.gz" \
  && tar --extract --gzip --file "hadoop-${HADOOP_VERSION}.tar.gz" \
  && mv "hadoop-${HADOOP_VERSION}" "hadoop" \
  && curl --location "https://github.com/jwilder/dockerize/releases/download/${DOCKERIZE_VERSION}/dockerize-linux-amd64-${DOCKERIZE_VERSION}.tar.gz" --output "dockerize-linux-amd64-${DOCKERIZE_VERSION}.tar.gz" \
  && tar --extract --gzip --file "dockerize-linux-amd64-${DOCKERIZE_VERSION}.tar.gz" \
  && ./generate.sh

FROM openjdk:8-jre

ENV PATH /opt/hadoop/bin:${PATH}

COPY --from=builder /dockerize /usr/local/bin/dockerize
COPY --from=builder /hadoop /opt/hadoop
COPY --from=builder /core-site.xml.tmpl /opt/hadoop/etc/hadoop/core-site.xml.tmpl
COPY --from=builder /hdfs-site.xml.tmpl /opt/hadoop/etc/hadoop/hdfs-site.xml.tmpl
COPY --from=builder /yarn-site.xml.tmpl /opt/hadoop/etc/hadoop/yarn-site.xml.tmpl
COPY --from=builder /mapred-site.xml.tmpl /opt/hadoop/etc/hadoop/mapred-site.xml.tmpl

# Setup non-root user.
RUN addgroup --system --gid 10001 hdfs \
 && adduser --system --no-create-home --uid 10001 --ingroup hdfs hdfs \
 && chown -R hdfs:hdfs /opt/hadoop \
 && mkdir -p /tmp/hadoop-hdfs/dfs/data \
 && mkdir -p /tmp/hadoop-hdfs/dfs/name \
 && chown -R hdfs:hdfs /tmp/hadoop-hdfs/dfs/data \
 && chown -R hdfs:hdfs /tmp/hadoop-hdfs/dfs/name

# Link /opt/hadoop/etc/hadoop/*-site.xml to /etc/hadoop, such that /etc/hadoop can be mounted as a volume without
# overwriting other configuration files in /opt/hadoop/etc/hadoop. This is required when using a read-only root
# filesystem.
RUN mkdir -p /etc/hadoop \
 && ln -sf /etc/hadoop/core-site.xml /opt/hadoop/etc/hadoop/core-site.xml \
 && ln -sf /etc/hadoop/hdfs-site.xml /opt/hadoop/etc/hadoop/hdfs-site.xml \
 && ln -sf /etc/hadoop/yarn-site.xml /opt/hadoop/etc/hadoop/yarn-site.xml \
 && ln -sf /etc/hadoop/mapred-site.xml /opt/hadoop/etc/hadoop/mapred-site.xml \
 && chown -R hdfs:hdfs /etc/hadoop

USER hdfs

VOLUME /etc/hadoop
VOLUME /tmp/hadoop-hdfs/dfs/data
VOLUME /tmp/hadoop-hdfs/dfs/name

ENTRYPOINT [ "dockerize", \
  "-template", "/opt/hadoop/etc/hadoop/core-site.xml.tmpl:/etc/hadoop/core-site.xml", \
  "-template", "/opt/hadoop/etc/hadoop/hdfs-site.xml.tmpl:/etc/hadoop/hdfs-site.xml", \
  "-template", "/opt/hadoop/etc/hadoop/yarn-site.xml.tmpl:/etc/hadoop/yarn-site.xml", \
  "-template", "/opt/hadoop/etc/hadoop/mapred-site.xml.tmpl:/etc/hadoop/mapred-site.xml" ]
CMD [ "hdfs", "--help" ]
