#!/bin/bash
echo "Building eMail Server Policy Configuration"
###################
# INPUT VARIABLES #
###################
CONFIG_NAME="ace-email-server-policy"
CONFIG_TYPE="policyproject"
CONFIG_NS="tools"
CONFIG_DESCRIPTION="Policy to configure default values for CP4I Demo"
##########################
# PREPARE CONFIG CONTENT #
##########################
echo "Packaging Policy..."
mkdir CP4IEMAIL && cp -a cp4i-ace-artifacts/CP4IEMAIL/. CP4IEMAIL/
zip -r CP4IEMAIL.zip CP4IEMAIL
CONFIG_CONTENT_BASE64=$(base64 -i -w 0 CP4IEMAIL.zip)
( echo "cat <<EOF" ; cat templates/template-ace-config-content.yaml ;) | \
    CONFIG_NAME=${CONFIG_NAME} \
    CONFIG_TYPE=${CONFIG_TYPE} \
    CONFIG_NS=${CONFIG_NS} \
    CONFIG_DESCRIPTION=${CONFIG_DESCRIPTION} \
    CONFIG_CONTENT_BASE64=${CONFIG_CONTENT_BASE64} \
    sh > ace-config-policy-email.yaml
########################
# CREATE CONFIGURATION #
########################
echo "Creating ACE Configuration..."
oc create -f ace-config-policy-email.yaml
oc -n tools label configuration ace-email-server-policy assembly.integration.ibm.com/tools.jgr-demo=true
echo "Cleaning up temp files..."
rm -rf CP4IEMAIL
rm -f CP4IEMAIL.zip
rm -f ace-config-policy-email.yaml
echo "eMail Server Policy Configuration has been created."