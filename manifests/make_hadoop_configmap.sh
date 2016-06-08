#!/bin/bash

kubectl --namespace yarn-cluster create configmap hadoop-config \
  --from-file=artifacts/bootstrap.sh \
  --from-file=artifacts/start-yarn-rm.sh \
  --from-file=artifacts/start-yarn-nm.sh \
  --from-file=artifacts/slaves \
  --from-file=artifacts/core-site.xml \
  --from-file=artifacts/hdfs-site.xml \
  --from-file=artifacts/mapred-site.xml \
  --from-file=artifacts/yarn-site.xml \
  --from-file=artifacts/hosts-helper.py \
  --from-file=artifacts/update-hosts.sh
