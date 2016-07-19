# Benchmarking the hadoop cluster.

Resources:

- http://www.michael-noll.com/blog/2011/04/09/benchmarking-and-stress-testing-an-hadoop-cluster-with-terasort-testdfsio-nnbench-mrbench/
- https://discuss.zendesk.com/hc/en-us/articles/200864057-Running-DFSIO-MapReduce-benchmark-test
- http://blog.octo.com/en/hadoop-in-my-it-department-benchmark-your-cluster/

## Testing hadoop in Zeppelin

> Make sure to set `shell.command.timeout.millisecs` to something like 10 minutes (600000), default is 60s.

Running the `TestDFSIO` program from Zeppelin notebook:

```
%sh
/usr/hadoop-2.6.3/bin/hadoop jar /usr/hadoop-2.6.3/share/hadoop/mapreduce/hadoop-mapreduce-client-jobclient-2.6.3-tests.jar TestDFSIO -write -nrFiles 5 -fileSize 1GB -resFile /tmp/TestDFSIOwrite.txt
```

From yarn-nm container:

```
/usr/local/hadoop/bin/hadoop jar /usr/local/hadoop/share/hadoop/mapreduce/hadoop-mapreduce-client-jobclient-2.6.0-tests.jar TestDFSIO -write -nrFiles 5 -fileSize 128MB -resFile /tmp/TestDFSIOwrite.txt
```
