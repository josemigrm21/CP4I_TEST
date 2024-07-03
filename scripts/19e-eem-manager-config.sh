#!/bin/bash
# This script requires the oc and jq commands to be installed in your environment
# And before running the script you need to set an environment variable call "EEM_TOKEN" with the corresponding token, i.e. using this command:
# "export EEM_TOKEN=my-eem-token"
if [ ! command -v oc &> /dev/null ]; then echo "oc could not be found"; exit 1; fi;
if [ ! command -v jq &> /dev/null ]; then echo "jq could not be found"; exit 1; fi;
if [ -z "$EEM_TOKEN" ]; then echo "EEM_TOKEN not set, it must be provided on the command line."; exit 1; fi;
echo "Event Endpoint Manager Configuration..."
###################
# INPUT VARIABLES #
###################
EEM_INST_NAME='eem-demo-mgr'
EEM_NAMESPACE='tools'
ES_INST_NAME='es-demo'
ES_NAMESPACE='tools'
##########################
# PREPARE CONFIG CONTENT #
##########################
EEM_API=$(oc get route -n $EEM_NAMESPACE ${EEM_INST_NAME}-ibm-eem-admin -ojsonpath='https://{.spec.host}')
echo "EEM_API:"$EEM_API
ES_BOOTSTRAP_SERVER=$(oc get eventstreams ${ES_INST_NAME} -n ${ES_NAMESPACE} -o=jsonpath='{range .status.kafkaListeners[*]}{.name} {.bootstrapServers}{"\n"}{end}' | awk '$1=="authsslsvc" {print $2}')
ES_BOOTSTRAP_SERVER=$(echo ${ES_BOOTSTRAP_SERVER%:*})
#ES_CERTIFICATE=$(oc get eventstreams $ES_INST_NAME -n $ES_NAMESPACE -o jsonpath='{.status.kafkaListeners[?(@.name=="authsslsvc")].certificates[0]}')
#ES_CERTIFICATE=${ES_CERTIFICATE//$'\n'/\\\\n}
oc extract secret/${ES_INST_NAME}-cluster-ca-cert -n ${ES_NAMESPACE} --keys=ca.crt
ES_CERTIFICATE=$(awk 'NF {sub(/\r/, ""); printf "%s\\n",$0;}' ca.crt)
#echo $ES_CERTIFICATE
#printf "%s\\n" "$ES_CERTIFICATE"
ES_PASSWORD=$(oc get secret eem-user -n $ES_NAMESPACE -ojsonpath='{.data.password}' | base64 -d)
( echo "cat <<EOF" ; cat templates/template-eem-es-cluster.json ;) | \
    ES_BOOTSTRAP_SERVER=${ES_BOOTSTRAP_SERVER} \
    ES_CERTIFICATE=${ES_CERTIFICATE} \
    ES_PASSWORD=${ES_PASSWORD} \
    sh > eem-es-cluster.json
curl -X POST -s -k \
     --dump-header eem-api-header \
     -H 'Accept: application/json' \
     -H 'Content-Type: application/json' \
     -H "Authorization: Bearer $EEM_TOKEN" \
     --data @eem-es-cluster.json \
     --output eem-response-data.json \
     --write-out '%{response_code}' \
     $EEM_API/eem/clusters
clusterId=$(jq .id eem-response-data.json)
echo "Cluster ID is:"$clusterId
topics=("CANCELLATIONS" "CUSTOMERS.NEW" "DOOR.BADGEIN" "ORDERS.NEW" "SENSOR.READINGS" "STOCK.MOVEMENT" "cp4i-es-demo-topic")
for topic in "${topics[@]}"
do
     curl -X POST -s -k \
          --dump-header eem-api-header \
          -H 'Accept: application/json' \
          -H 'Content-Type: application/json' \
          -H "Authorization: Bearer $EEM_TOKEN" \
          --data "$(cat templates/template-eem-eventsource-$topic.json | jq ".clusterId |= ${clusterId}")" \
          --output eem-response-data.json \
          --write-out '%{response_code}' \
          $EEM_API/eem/eventsources
     eventSourceId=$(jq .id eem-response-data.json)

     curl -X POST -s -k \
          --dump-header eem-api-header \
          -H 'Accept: application/json' \
          -H 'Content-Type: application/json' \
          -H "Authorization: Bearer $EEM_TOKEN" \
          --data "$(cat templates/template-eem-option-$topic.json | jq ".eventSourceId |= ${eventSourceId}")" \
          --output eem-response-data.json \
          --write-out '%{response_code}' \
          $EEM_API/eem/options
     asyncapiOptionId=$(jq -r .id eem-response-data.json)

     if [ ! -z $EEM_APIC_INT ]
     then
          echo "Getting AsyncAPI for APIC..."
          curl -X GET -s -k \
               --dump-header eem-api-header \
               -H 'Accept: application/yaml' \
               -H 'Content-Type: application/json' \
               -H "Authorization: Bearer $EEM_TOKEN" \
               --output artifacts/$topic.yaml \
               --write-out '%{response_code}' \
               $EEM_API/eem/options/${asyncapiOptionId}/apicasyncapi
     fi

done
echo "Cleaning up temp files..."
rm -f ca.crt
rm -f eem-api-header
rm -f eem-es-cluster.json
rm -f eem-response-data.json
echo "Event Endpoint Manager has been configured."