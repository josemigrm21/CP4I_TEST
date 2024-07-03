#!/bin/bash
# This script requires the oc command being installed in your environment
# This script requires the apic command being installed in your environment
if [ ! command -v oc &> /dev/null ]; then echo "oc could not be found"; exit 1; fi;
if [ ! command -v apic &> /dev/null ]; then echo "apic could not be found"; exit 1; fi;
if [ ! command -v jq &> /dev/null ]; then echo "jq could not be found"; exit 1; fi;
echo "Configuring Catalogs..."
###################
# INPUT VARIABLES #
###################
APIC_INST_NAME='apim-demo'
APIC_NAMESPACE='tools'
APIC_ORG='cp4i-demo-org'
######################
# SET APIC VARIABLES #
######################
APIC_MGMT_SERVER=$(oc get route "${APIC_INST_NAME}-mgmt-platform-api" -n $APIC_NAMESPACE -o jsonpath="{.spec.host}")
APIC_CATALOG='sandbox'
APIC_PORTAL_TYPE='drupal'
CATALOG_NAME="demo"
CATALOG_TITLE="Demo"
CATALOG_SUMMARY="Demo Catalog"
APIC_AVAILABILITY_ZONE='availability-zone-default'
#################
# LOGIN TO APIC #
#################
echo "Login to APIC with CP4I Admin User using SSO..."
apic login --server $APIC_MGMT_SERVER --sso --context provider
###########################################
# UPDATE SANDBOX CATALOG TO ENABLE PORTAL #
###########################################
echo "Getting Portal URL..."
APIC_PORTAL_URL=$(apic portal-services:list --server $APIC_MGMT_SERVER --scope org --org $APIC_ORG | awk '{print $4}')
echo $APIC_PORTAL_URL
echo "Getting Sandbox Catalog Settings..."
apic catalog-settings:get --server $APIC_MGMT_SERVER --org $APIC_ORG --catalog $APIC_CATALOG --format json
echo "Updating Catalog Settings File..."
jq --arg PORTAL_URL $APIC_PORTAL_URL \
   --arg APIC_PORTAL_TYPE $APIC_PORTAL_TYPE \
   '.portal.type=$APIC_PORTAL_TYPE |
   .portal.portal_service_url=$PORTAL_URL |
   del(.created_at, .updated_at)' \
   catalog-setting.json > catalog-setting-sandbox.json
echo "Enabling Portal in Catalog Sandbox..."
apic catalog-settings:update --server $APIC_MGMT_SERVER --org $APIC_ORG --catalog $APIC_CATALOG catalog-setting-sandbox.json
#########################################
# CREATE DEMO CATALOG AND ENABLE PORTAL #
#########################################
apic catalogs:get --server $APIC_MGMT_SERVER --org $APIC_ORG --format json $APIC_CATALOG
jq --arg CATALOG_NAME $CATALOG_NAME \
   --arg CATALOG_TITLE $CATALOG_TITLE \
   --arg CATALOG_SUMMARY "$CATALOG_SUMMARY" \
   '.name=$CATALOG_NAME |
   .title=$CATALOG_TITLE |
   .summary=$CATALOG_SUMMARY |
   del(.id, .created_at, .updated_at, .url)' \
   sandbox.json > demo.json
echo "Creating Demo Catalog..."
CATALOG_URL=$(apic catalogs:create --server $APIC_MGMT_SERVER --org $APIC_ORG demo.json | awk '{print $2}')
echo "Getting Demo Catalog Settings..."
rm -f catalog-setting.json
apic catalog-settings:get --server $APIC_MGMT_SERVER --org $APIC_ORG --catalog $CATALOG_NAME --format json
echo "Updating Catalog Settings File..."
jq --arg PORTAL_URL $APIC_PORTAL_URL \
   --arg APIC_PORTAL_TYPE $APIC_PORTAL_TYPE \
   '.portal.type=$APIC_PORTAL_TYPE |
   .portal.portal_service_url=$PORTAL_URL |
   del(.created_at, .updated_at)' \
   catalog-setting.json > catalog-setting-demo.json
echo "Enabling Portal in Catalog Demo..."
apic catalog-settings:update --server $APIC_MGMT_SERVER --org $APIC_ORG --catalog $CATALOG_NAME catalog-setting-demo.json
#################################################
# PUBLISH PRODUCT WITH REST API TO DEMO CATALOG #
#################################################
echo "Publishing Product with Rest API in Demo Catalog..."
apic products:publish --server $APIC_MGMT_SERVER --org $APIC_ORG --catalog $CATALOG_NAME resources/05-jgr-mqapi-product.yaml
####################################
# UPDATE CATALOGS WITH EEM GATEWAY #
####################################
if [ ! -z "$EEM_APIC_INT" ]
then
    echo "Updating Catalogs with EEM Gateway..."
    apic gateway-services:get --server $APIC_MGMT_SERVER --org $APIC_ORG --availability-zone $APIC_AVAILABILITY_ZONE --scope org --format json eem-gateway-service
    GATEWAY_SERVICE_NAME=$(jq -r '.name' "eem-gateway-service.json")
    GATEWAY_SERVICE_URL=$(jq -r '.url' "eem-gateway-service.json")
    GATEWAY_SERVICE_TYPE=$(jq -r '.gateway_service_type' "eem-gateway-service.json")
    ( echo "cat <<EOF" ; cat templates/template-apic-configured-gateway-service.yaml ;) | \
        GATEWAY_SERVICE_NAME=${GATEWAY_SERVICE_NAME} \
        GATEWAY_SERVICE_URL=${GATEWAY_SERVICE_URL} \
        GATEWAY_SERVICE_TYPE=${GATEWAY_SERVICE_TYPE} \
        sh > apic-configured-gateway-service.yaml
    echo "Catalog " $APIC_CATALOG
    apic configured-gateway-services:create --server $APIC_MGMT_SERVER --org $APIC_ORG --catalog $APIC_CATALOG --scope catalog apic-configured-gateway-service.yaml
    echo "Catalog " $CATALOG_NAME
    apic configured-gateway-services:create --server $APIC_MGMT_SERVER --org $APIC_ORG --catalog $CATALOG_NAME --scope catalog apic-configured-gateway-service.yaml
    #################################################
    # PUBLISH PRODUCT WITH ASYNCAPI TO DEMO CATALOG #
    #################################################
    echo "Publishing Product with AsyncAPI in Demo Catalog..."
    apic products:publish --server $APIC_MGMT_SERVER --org $APIC_ORG --catalog $CATALOG_NAME resources/06-jgr-asyncapi-product.yaml
    apic products:get --scope catalog --format json --output artifacts --server $APIC_MGMT_SERVER --org $APIC_ORG --catalog $CATALOG_NAME jgrasyncapi-product:1.0.0
fi
#######################################
echo "Cleaning up temp files..." 
rm -f catalog-setting.json
rm -f catalog-setting-sandbox.json
rm -f catalog-setting-demo.json
rm -f sandbox.json
rm -f demo.json
rm -f resources/jgrmqapi_1.2.0.yaml
rm -f resources/cp4i-es-demo-topic.yaml
rm -f artifacts/jgrasyncapi-product_1.0.0.json
rm -f eem-gateway-service.json
rm -f apic-configured-gateway-service.yaml
echo "Catalogs have been configured"    