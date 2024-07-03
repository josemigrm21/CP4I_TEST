#!/bin/bash
echo "Installing ElasticSearch dependencies..."
oc create -f resources/00a-elasticsearch-namespace.yaml
oc create -f resources/00b-elasticsearch-operatorgroup.yaml
oc create -f resources/00c-elasticsearch-subscription.yaml
echo "Elastic install ended."