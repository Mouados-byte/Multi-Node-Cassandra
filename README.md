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

## Troubleshooting

* Check logs: `kubectl logs <your-pod-name>`
* Delete PVC data: `kubectl delete pvc -l app=cassandra`
* Delete everything: `kubectl delete statefulset,pvc,pv,svc -l app=cassandra`
