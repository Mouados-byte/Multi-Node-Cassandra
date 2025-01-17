#!/bin/bash
kubectl apply -f cassandra-service.yaml
kubectl apply -f local-volumes.yaml
kubectl apply -f cassandra-statefulset.yaml
kubectl get nodes
kubectl get svc cassandra
