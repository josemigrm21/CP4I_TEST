#!/bin/bash
# This script requires the oc command being installed in your environment
# This script requires the apic command being installed in your environment
if [ ! command -v oc &> /dev/null ]; then echo "oc could not be found"; exit 1; fi;
if [ ! command -v apic &> /dev/null ]; then echo "apic could not be found"; exit 1; fi;
if [ -z "$CP4I_VER" ]; then echo "CP4I_VER not set, it must be provided on the command line."; exit 1; fi;
echo "CP4I_VER is set to" $CP4I_VER
read -p "Press <Enter> to execute script..."
echo "Publising APIs in Draft mode..."
###################
# INPUT VARIABLES #
###################
APIC_INST_NAME='apim-demo'
APIC_NAMESPACE='tools'
APIC_ORG='cp4i-demo-org'
ES_INST_NAME='es-demo'
ES_NAMESPACE='tools'
ES_USER_ID='ace-user'
######################
# SET APIC VARIABLES #
######################
APIC_MGMT_SERVER=$(oc get route "${APIC_INST_NAME}-mgmt-platform-api" -n $APIC_NAMESPACE -o jsonpath="{.spec.host}")
#ES_BOOTSTRAP_SERVER=$(oc get eventstreams ${ES_INST_NAME} -n ${ES_NAMESPACE} -o=jsonpath='{range .status.kafkaListeners[*]}{.type} {.bootstrapServers}{"\n"}{end}' | awk '$1=="external" {print $2}')
ES_BOOTSTRAP_SERVER=$(oc get eventstreams ${ES_INST_NAME} -n ${ES_NAMESPACE} -o=jsonpath='{range .status.kafkaListeners[*]}{.name} {.bootstrapServers}{"\n"}{end}' | awk '$1=="external" {print $2}')
oc extract secret/${ES_USER_ID} -n ${ES_NAMESPACE} --keys=password
ES_USER_PWD=`cat password`
oc extract secret/${ES_INST_NAME}-cluster-ca-cert -n ${ES_NAMESPACE} --keys=ca.crt
ES_CA_CERT_PEM=`awk '{print "            "$0}' ca.crt`
GUUID=$(uuidgen | awk '{print tolower($0)}') 
#################
# LOGIN TO APIC #
#################
echo "Login to APIC with CP4I Admin User using SSO..."
apic login --server $APIC_MGMT_SERVER --sso --context provider
##########################################
# PUBLISH NEW APIS AND PRODUCTS TO DRAFT #
##########################################
# REST API
echo "Getting Values to Publish REST API..."
case "$CP4I_VER" in
    "2022.2")
        TARGET_URL=$(oc get integrationserver jgr-designer-sfleads -n tools -o jsonpath='{.status.endpoints[0].uri}')'/SFLeads/lead'
        PREMIUM_URL=$(oc get integrationserver jgr-mqapi-prem -n tools -o jsonpath='{.status.endpoints[0].uri}')
        DEFAULT_URL=$(oc get integrationserver jgr-mqapi-dflt -n tools -o jsonpath='{.status.endpoints[0].uri}')
        ;;
    "2022.4" | "2023.2" | "2023.4")
        TARGET_URL=$(oc get integrationruntime jgr-designer-sfleads -n tools -o jsonpath='{.status.endpoints[0].uri}')'/SFLeads/lead'
        PREMIUM_URL=$(oc get integrationruntime jgr-mqapi-prem -n tools -o jsonpath='{.status.endpoints[0].uri}')
        DEFAULT_URL=$(oc get integrationruntime jgr-mqapi-dflt -n tools -o jsonpath='{.status.endpoints[0].uri}')
        ;;
esac
echo "Preparing REST API File..."
( echo "cat <<EOF" ; cat templates/template-apic-api-def-jgrmqapiv2.yaml ;) | \
    TARGET_URL=${TARGET_URL} \
    PREMIUM_URL=${PREMIUM_URL} \
    DEFAULT_URL=${DEFAULT_URL} \
    MSG_BODY_VAL='$(message.body)' \
    INVOKE_URL_VAL1='$(target-url)' \
    INVOKE_URL_VAL2='$(default-url)$(my-path)' \
    INVOKE_URL_VAL3='$(premium-url)$(my-path)' \
    ref='$ref' \
    sh > resources/jgrmqapi_1.2.0.yaml
echo "Publishing RES API and Product in Draft mode..."
apic draft-products:create --server $APIC_MGMT_SERVER --org $APIC_ORG resources/05-jgr-mqapi-product.yaml
# AsyncAPI
if [ ! -z "$EEM_APIC_INT" ]
then
    #( echo "cat <<EOF" ; cat templates/template-apic-api-def-asyncapi.yaml ;) | \
    #    ES_BOOTSTRAP_SERVER=${ES_BOOTSTRAP_SERVER} \
    #    ES_USER_ID=${ES_USER_ID} \
    #    ES_USER_PWD=${ES_USER_PWD} \
    #    ES_CA_CERT_PEM=${ES_CA_CERT_PEM} \
    #    GUUID=${GUUID} \
    #    BOOTSTRAP_VAL='$(bootstrapServerAddress)' \
    #    sh > resources/jgrasyncapi_1.0.0.yaml
    cp artifacts/cp4i-es-demo-topic.yaml resources/
    echo "Publishing AsyncAPI and Product in Draft mode..."
    apic draft-products:create --server $APIC_MGMT_SERVER --org $APIC_ORG resources/06-jgr-asyncapi-product.yaml
fi
#######################################
echo "Cleaning up temp files..." 
rm -f password
rm -f ca.crt
echo "APIs have been published to Drafts" 