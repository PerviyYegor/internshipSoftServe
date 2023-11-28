#!/bin/bash

helm repo add grafana https://grafana.github.io/helm-charts
helm install grafana grafana/grafana -f files/values.yml

kubectl get secret --namespace default grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo

kubectl expose service grafana --type=NodePort --target-port=3000 --name=grafana-np
minikube service grafana-np --url