# Copyright 2016 Comcast Cable Communications Management, LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

### Local cluster targets

MINIKUBE_MIN_MEM=8192
MINIKUBE_VM_NAME=minikubeVM
MINIKUBE_BIN=/usr/local/bin/minikube
XHYVE_BIN=/usr/local/bin/docker-machine-driver-xhyve

$(XHYVE_BIN):
	$(warning installing xhyve driver)
	curl -L https://github.com/zchee/docker-machine-driver-xhyve/releases/download/v0.2.2/docker-machine-driver-xhyve > /usr/local/bin/docker-machine-driver-xhyve
	chmod +x /usr/local/bin/docker-machine-driver-xhyve
	sudo chown root:wheel /usr/local/bin/docker-machine-driver-xhyve
	sudo chmod u+s /usr/local/bin/docker-machine-driver-xhyve

$(MINIKUBE_BIN):
	curl -f -L https://github.com/kubernetes/minikube/releases/download/v0.7.1/minikube-darwin-amd64 > /usr/local/bin/minikube
	chmod +x /usr/local/bin/minikube

minikube: $(MINIKUBE_BIN) $(XHYVE_BIN)
	@NCPU=$$(sysctl -n hw.ncpu) && if [ "$$(minikube status)" == "Does Not Exist" ]; then \
		$(MINIKUBE_BIN) start --vm-driver=xhyve --memory $(MINIKUBE_MIN_MEM) --cpus $$(sysctl -n hw.ncpu) ; \
	else \
		eval $$(jq -r '.Driver | to_entries[] | "\(.key)=\(.value)"' $(HOME)/.minikube/machines/$(MINIKUBE_VM_NAME)/config.json | egrep 'CPU|Memory' | xargs echo export ) ; \
		if [ "$$CPU" -ne "$$NCPU" ]; then echo "ERROR: minikube started with $$CPU cpus, expected $$NCPU, to fix, run: minikube delete && make minikube" ; exit 1 ; fi ; \
		if [ "$$Memory" -lt $(MINIKUBE_MIN_MEM) ]; then echo "ERROR: minikube started with $$Memory memory, expected >= $(MINIKUBE_MIN_MEM), to fix, run: minikube delete && make minikube" ; exit 1 ; fi ; \
		if [ "$$(minikube status)" != "Running" ];  then minikube start ; fi ; \
		echo "minikube is running" ; \
	fi

stop-minikube: $(MINIKUBE_BIN)
	minikube stop
