# CouchDiscover

![docker automated build](https://img.shields.io/docker/automated/callforamerica/couchdiscover.svg) ![docker pulls](https://img.shields.io/docker/pulls/callforamerica/couchdiscover.svg)


## Maintainer

Joe Black <joe@valuphone.com>


## Introduction

Utilizes the Kubernetes and CouchDB 2.0 clustering API's for automating the process of creating a CouchDB 2.0 Cluster. The reqirements here vary significantly compared to the predecessor BigCouch.

This module has an entrypoint stub called `couchdiscover` that will be created upon installation with setuptools.

This tool is meant to be used in a kubernetes cluster as a sidecar container.


### Environment variables used by couchdiscover:

#### `couchdb` container:
* `COUCHDB_ADMIN_USER`: username to use when enabling the node, required.
* `COUCHDB_ADMIN_PASS`: password to use when enabling the node, required.
* `ERLANG_COOKIE`: cookie value to use as the `.erlang.cookie`, not required, fails back to insecure cookie value when not set.
* `COUCHDB_CLUSTER_SIZE`: not required, overrides the value of `spec.replicas` in the statefulset, should rarely be necessary to set. Don't set unless you know what you're doing.

#### `couchdiscover` container:
* `LOG_LEVEL`: logging level to output container logs for.  Defaults to `INFO`, most logs are either INFO or WARNING level.


## How information is discovered

In order to best use something that is essentially "zero configuration," it helps to understand how the necessary information is obtained from the environment and api's. 

1. Initially a great deal of information is obtained by grabbing the hostname of the container that's part of a statefulset and parsing it.  This is how the namespace is determined, how hostnames are calculated later, the name of the statefulset to look for in the api, the name of the headless service, the node name, the index, whether a node is master or not, etc.

2. The kubernetes api is used to grab the statefulset and entrypoint objects. The entrypoint object is parsed to obtain the `hosts` list and the statefulset is parsed for the ports. After that the environment for the statefulset spec is resolved, fetching any externally referenced configmaps or secrets that are necessary.  Credentials are resolved by looking through the environment for the keys: `COUCHDB_ADMIN_USER`, `COUCHDB_ADMIN_PASS`.  Finally the expected cluster size is set to the number of replicas in the fetched statefulset.  You can override this by setting `COUCHDB_CLUSTER_SIZE` on the couchdb container though it should be completely unnecessary for most use cases.


## Main logic

The main logic is performed in the `manage` module's `ClusterManager` object's `run` method.  I think most of it is relatively straighforward.

```python
# couchdiscover.manage.ClusterManager
def run(self):
    """Main logic here, this is where we begin once all environment
    information has been retrieved."""
    log.info('Starting couchdiscover: %s', self.couch)
    if self.couch.disabled:
        log.info('Cluster disabled, enabling')
        self.couch.enable()
    elif self.couch.finished:
        log.info('Cluster already finished')
        self.sleep_forever()

    if self.env.first_node:
        log.info("Looks like I'm the first node")
        if self.env.single_node_cluster:
            log.info('Single node cluster detected')
            self.couch.finish()
    else:
        log.info("Looks like I'm not the first node")
        self.couch.add_to_master()
        if self.env.last_node:
            log.info("Looks like I'm the last node")
            self.couch.finish()
        else:
            log.info("Looks like I'm not the last node")
    self.sleep_forever()
```
