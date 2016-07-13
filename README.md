# YARN on Kubernetes

![Architecture](docs/k8s_yarn_architecture.png)

#### [Initial Design Document (Google Docs)](https://docs.google.com/document/d/1ZoKLWkHiZZPP-394aUTIOE9R7Vx88pgOC8NE0hkVn24/edit?usp=sharing)

## Running locally

This repo uses [`minikube`](https://github.com/kubernetes/minikube) to start a k8s cluster locally.

The [`Makefile`](./Makefile) contains targets for starting the cluster and helper targets for `kubectl` to apply the K8S manifests and interact with the pods.

When running locally with minikube, make sure your VM has enough resources, you should set the number of cpus to 8 and memory to 8192. If not set, the pods won't have enough resources to fully start and will be stuck in the `Pending` creation phase.

Starting minikube manually:

```
minikube start --cpus 8 --memory 8192
```

Or, start with the Makefile which will download minikube and start the cluster:

```
make minikube
```

## Start the YARN cluster:

```
make
```

This will create all of the components for the cluster.

Run this to create port forwards to `localhost`:

```
make port-forward
```

You should now be able to access the following:

- YARN WebUI: `http://localhost:8088`
- Zeppelin: `http://localhost:8081`
- k8S Canary Dashboard: `http://localhost:31999`

### Spark on YARN in Zeppelin

In your browser, go to Zeppelin at: http://localhost:8081

Create a new note and run this in a paragraph:

```
sc.parallelize(1 to 1000).count
```

Press `shift-enter` to execute the paragraph

The first command executed creates the spark job on yarn and will take a few seconds, then you should get the result `1000` when complete.

### Using Weave Scope (Optional)

Run [Weave Scope](https://www.weave.works/docs/scope/0.15.0/installing/#k8s) to visualize and access pods in the cluster:

```
make create-weavescope
```

Weave Scope is now available at: http://localhost:4040

NOTE: it may take a few seconds for weavescope to discover all of the nodes and pods.

## Make targets:

### `init`

Create the namespace, configmaps service account and hosts-disco service.

### `create-apps`

Creates hdfs, yarn and zeppelin apps.

### `port-forward`

Creates local port forwards for yarn and zeppelin.

### `dfsreport`

Gets the state of HDFS.

### `nn-shell`

Drops into a shell on the namenode

### `rm-shell`

Drops into a shell on the resource manager.

### `zeppelin-shell`

Drops into a shell on the zeppelin container.

## Shutting down

```
make clean
```

Stopping Weave Scope (if started)

```
kubectl delete ds weavescope-probe && kubectl delete rc,services weavescope-app
```

Shutdown the cluster

```
minikube stop
```

Or:

```
make stop-minikube
```
