NAMESPACE ?= yarn-cluster

up: init create-svc create-rc
init: create-namespace create-configmap
clean: delete-svc delete-rc delete-configmap delete-namespace

### Namespace
create-namespace:
		kubectl create -f manifests/namespace-yarn-cluster.yaml

delete-namespace:
		-kubectl delete namespace ${NAMESPACE}

kubectl:
		$(eval KUBECTL := kubectl --namespace $(NAMESPACE))


### Config Map
delete-configmap: kubectl
		-$(KUBECTL) delete configmap hadoop-config

create-configmap:
		./manifests/make_hadoop_configmap.sh

get-configmap: kubectl
		$(KUBECTL) get configmap hadoop-config -o=yaml


### Replication Controllers
create-rc: create-hdfs create-yarn create-zeppelin
delete-rc: delete-zeppelin delete-yarn delete-hdfs

create-hdfs: create-namenode-controller create-datanode-controller
delete-hdfs: delete-datanode-controller delete-namenode-controller
create-zeppelin: create-zeppelin-controller
delete-zeppelin: delete-zeppelin-controller

create-yarn: create-resource-manager-controller create-node-manager-controller
delete-yarn: delete-node-manager-controller delete-resource-manager-controller

create-namenode-controller: kubectl
		$(KUBECTL) create -f manifests/hdfs-namenode-controller.yaml

delete-namenode-controller: kubectl
		-$(KUBECTL) delete rc hdfs-namenode-controller

create-datanode-controller: kubectl
		$(KUBECTL) create -f manifests/hdfs-datanode-controller.yaml

delete-datanode-controller: kubectl
		-$(KUBECTL) delete rc hdfs-datanode-controller

create-resource-manager-controller: kubectl
		$(KUBECTL) create -f manifests/yarn-resource-manager-controller.yaml

delete-resource-manager-controller: kubectl
		-$(KUBECTL) delete rc yarn-resource-manager-controller

create-node-manager-controller: kubectl
		$(KUBECTL) create -f manifests/yarn-node-manager-controller.yaml

delete-node-manager-controller: kubectl
		-$(KUBECTL) delete rc yarn-node-manager-controller

create-zeppelin-controller: kubectl
		$(KUBECTL) create -f manifests/zeppelin-controller.yaml

delete-zeppelin-controller: kubectl
		-$(KUBECTL) delete rc zeppelin-controller


### Services
create-svc: create-datanode-service create-namenode-service create-resource-manager-service
delete-svc: delete-datanode-service delete-namenode-service delete-resource-manager-service

create-namenode-service: kubectl
		$(KUBECTL) create -f manifests/hdfs-namenode-service.yaml

delete-namenode-service: kubectl
		-$(KUBECTL) delete service hdfs-namenode

create-datanode-service: kubectl
		$(KUBECTL) create -f manifests/hdfs-datanode-service.yaml

delete-datanode-service: kubectl
		-$(KUBECTL) delete service hdfs-datanode

create-resource-manager-service: kubectl
		$(KUBECTL) create -f manifests/yarn-resource-manager-service.yaml

delete-resource-manager-service: kubectl
		-$(KUBECTL) delete service yarn-resource-manager

create-zeppelin-service: kubectl
		$(KUBECTL) create -f manifests/zeppelin-service.yaml

delete-zeppelin-service: kubectl
		-$(KUBECTL) delete service zeppelin


### Helper tasks
get-rc: kubectl
		$(KUBECTL) get rc

get-pods: kubectl
		$(KUBECTL) get pods

get-svc: kubectl
		$(KUBECTL) get services

get-namenode-pod: kubectl
		$(eval NAMENODE_POD := $(shell $(KUBECTL) get pods -l component=hdfs-namenode -o jsonpath={.items..metadata.name}))
		echo $(NAMENODE_POD)

get-datanode-pod: kubectl
		$(eval DATANODE_POD := $(shell $(KUBECTL) get pods -l component=hdfs-datanode -o jsonpath={.items..metadata.name}))
		echo $(DATANODE_POD)

get-resource-manager-pod: kubectl
		$(eval RESOURCE_MANAGER_POD := $(shell $(KUBECTL) get pods -l component=yarn-resource-manager -o jsonpath={.items..metadata.name}))
		echo $(RESOURCE_MANAGER_POD)

get-zeppelin-pod: kubectl
		$(eval ZEPPELIN_POD := $(shell $(KUBECTL) get pods -l component=zeppelin -o jsonpath={.items..metadata.name}))
		echo $(ZEPPELIN_POD)

namenode-logs: kubectl get-namenode-pod
		$(KUBECTL) logs $(NAMENODE_POD)

datanode-logs: kubectl get-datanode-pod
		$(KUBECTL) logs $(DATANODE_POD)

namenode-shell: kubectl get-namenode-pod
		$(KUBECTL) exec -it $(NAMENODE_POD) -- bash

datanode-shell: kubectl get-datanode-pod
		$(KUBECTL) exec -it $(DATANODE_POD) -- bash

resource-manager-shell: kubectl get-resource-manager-pod
		$(KUBECTL) exec -it $(RESOURCE_MANAGER_POD) -- bash

dfsreport: kubectl get-namenode-pod
		$(KUBECTL) exec -it $(NAMENODE_POD) -- /usr/local/hadoop/bin/hdfs dfsadmin -report

port-forward-rm: get-resource-manager-pod
		$(KUBECTL) port-forward $(RESOURCE_MANAGER_POD) 8088:8088

port-forward-zeppelin: get-zeppelin-pod
		$(KUBECTL) port-forward $(ZEPPELIN_POD) 8081:8080
