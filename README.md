# YARN on Kubernetes

![Architecture](docs/k8s_yarn_architecture.png)

#### [Initial Design Document (Google Docs)](https://docs.google.com/document/d/1ZoKLWkHiZZPP-394aUTIOE9R7Vx88pgOC8NE0hkVn24/edit?usp=sharing)

## Running locally

This repo uses [`kubernetes-anywhere`](https://github.com/kubernetes/kubernetes-anywhere) to start k8s cluster locally with [Docker Machine](https://www.docker.com/products/docker-toolbox)

The [`Makefile`](./Makefile) contains targets for starting the cluster and helper targets for `kubectl` to apply the K8S manifests and interact with the pods.

```
make start-k8s
```

OPTIONAL: to get your docker machine to resolve to `docker.local` run this: `docker run -d --name avahi-docker --net host --restart always -e AVAHI_HOST=docker danisla/avahi:latest`

Start the yarn cluster:

```
make
```

### Using Weave Scope (Optional)

Run [Weave Scope](https://www.weave.works/docs/scope/0.15.0/installing/#k8s) to visualize and access pods in the cluster:

```
kubectl create -f 'https://scope.weave.works/launch/k8s/weavescope.yaml' --validate=false
kubectl port-forward $(kubectl get pod --selector=weavescope-component=weavescope-app -o jsonpath={.items..metadata.name}) 4040
```

Weave Scope is now available at: http://localhost:4040

### Shutting down

```
make clean
```

Stopping Weave Scope (if started)

```
kubectl delete ds weavescope-probe && kubectl delete rc,services weavescope-app
```

Shutdown the cluster

```
make stop-k8s
```
