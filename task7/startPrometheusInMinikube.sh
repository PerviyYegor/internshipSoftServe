#!/bin/bash

chmod +x ./prometheusConfScript.sh
./prometheusConfScript.sh
minikube start --driver=docker
#Wait...

minikube cp files/* /tmp
kubectl apply -f main.yml

#wait until pod will be ready. You can check with 'execute kubectl get pods'
minikube service prometheus-service --url