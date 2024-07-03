#!/bin/bash
# This script requires the oc command being installed in your environment 
echo "Installing Tracing dependencies..."
oc create -f resources/01a-tracing-platform-namespace.yaml
oc create -f resources/01b-tracing-platform-operatorgroup.yaml
oc create -f resources/01c-tracing-platform-subscription.yaml
echo "Waiting 90 seconds..."
sleep 90
oc create -f resources/01d-tracing-data-collection-subscription.yaml
echo "Waiting 60 seconds..."
sleep 60
oc create -f resources/01e-tracing-instance.yaml
echo "Waiting 60 seconds..."
sleep 60
echo "Done!"