# Ello - Cassandra

## Setup

I am using https://github.com/pcmanus/ccm to make it easier to work with cassandra locally.  I would also go ahead and install cassandra from homebrew.

### Create your test cluster
```bash
ccm create ello-test -v 2.1.2 -n 3
```

### Start/Verify
```bash
ccm start
ccm status 
```
This should show 3 nodes with UP status. 

You can now run this to create your keyspace/table(s):

```bash
bundle exec rake cas[schema/schema_streams.cql]
```

You can now connect with _cqlsh_ and play around with your cluster.

### Stop

```bash
ccm stop
```

### Troubleshooting

- CCM won't install and start correctly:  I've had to download cassandra from source and use --install-path at times to get things working right.
- Sometimes, Cassandra likes to get all wierd and hung up on things:  Occasionally, it's necessary to kill the java process(es) for Cassandra.  This is due to how we're running it locally, more than a problem that you'd see in production.  
- You may need to run the ccm_alias.sh command prior to starting the cluster as a result of ccm only working on localhost.  This will add the loopback aliases needed.

### Stress testing


```bash
 <CASSANDRA_HOME>/tools/bin/cassandra-stress user profile=../ello-cas/schema/ello_stress.yaml ops\(insert=1,singlepost=1,timeline=2\)
```

### Run specs

The tests do assume you have a running cassandra instance for now.  So ccm start and verify with ccm status that you're up, then 

```bash
bundle exec rake spec
```
