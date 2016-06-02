#!/bin/bash

: ${HADOOP_PREFIX:=/usr/local/hadoop}

$HADOOP_PREFIX/etc/hadoop/hadoop-env.sh

CONFIG_DIR="/tmp/hadoop-config"

# Copy config files from volume mount

for f in slaves core-site.xml hdfs-site.xml mapred-site.xml yarn-site.xml; do
  if [[ -e ${CONFIG_DIR}/$f ]]; then
    cp ${CONFIG_DIR}/$f $HADOOP_PREFIX/etc/hadoop/$f
  else
    echo "ERROR: Could not find $f in $CONFIG_DIR"
    exit 1
  fi
done

rm /tmp/*.pid

mkdir -p /root/hdfs/namenode
mkdir -p /root/hdfs/datanode

# installing libraries if any - (resource urls added comma separated to the ACP system variable)
cd $HADOOP_PREFIX/share/hadoop/common ; for cp in ${ACP//,/ }; do  echo == $cp; curl -LO $cp ; done; cd -

if [[ "${HOSTNAME}" =~ "hdfs-namenode" ]]; then
  [[ ! -d /root/hdfs/namenode/current || ${FORMAT_NAMENODE} == true ]] && echo "Formatting namenode" && $HADOOP_PREFIX/bin/hdfs namenode -format -force -nonInteractive

  sed -i s/hdfs-namenode:9000/$HOSTNAME:9000/ /usr/local/hadoop/etc/hadoop/core-site.xml
  service sshd start
  $HADOOP_PREFIX/sbin/hadoop-daemon.sh start namenode
  $HADOOP_PREFIX/sbin/hadoop-daemon.sh start datanode
fi

if [[ "${HOSTNAME}" =~ "hdfs-datanode" ]]; then
  $HADOOP_PREFIX/sbin/hadoop-daemon.sh start datanode
fi

if [[ "${HOSTNAME}" =~ "yarn-resource-manager" ]]; then
  sed -i s/yarn-resource-manager/0.0.0.0/ $HADOOP_PREFIX/etc/hadoop/yarn-site.xml
  cp ${CONFIG_DIR}/start-yarn-rm.sh $HADOOP_PREFIX/sbin/
  cd $HADOOP_PREFIX/sbin
  chmod +x start-yarn-rm.sh
  ./start-yarn-rm.sh
fi

if [[ "${HOSTNAME}" =~ "yarn-node-manager" ]]; then
  cp ${CONFIG_DIR}/start-yarn-nm.sh $HADOOP_PREFIX/sbin/
  cd $HADOOP_PREFIX/sbin
  chmod +x start-yarn-nm.sh
  ./start-yarn-nm.sh
fi

if [[ $1 == "-d" ]]; then
  while true; do sleep 1000; done
fi

if [[ $1 == "-bash" ]]; then
  /bin/bash
fi
