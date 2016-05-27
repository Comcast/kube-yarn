#!/bin/bash

: ${HADOOP_PREFIX:=/usr/local/hadoop}

$HADOOP_PREFIX/etc/hadoop/hadoop-env.sh

rm /tmp/*.pid

mkdir -p /root/hdfs/namenode
mkdir -p /root/hdfs/datanode

# installing libraries if any - (resource urls added comma separated to the ACP system variable)
cd $HADOOP_PREFIX/share/hadoop/common ; for cp in ${ACP//,/ }; do  echo == $cp; curl -LO $cp ; done; cd -

if [[ "${HOSTNAME}" == "nn" ]]; then
  [[ ! -d /root/hdfs/namenode/current || ${FORMAT_NAMENODE} == true ]] && echo "Formatting namenode" && $HADOOP_PREFIX/bin/hdfs namenode -format

  sed s/HOSTNAME/$HOSTNAME/ /usr/local/hadoop/etc/hadoop/core-site.xml.template > /usr/local/hadoop/etc/hadoop/core-site.xml
  service sshd start
  $HADOOP_PREFIX/sbin/hadoop-daemon.sh start namenode
  $HADOOP_PREFIX/sbin/hadoop-daemon.sh start datanode
else
  $HADOOP_PREFIX/sbin/hadoop-daemon.sh start datanode
fi

$HADOOP_PREFIX/sbin/start-yarn.sh

if [[ $1 == "-d" ]]; then
  while true; do sleep 1000; done
fi

if [[ $1 == "-bash" ]]; then
  /bin/bash
fi
