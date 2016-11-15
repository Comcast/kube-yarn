FROM gcr.io/google_containers/hyperkube-amd64:v1.4.6

RUN apt-get update && apt-get install -y make jq && \
    cp /kubectl /usr/local/bin/kubectl && \
    mkdir -p /opt/kube-yarn && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ADD . /opt/kube-yarn/

WORKDIR /opt/kube-yarn

ENV KUBECONFIG /root/.kube/config

ENTRYPOINT ["make"]
