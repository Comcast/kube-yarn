# Multi-node YARN in Docker

## Running single-node YARN

This will start HDFS and YARN in a container using the [SequenceIQ Hadoop Docker Image](https://github.com/sequenceiq/hadoop-docker) which contains their [Hadoop native libs build](https://github.com/sequenceiq/docker-hadoop-build)

```
docker run -it --rm -p 8088:8088 sequenceiq/hadoop-docker:2.7.0
```

## Running with Docker Compose

```
docker-compose up -d
docker-compose scale dn=2
```

TODO: scaling down doesn't unregister nodes in the resource manager. Need to figure out a way to properly decommission nodemanagers.


## NOTES:

Spark on Yarn requires HDFS to load distributed artifacts like the executor jar and sparkconf.

Running HDFS in Docker requires that all datanode hostnames are added to the `etc/hadoop/slaves` file.

Need to do some runtime introspection to set NM avail mem and vcpus and ports so node can be easily accessed from the RM UI.
