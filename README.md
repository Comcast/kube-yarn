# YARN on Kubernetes

![Architecture](docs/k8s_yarn_architecture.png)

## Running locally

Use [`kid`](https://github.com/vyshane/kid) to start k8s cluster locally with [Docker Machine](https://www.docker.com/products/docker-toolbox)


```
kid up
```

The Canary Dashboard should be accessible at: http://docker.local:31999

NOTE: to get your docker machine to resolve to `docker.local` run this: `docker run -d --name avahi-docker --net host --restart always -e AVAHI_HOST=docker danisla/avahi:latest`

Run [Weave Scope](https://www.weave.works/docs/scope/0.15.0/installing/#k8s) to visualize and access pods in the cluster:

```
kubectl create -f 'https://scope.weave.works/launch/k8s/weavescope.yaml' --validate=false
kubectl port-forward $(kubectl get pod --selector=weavescope-component=weavescope-app -o jsonpath={.items..metadata.name}) 4040
```

Weave Scope is now available at: http://localhost:4040

### Shutting down

```
kid down
```

Stopping Weave Scope

```
kubectl delete ds weavescope-probe && kubectl delete rc,services weavescope-app
```
