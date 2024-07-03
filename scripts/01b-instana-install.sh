#!/bin/bash
# This script requires the oc command being installed in your environment 
echo "ZONE_NAME is set to" $ZONE_NAME
echo "CLUSTER_NAME is set to" $CLUSTER_NAME
echo "INSTANA_APP_KEY is set to" $INSTANA_APP_KEY
echo "INSTANA_SVC_ENDPOINT is set to" $INSTANA_SVC_ENDPOINT
echo "INSTANA_SVC_PORT is set to" $INSTANA_SVC_PORT
read -p "Press <Enter> to execute script..."
echo "Installing Instana dependencies..."
oc new-project instana-agent
oc adm policy add-scc-to-user privileged -z instana-agent -n instana-agent

oc create -f resources/01f-instana-agent-subscription.yaml
echo "Waiting 60 seconds..."
sleep 60

        #########################
        # CREATE AGENT INSTANCE #
        #########################
        echo "Creating Instana Agent instance..."
        (echo "cat <<EOF" ; cat templates/template-instana-agent.yaml ;) | \
            ZONE_NAME=${ZONE_NAME} \
            CLUSTER_NAME=${CLUSTER_NAME} \
            INSTANA_APP_KEY=${INSTANA_APP_KEY} \
            INSTANA_SVC_ENDPOINT=${INSTANA_SVC_ENDPOINT} \
            INSTANA_SVC_PORT=${INSTANA_SVC_PORT} \
            sh > instana-agent.yaml
        oc create -f instana-agent.yaml
        rm -fr instana-agent.yaml
echo "Waiting 60 seconds..."
sleep 60
echo "Done!"