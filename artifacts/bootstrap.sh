#!/bin/bash

: ${HADOOP_PREFIX:=/usr/local/hadoop}

. $HADOOP_PREFIX/etc/hadoop/hadoop-env.sh

# Directory to find config artifacts
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

# installing libraries if any - (resource urls added comma separated to the ACP system variable)
cd $HADOOP_PREFIX/share/hadoop/common ; for cp in ${ACP//,/ }; do  echo == $cp; curl -LO $cp ; done; cd -

if [[ "${HOSTNAME}" =~ "hdfs-nn" ]]; then
  mkdir -p /root/hdfs/namenode
  $HADOOP_PREFIX/bin/hdfs namenode -format -force -nonInteractive
  sed -i s/hdfs://hdfs-nn:9000/0.0.0.0:9000/ /usr/local/hadoop/etc/hadoop/core-site.xml
  $HADOOP_PREFIX/sbin/hadoop-daemon.sh start namenode
fi

if [[ "${HOSTNAME}" =~ "hdfs-dn" ]]; then
  mkdir -p /root/hdfs/datanode
  $HADOOP_PREFIX/sbin/hadoop-daemon.sh start datanode
fi

if [[ "${HOSTNAME}" =~ "yarn-rm" ]]; then
  sed -i s/yarn-rm/0.0.0.0/ $HADOOP_PREFIX/etc/hadoop/yarn-site.xml
  cp ${CONFIG_DIR}/start-yarn-rm.sh $HADOOP_PREFIX/sbin/
  cd $HADOOP_PREFIX/sbin
  chmod +x start-yarn-rm.sh
  ./start-yarn-rm.sh
fi

if [[ "${HOSTNAME}" =~ "yarn-nm" ]]; then
  sed -i '/<\/configuration>/d' $HADOOP_PREFIX/etc/hadoop/yarn-site.xml
  cat >> $HADOOP_PREFIX/etc/hadoop/yarn-site.xml <<- EOM
  <property>
    <name>yarn.nodemanager.resource.memory-mb</name>
    <value>${MY_MEM_LIMIT:-2048}</value>
  </property>

  <property>
    <name>yarn.nodemanager.resource.cpu-vcores</name>
    <value>${MY_CPU_LIMIT:-2}</value>
  </property>
EOM
  echo '</configuration>' >> $HADOOP_PREFIX/etc/hadoop/yarn-site.xml
  cp ${CONFIG_DIR}/start-yarn-nm.sh $HADOOP_PREFIX/sbin/
  cd $HADOOP_PREFIX/sbin
  chmod +x start-yarn-nm.sh
  ./start-yarn-nm.sh
fi

if [[ $1 == "-d" ]]; then
  until find ${HADOOP_PREFIX}/logs -mmin -1 | egrep -q '.*'; echo "`date`: Waiting for logs..." ; do sleep 2 ; done
  tail -F ${HADOOP_PREFIX}/logs/* &
  while true; do sleep 1000; done
fi

if [[ $1 == "-bash" ]]; then
  /bin/bash
fi
