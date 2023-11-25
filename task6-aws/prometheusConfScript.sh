#!/bin/bash

wordpressTargets=$(cat ../task3-aws/ip.txt)
dockerHostTargets=$(cat ../task4-aws/ip.txt)

sed -e "s/REPLACE_DOCKER_HOST_TARGETS/$dockerHostTargets/" \
    -e "s/REPLACE_WORDPRESS_TARGETS/$wordpressTargets/" \
    prometheus-template.yml > ./VMPart/files/prometheus.yml
