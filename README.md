# Scalable multi-node Cassandra deployment on Kubernetes

This project demonstrates the deployment of a multi-node scalable Cassandra cluster on Kubernetes. Apache Cassandra is a massively scalable open source NoSQL database. Cassandra is perfect for managing large amounts of structured, semi-structured, and unstructured data.

![image](https://github.com/user-attachments/assets/58c683e2-f3f7-44d4-80f3-6fe7303c6992)

## Prerequisites

You'll need a Kubernetes cluster. For local development:
* Install [Minikube](https://kubernetes.io/docs/setup/minikube/) on your workstation

After installing Kubernetes ensure that you can access it by running:

```shell
$ kubectl version
```

## Create a Cassandra Cluster

### 1. Create a Cassandra Headless Service

Create a "headless" service for Cassandra cluster discovery:

```shell
$ kubectl create -f cassandra-service.yaml
service "cassandra" created
$ kubectl get svc cassandra
NAME        CLUSTER-IP   EXTERNAL-IP   PORT(S)    AGE
cassandra   None         <none>        9042/TCP   10s
```

### 2. Create Local Volumes

Create persistent volumes for Cassandra data:

```shell
$ kubectl create -f local-volumes.yaml
$ kubectl get pv
NAME               CAPACITY   ACCESSMODES   RECLAIMPOLICY   STATUS      CLAIM     STORAGECLASS   REASON    AGE
cassandra-data-1   1Gi        RWO           Recycle         Available                                      7s
cassandra-data-2   1Gi        RWO           Recycle         Available                                      7s
cassandra-data-3   1Gi        RWO           Recycle         Available                                      7s
```

### 3. Create a StatefulSet

Deploy Cassandra using StatefulSet:

```shell
$ kubectl create -f cassandra-statefulset.yaml
```

### 4. Validate the StatefulSet

Check your deployment:

```shell
$ kubectl get statefulsets
NAME        DESIRED   CURRENT   AGE
cassandra   1         1         2h
```

View the pods:

```shell
$ kubectl get pods -o wide
NAME          READY     STATUS    RESTARTS   AGE       IP              NODE
cassandra-0   1/1       Running   0          1m        172.xxx.xxx.xxx   169.xxx.xxx.xxx
```

Check Cassandra status:

```shell
$ kubectl exec -ti cassandra-0 -- nodetool status
```

### 5. Scale the StatefulSet

Scale your cluster:

```shell
$ kubectl scale --replicas=3 statefulset/cassandra
```

### 6. Using CQL

Access Cassandra:

```shell
kubectl exec -it cassandra-0 cqlsh
```

### 7. Testing the cluster
```
kubectl exec -it cassandra-0 -- nodetool status
Datacenter: DC1
===============
Status=Up/Down
|/ State=Normal/Leaving/Joining/Moving
--  Address      Load       Tokens       Owns (effective)  Host ID                               Rack
UN  10.244.0.17  90.41 KiB  256          100.0%            8101c20a-f11e-4ba2-9365-e00d6696239d  Rack1
```
```
kubectl exec -it cassandra-0 -- nodetool gossipinfo
/10.244.0.17
  generation:1737140813
  heartbeat:47
  STATUS:19:NORMAL,-1058145774692920768
  LOAD:23:92576.0
  SCHEMA:15:e84b6a60-24cf-30ca-9b58-452d92911703
  DC:9:DC1
  RACK:11:Rack1
  RELEASE_VERSION:4:3.11.17
  INTERNAL_IP:7:10.244.0.17
  RPC_ADDRESS:3:10.244.0.17
  NET_VERSION:1:11
  HOST_ID:2:8101c20a-f11e-4ba2-9365-e00d6696239d
  RPC_READY:32:true
  SSTABLE_VERSIONS:5:big-me
  TOKENS:18:<hidden>
/10.244.0.18
  generation:1737140822
  heartbeat:36
  STATUS:34:BOOT,-2441399008391811259
  LOAD:17:82714.0
  SCHEMA:19:e84b6a60-24cf-30ca-9b58-452d92911703
  DC:9:DC1
  RACK:11:Rack1
  RELEASE_VERSION:4:3.11.17
  INTERNAL_IP:7:10.244.0.18
  RPC_ADDRESS:3:10.244.0.18
  NET_VERSION:1:11
  HOST_ID:2:69c9fbe0-60e8-469f-bd65-83e551ce5f5c
  SSTABLE_VERSIONS:5:big-me
  TOKENS:33:<hidden>
/10.244.0.19
  generation:1737140827
  heartbeat:27
  LOAD:19:82740.0
  SCHEMA:16:e84b6a60-24cf-30ca-9b58-452d92911703
  DC:9:DC1
  RACK:11:Rack1
  RELEASE_VERSION:4:3.11.17
  INTERNAL_IP:7:10.244.0.19
  RPC_ADDRESS:3:10.244.0.19
  NET_VERSION:1:11
  HOST_ID:2:33b0ff5c-cc3e-41e9-a37c-ef4f8a2003f8
  SSTABLE_VERSIONS:5:big-me
  TOKENS: not present
```
```
kubectl exec -it cassandra-0 -- nodetool describecluster
Cluster Information:
        Name: Cassandra
        Snitch: org.apache.cassandra.locator.GossipingPropertyFileSnitch
        DynamicEndPointSnitch: enabled
        Partitioner: org.apache.cassandra.dht.Murmur3Partitioner
        Schema versions:
                e84b6a60-24cf-30ca-9b58-452d92911703: [10.244.0.17, 10.244.0.18]

                UNREACHABLE: [10.244.0.19]
```
## Troubleshooting

* Check logs: `kubectl logs <your-pod-name>`
* Delete PVC data: `kubectl delete pvc -l app=cassandra`
* Delete everything: `kubectl delete statefulset,pvc,pv,svc -l app=cassandra`
