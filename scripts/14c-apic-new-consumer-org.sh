#!/bin/bash
# This script requires the oc command being installed in your environment
# This script requires the apic command being installed in your environment
# And before running the script you need to set an environment variable call "APPDEV_PWD" with the user password, i.e. using this command: "export APPDEV_PWD=my-pwd"
if [ ! command -v oc &> /dev/null ]; then echo "oc could not be found"; exit 1; fi;
if [ ! command -v apic &> /dev/null ]; then echo "apic could not be found"; exit 1; fi;
if [ -z "$APPDEV_PWD" ]; then echo "APPDEV_PWD not set, it must be provided on the command line."; exit 1; fi;
echo "APPDEV_PWD is set to" $APPDEV_PWD
read -p "Press <Enter> to execute script..."
echo "Creating Consumer Organization..."
###################
# INPUT VARIABLES #
###################
APIC_INST_NAME='apim-demo'
APIC_NAMESPACE='tools'
######################
# SET APIC VARIABLES #
######################
APIC_ORG='cp4i-demo-org'
CATALOG_NAME="demo"
CONSUMER_ORG_NAME='AppDevOrg'
APIC_MGMT_SERVER=$(oc get route "${APIC_INST_NAME}-mgmt-platform-api" -n $APIC_NAMESPACE -o jsonpath="{.spec.host}")
#################
# LOGIN TO APIC #
#################
echo "Login to APIC with CP4I Admin User using SSO..."
apic login --server $APIC_MGMT_SERVER --sso --context provider
PORG_URL=$(apic orgs:list --server $APIC_MGMT_SERVER | awk -v porgname="${APIC_ORG}" '$1 == porgname {print $4}')
USER_REGISTRY_URL=$(apic user-registries:list --server $APIC_MGMT_SERVER --org $APIC_ORG | awk -v catname="${CATALOG_NAME}-catalog" '$1 == catname {print $2}')
CATALOG_URL=$(apic catalogs:list --server $APIC_MGMT_SERVER --org $APIC_ORG | awk -v catname="${CATALOG_NAME}" '$1 == catname {print $2}')
#######################################
# CREATE CONSUMER ORG IN DEMO CATALOG #
#######################################
echo "Preparing Consumer Org User File"
( echo "cat <<EOF" ; cat templates/template-apic-consumer-org-user.json ;) | \
    CATALOG_NAME=${CATALOG_NAME} \
    APPDEV_PWD=${APPDEV_PWD} \
    PORG_URL=${PORG_URL} \
    USER_REGISTRY_URL=${USER_REGISTRY_URL} \
    sh > consumer-org-user.json
echo "Creating Consumer Org User"
OWNER_URL=$(apic users:create --server $APIC_MGMT_SERVER --org $APIC_ORG --user-registry ${CATALOG_NAME}-catalog consumer-org-user.json | awk '{print $4}')
echo "Preparing Consumer Org File"
( echo "cat <<EOF" ; cat templates/template-apic-consumer-org.json ;) | \
    ORG_NAME=${CONSUMER_ORG_NAME} \
    OWNER_URL=${OWNER_URL} \
    PORG_URL=${PORG_URL} \
    CATALOG_URL=${CATALOG_URL} \
    sh > consumer-org.json
echo "Creating Consumer Org..."
apic consumer-orgs:create --server $APIC_MGMT_SERVER --org $APIC_ORG --catalog $CATALOG_NAME consumer-org.json
#######################################
echo "Cleaning up temp files..." 
rm -f consumer-org-user.json
rm -f consumer-org.json
echo "Consumer Organization has been created."    