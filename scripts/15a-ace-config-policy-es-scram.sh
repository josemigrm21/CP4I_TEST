#!/bin/bash
echo "Building ES Policy Configuration"
###################
# INPUT VARIABLES #
###################
ES_INST_NAME='es-demo'
ES_NAMESPACE='tools'
CONFIG_NAME="ace-es-demo-scram-policy"
CONFIG_TYPE="policyproject"
CONFIG_NS="tools"
CONFIG_DESCRIPTION="Policy to connect to Demo Event Streams Cluster"
##########################
# PREPARE CONFIG CONTENT #
##########################
echo "Packaging Policy..."
mkdir CP4IESDEMOSCRAM && cp -a cp4i-ace-artifacts/CP4IESDEMOSCRAM/. CP4IESDEMOSCRAM/
#ES_BOOTSTRAP_SERVER=$(oc get eventstreams ${ES_INST_NAME} -n ${ES_NAMESPACE} -o=jsonpath='{range .status.kafkaListeners[*]}{.type} {.bootstrapServers}{"\n"}{end}' | awk '$1=="external" {print $2}')
ES_BOOTSTRAP_SERVER=$(oc get eventstreams ${ES_INST_NAME} -n ${ES_NAMESPACE} -o=jsonpath='{range .status.kafkaListeners[*]}{.name} {.bootstrapServers}{"\n"}{end}' | awk '$1=="external" {print $2}')
( echo "cat <<EOF" ; cat CP4IESDEMOSCRAM/es-demo.policyxml ;) | \
    ES_BOOTSTRAP_SERVER=${ES_BOOTSTRAP_SERVER} \
    sh > es-demo.policyxml
mv -f es-demo.policyxml CP4IESDEMOSCRAM/es-demo.policyxml
zip -r CP4IESDEMOSCRAM.zip CP4IESDEMOSCRAM
CONFIG_CONTENT_BASE64=$(base64 -i -w 0 CP4IESDEMOSCRAM.zip)
( echo "cat <<EOF" ; cat templates/template-ace-config-content.yaml ;) | \
    CONFIG_NAME=${CONFIG_NAME} \
    CONFIG_TYPE=${CONFIG_TYPE} \
    CONFIG_NS=${CONFIG_NS} \
    CONFIG_DESCRIPTION=${CONFIG_DESCRIPTION} \
    CONFIG_CONTENT_BASE64=${CONFIG_CONTENT_BASE64} \
    sh > ace-config-policy-es-scram.yaml
########################
# CREATE CONFIGURATION #
########################
echo "Creating ACE Configuration..."
oc create -f ace-config-policy-es-scram.yaml
oc -n tools label configuration ace-es-demo-scram-policy assembly.integration.ibm.com/tools.jgr-demo=true
#echo "Cleaning up temp files..."
rm -rf CP4IESDEMOSCRAM
rm -f CP4IESDEMOSCRAM.zip
rm -f ace-config-policy-es-scram.yaml
echo "ES Policy Configuration has been created."