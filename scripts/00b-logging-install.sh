#!/bin/bash
# This script requires the oc command being installed in your environment 
echo "Invoking script to install ElasticSearch..."
scripts/00x-elastic-install.sh 
echo "Waiting 120 seconds..."
sleep 120
echo "Installing Logging dependencies..."
    oc create -f resources/00d-logging-namespace.yaml
    oc create -f resources/00e-logging-operatorgroup.yaml
    oc create -f resources/00f-logging-subscription.yaml
echo "Waiting 60 seconds..."
sleep 60
echo "Deploying Logging instance..."
oc create -f resources/00g-logging-instance-odf.yaml
echo "Waiting 120 seconds..."
sleep 120
echo "Done!"