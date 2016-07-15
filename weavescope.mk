### Weave Scope
create-weavescope:
	kubectl create -f 'https://scope.weave.works/launch/k8s/weavescope.yaml' --validate=false
	@while [[ -z `kubectl get pod --selector=weavescope-component=weavescope-app -o json | jq 'select(.items[].status.phase=="Running") | true'` ]]; do echo "Waiting for weavescope pod" ; sleep 2; done
	make weavescope-pf

delete-weavescope: delete-weavescope-pf
	-kubectl delete -f 'https://scope.weave.works/launch/k8s/weavescope.yaml'

get-weavescope-pod:
	$(eval WEAVESCOPE_POD := $(shell kubectl --namespace default get pod --selector=weavescope-component=weavescope-app -o jsonpath={.items..metadata.name}))
	echo $(WEAVESCOPE_POD)

weavescope-pf: get-weavescope-pod
	kubectl --namespace default port-forward $(WEAVESCOPE_POD) 4040 2>/dev/null &
