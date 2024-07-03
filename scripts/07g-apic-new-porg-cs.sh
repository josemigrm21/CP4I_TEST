#!/bin/bash
# This script requires the oc command being installed in your environment
# This script requires the apic command being installed in your environment
if [ ! command -v oc &> /dev/null ]; then echo "oc could not be found"; exit 1; fi;
if [ ! command -v apic &> /dev/null ]; then echo "apic could not be found"; exit 1; fi;
if [ -z "$CP4I_VER" ]; then echo "CP4I_VER not set, it must be provided on the command line."; exit 1; fi;
echo "CP4I_VER is set to" $CP4I_VER
read -p "Press <Enter> to execute script..."
echo "Creating new Provider Organization..."
###################
# INPUT VARIABLES #
###################
APIC_INST_NAME='apim-demo'
APIC_NAMESPACE='tools'
######################
# SET APIC VARIABLES #
######################
PORG_NAME='cp4i-demo-org'
PORG_TITLE='CP4I Demo Provider Org'
APIC_REALM='admin/default-idp-1'
APIC_ADMIN_USER='admin'
APIC_ADMIN_ORG='admin'
if [ "$CP4I_VER" = "2023.4" ]
then 
    APIC_CMC_USER='integration-admin'
    APIC_USER_REGISTRY='integration-keycloak'
else
    APIC_CMC_USER='admin'
    APIC_USER_REGISTRY='common-services'
fi
APIC_MGMT_SERVER=$(oc get route "${APIC_INST_NAME}-mgmt-platform-api" -n $APIC_NAMESPACE -o jsonpath="{.spec.host}")
APIC_ADMIN_PWD=$(oc get secret "${APIC_INST_NAME}-mgmt-admin-pass" -n $APIC_NAMESPACE -o jsonpath="{.data.password}"| base64 -d)
#################
# LOGIN TO APIC #
#################
echo "Login to APIC with CMC Admin User..."
apic login --server $APIC_MGMT_SERVER --realm $APIC_REALM -u $APIC_ADMIN_USER -p $APIC_ADMIN_PWD
###########################
# CREATE NEW PROVIDER ORG #
###########################
echo "Getting Values to Create Provider Organization..."
USER_URL=$(apic users:list --server $APIC_MGMT_SERVER --org $APIC_ADMIN_ORG --user-registry $APIC_USER_REGISTRY | awk -v user=$APIC_CMC_USER '$1 == user {print $4}')
echo "Preparing POrg File for user " $APIC_CMC_USER
( echo "cat <<EOF" ; cat templates/template-apic-provider-org.json ;) | \
    PORG_NAME=${PORG_NAME} \
    PORG_TITLE=${PORG_TITLE} \
    USER_URL=${USER_URL} \
    sh > provider-org.json
echo "Creating PORG for user " $APIC_CMC_USER
apic orgs:create --server $APIC_MGMT_SERVER provider-org.json
echo "Cleaning up temp files..."
rm -f provider-org.json
echo "Provider Organization has been created."