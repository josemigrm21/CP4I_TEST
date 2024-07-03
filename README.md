# Cloud Pak for Integration BootCamp

## Prerequisites
> [!IMPORTANT]
> This tools need to be installed in order to execute the workshop
- Ubuntu Linux 22.x or higher
- Internet Browser Firefox or Google Chrome
- SSH Server
```
sudo apt install ssh
```
- GIT Client
```
sudo apt install git
```
- Curl command
```
sudo apt install curl
```
- Openshift command line

   You can download it from here [openshift-client](https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/ocp/4.14.21/openshift-client-linux-4.14.21.tar.gz).
- openssl
- [jq](https://stedolan.github.io/jq/)
- [yq](https://github.com/mikefarah/yq/releases/download/v4.43.1/yq_linux_amd64)
- [apic cli](https://github.com/fxnaranjo/cp4i-bootcamp/blob/main/apic/toolkit-linux.tgz) (rename the binary as 'apic')
- keytool
```
sudo apt install openjdk-17-jre-headless
```
You also need an account in the folllowing email service to configure APIC:

- [mailtrap](https://mailtrap.io/)

---

<details>
<summary>
Openshift Clusters Credentials
</summary>
Team 1

```
  * Cluster URL: https://console-openshift-console.apps.666302e8cb95b2001d2ea80c.cloud.techzone.ibm.com
  * Username: kubeadmin
  * Password: VPQjt-wppTM-aLXtu-p2wup
```
Team 2

```
  * Cluster URL: https://console-openshift-console.apps.6667444659a2e3001e23532d.cloud.techzone.ibm.com/
  * Username: kubeadmin
  * Password: uMJ2x-fLNc7-ZhZZk-3kR5P
```

Team 3
```
  * Cluster URL: https://console-openshift-console.apps.665f9412115cb2001e6d7ddd.cloud.techzone.ibm.com
  * Username: kubeadmin
  * Password: E5nwM-sD3JZ-JpXya-XbKLU
```
Team 4
```
  * Cluster URL: https://console-openshift-console.apps.665f9509aeb07d001e8e460a.cloud.techzone.ibm.com
  * Username: kubeadmin
  * Password: xYGJ5-ymuu8-b3DGG-cKrt6
```
Team 5
```
  * Cluster URL: https://console-openshift-console.apps.66675fd22a1f01001e5c541b.cloud.techzone.ibm.com
  * Username: kubeadmin
  * Password: i4Zub-WmPKG-Huqzz-kosg7
```
Team 6
```
  * Cluster URL: https://console-openshift-console.apps.66675ef82a1f01001e5c5419.cloud.techzone.ibm.com
  * Username: kubeadmin
  * Password: HYeqf-wofMr-oKJyC-RZXTa
```

</details>


## Components Installation



<details>
<summary>
Get the scripts and resources:
</summary>

1. Clone the repository:
   ```
   git clone https://github.com/fxnaranjo/cp4i-bootcamp
   ```
</details>
&nbsp; 

<details>
<summary>
Set environment variables:
</summary>

1. Set CP4I version:
   ```
   export CP4I_VER=2023.4
   ```
2. Set the OCP type based on the storage classes in your cluster:
   ```
   export OCP_TYPE=ODF
   ```
3. Configure mail server Credentials
   ```
   export MAILTRAP_USER=<my-mailtrap-user>
   export MAILTRAP_PWD=<my-mailtrap-pwd>
   ```
</details>
&nbsp; 

> [!IMPORTANT]
> You must be logged in to the cluster before executing the following commands

<details>
<summary>
Set a default storage class for your cluster:
</summary>

1. The OCP cluster was provisioned Tech Zone use the following script to set the proper default storage class:
   ```
   scripts/99-odf-tkz-set-scs.sh
   ```
</details>
&nbsp; 

<details>
<summary>
Openshift Login:
</summary>  

1. Run script:
   ```
   scripts/00b-logging-install.sh
   ```
   Confirm installation completed successfully, you can run the following commands:
   ```
   oc get csv -n openshift-logging
   oc get pods -n openshift-logging
   ```
   You should receive a response like this for each command respectively.
   ```
   NAME                            DISPLAY                            VERSION   REPLACES   PHASE
   cluster-logging.v5.6.1          Red Hat OpenShift Logging          5.6.1                Succeeded
   elasticsearch-operator.v5.6.1   OpenShift Elasticsearch Operator   5.6.1                Succeeded
   ```

   ```
   NAME                                            READY   STATUS      RESTARTS   AGE
   cluster-logging-operator-756b4c48cc-lhkzs       1/1     Running     0          6m41s
   collector-njm62                                 2/2     Running     0          5m36s
   collector-nxpmd                                 2/2     Running     0          5m36s
   collector-xjl96                                 2/2     Running     0          5m36s
   collector-xsv6b                                 2/2     Running     0          5m36s
   collector-z9k9l                                 2/2     Running     0          5m36s
   elasticsearch-cdm-dxgp4gmf-1-577dc997c-sk7kg    2/2     Running     0          5m36s
   elasticsearch-cdm-dxgp4gmf-2-5f5d564466-cgk6x   2/2     Running     0          5m35s
   elasticsearch-cdm-dxgp4gmf-3-8695d6658c-lxblf   2/2     Running     0          5m33s
   elasticsearch-im-app-27947625-m6qd9             0/1     Completed   0          2m58s
   elasticsearch-im-audit-27947625-ht4jj           0/1     Completed   0          2m58s
   elasticsearch-im-infra-27947625-r9j8c           0/1     Completed   0          2m58s
   kibana-746f699cc-72qfk                          2/2     Running     0          5m34s
   ```
</details>
&nbsp; 

<details>
<summary>
Install Instana and prerequisites:
</summary>

1. Deploy prerequisites runnning script:
   ```
   scripts/01a-tracing-install.sh
   ```
   To confirm the installation completed successfully you can run the following commands:
   ```
   oc get csv -n openshift-distributed-tracing
   oc get jaeger -n openshift-distributed-tracing
   ```
   You should receive a response like this for each command respectively.
   ```
   NAME                               DISPLAY                                                 VERSION    REPLACES                           PHASE
   elasticsearch-operator.v5.6.1      OpenShift Elasticsearch Operator                        5.6.1                                         Succeeded
   jaeger-operator.v1.39.0-3          Red Hat OpenShift distributed tracing platform          1.39.0-3   jaeger-operator.v1.34.1-5          Succeeded
   opentelemetry-operator.v0.63.1-4   Red Hat OpenShift distributed tracing data collection   0.63.1-4   opentelemetry-operator.v0.60.0-2   Succeeded
   ```

   ```
   NAME                         STATUS    VERSION   STRATEGY   STORAGE   AGE
   jaeger-all-in-one-inmemory   Running   1.39.0    allinone   memory    18m
   ```
2. Set environment variables:
   ```
   export ZONE_NAME=BOOTCAMP-ZONE
   export CLUSTER_NAME=<my-cluster-name>
   export INSTANA_APP_KEY=ORiJrirMTj6PiA67APP16g
   export INSTANA_SVC_ENDPOINT=ingress-coral-saas.instana.io
   export INSTANA_SVC_PORT=443
   ```
3. Install Instana running script:
   ```
   scripts/01b-instana-install.sh
   ```
   To confirm the installation completed successfully you can run the following commands:
   ```
   oc get csv -n instana-agent
   oc get pods -n instana-agent
   ```
   You should receive a response like this for each command respectively.
   ```
   NAME                               DISPLAY                                                 VERSION    REPLACES                           PHASE
   cert-manager.v1.11.0               cert-manager                                            1.11.0     cert-manager.v1.10.2               Succeeded
   elasticsearch-operator.v5.6.2      OpenShift Elasticsearch Operator                        5.6.2      elasticsearch-operator.v5.6.1      Succeeded
   instana-agent-operator.v2.0.9      Instana Agent Operator                                  2.0.9      instana-agent-operator.v2.0.8      Succeeded
   jaeger-operator.v1.39.0-3          Red Hat OpenShift distributed tracing platform          1.39.0-3   jaeger-operator.v1.34.1-5          Succeeded
   opentelemetry-operator.v0.63.1-4   Red Hat OpenShift distributed tracing data collection   0.63.1-4   opentelemetry-operator.v0.60.0-2   Succeeded
   ```

   ```
   NAME                  READY   STATUS    RESTARTS   AGE
   instana-agent-75dkm   1/1     Running   0          5m6s 
   instana-agent-8gr46   1/1     Running   0          5m6s
   instana-agent-xpj95   1/1     Running   0          5m6s
   instana-agent-xxncc   1/1     Running   0          5m6s
   instana-agent-zvflw   1/1     Running   0          5m6s
   ```
4. Set environment variable:
   ```
   export CP4I_TRACING=YES
   ```

</details>
&nbsp;

<details>
<summary>
Install Common Services and its pre-requisites:
</summary>   

1. Install Cert Manager Operator:
   ```
   oc create -f resources/00-cert-manager-namespace.yaml
   oc create -f resources/00-cert-manager-operatorgroup.yaml
   oc create -f resources/00-cert-manager-subscription.yaml
   ```
   Confirm the subscription has been completed successfully before moving to the next step running the following command:
   ```
   oc get pods -n cert-manager-operator
   ```
   You should get a response like this:
   ```
   NAME                                                        READY   STATUS    RESTARTS   AGE
   cert-manager-operator-controller-manager-7f779b98b4-2f64r   2/2     Running   0          13h
   ```
2. Install Postgress SQL Catalog Source:
   ```
   oc create -f catalog-sources/${CP4I_VER}/01-postgress-sql-catalog-source-4.18.0.yaml
   ```
   Confirm the catalog source has been deployed successfully before moving to the next step running the following command:
   ```
   oc get pods -n openshift-marketplace | grep postgresql
   ```
   You should get a response like this:
   ```
   cloud-native-postgresql-catalog-jsmbk                             1/1     Running     0             14h
   ```
3. Install Common Services Catalog Source:
   ```
   oc create -f catalog-sources/${CP4I_VER}/02-common-services-catalog-source-4.4.0.yaml
   ```
   Confirm the catalog source has been deployed successfully before moving to the next step running the following command:
   ```
   oc get pods -n openshift-marketplace | grep opencloud
   ```
   You should get a response like this:
   ```
   opencloud-operators-fhbfd                                         1/1     Running     0             14h
   ```
4. Create the Common Services namespace:
   ```
   oc create namespace ibm-common-services
   ```
5. Install Common Services Operator:
   ```
   oc create -f subscriptions/${CP4I_VER}/00-common-service-subscription.yaml
   ```
   Confirm the operator has been deployed successfully before moving to the next step running the following command:
   ```
   oc get pods -n openshift-operators | grep ibm-common-service
   ```
   You should get a response like this:
   ```
   ibm-common-service-operator-8c9b944f4-nkkgb                       1/1     Running     0          14h
   ```
</details>
&nbsp; 

<details>
<summary>
Create namespaces with the corresponding entitlement key:
</summary>

1. Set your entitlement key:
   ```
   export ENT_KEY=eyJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJJQk0gTWFya2V0cGxhY2UiLCJpYXQiOjE1Nzg2ODgyNTksImp0aSI6IjdmYmZiMTM3NGFlNTQyOWZhOTM2MDdlOGUwYTcyNDU5In0.sd_sOTRpEsR3u9cxV_rR4jsxq4tuN6YHcyVmE8AngcQ
   ```
2. Create namespaces:
   ```
   scripts/02a-cp4i-ns-key-config.sh
   ```
</details>
&nbsp; 

<details>
<summary>
Deploy Platform UI:
</summary>

1. Install Platform UI Catalog Source:
   ```
   oc create -f catalog-sources/${CP4I_VER}/03-platform-navigator-catalog-source-7.2.2.yaml
   ```
   Confirm the catalog source has been deployed successfully before moving to the next step running the following command: 
   ```
   oc get pods -n openshift-marketplace | grep ibm-integration-platform-navigator
   ```
   You should get a response like this:
   ```
   ibm-integration-platform-navigator-catalog-xsm4w                  1/1     Running     0             14h
   ```
2. Install Platform UI Operator:
   ```
   oc create -f subscriptions/${CP4I_VER}/01-platform-navigator-subscription.yaml
   ```
   Confirm the operator has been deployed successfully before moving to the next step running the following command:
   ```
   oc get pods -n openshift-operators | grep ibm-integration-platform-navigator
   ```
   You should get a response like this:
   ```
   ibm-integration-platform-navigator-operator-6489bb9b7-tcnz8       1/1     Running     0          14h
   ```
3. Deploy a Platform UI instance (this may take 15 minutes):
   ```
   oc create -f instances/${CP4I_VER}/common/01-platform-navigator-instance.yaml
   ```
   Confirm the instance has been deployed successfully before moving to the next step running the following command:
   ```
   oc get platformnavigator -n tools
   ```
   You should get a response like this:
   ```
   NAME             REPLICAS   VERSION      STATUS   READY   LASTUPDATE   AGE   MESSAGE
   cp4i-navigator   1          2023.4.1-0   Ready    True    13h          14h   Platform UI has been provisioned.
   ```
4. Once the Platform UI instance is up and running get the access info:
   ```
   scripts/03b-cp4i-access-info.sh
   ```
   Note the password is temporary and you will be required to change it the first time you log into Platform UI.
</details>
&nbsp; 

<details>
<summary>
Deploy Asset Repo: 
</summary>

1. Install Asset Repo Catalog Source:
   ```
   oc create -f catalog-sources/${CP4I_VER}/04-asset-repo-catalog-source-1.6.2.yaml
   ```
   Confirm the catalog source has been deployed successfully before moving to the next step running the following command: 
   ```
   oc get pods -n openshift-marketplace | grep ibm-integration-asset-repository
   ```
   You should get a response like this:
   ```
   ibm-integration-asset-repository-catalog-7cm4f                    1/1     Running     0             14h
   ```
2. Install Asset Repo Operator:
   ```
   oc create -f subscriptions/${CP4I_VER}/02-asset-repo-subscription.yaml
   ```
   Confirm the operator has been deployed successfully before moving to the next step running the following command:
   ```
   oc get pods -n openshift-operators | grep ibm-integration-asset-repository
   ```
   You should get a response like this:
   ```
   ibm-integration-asset-repository-operator-7d7785d9b5-thcgd        1/1     Running     0          14h
   ```
3. Deploy an Asset Repo instance (this may take 5 minutes):
   ```
   oc create -f instances/${CP4I_VER}/${OCP_TYPE}/02-asset-repo-ai-instance.yaml
   ```
   Confirm the instance has been deployed successfully before moving to the next step running the following command:
   ```
   oc get assetrepository -n tools
   ```
   You should get a response like this:
   ```
   NAME            PHASE   VERSION      AGE
   asset-repo-ai   Ready   2023.4.1-0   14h
   ```
</details>
&nbsp;

<details>
<summary>
Deploy APIC: 
</summary>

1. Install DataPower Catalog Source:
   ```
   oc create -f catalog-sources/${CP4I_VER}/05-datapower-catalog-source-1.9.1.yaml
   ```
   Confirm the catalog source has been deployed successfully before moving to the next step running the following command: 
   ```
   oc get pods -n openshift-marketplace | grep ibm-datapower
   ```
   You should get a response like this:
   ```
   ibm-datapower-operator-catalog-8kmfg                              1/1     Running     0             14h
   ```
2. Install APIC Catalog Source:
   ```
   oc create -f catalog-sources/${CP4I_VER}/07-api-connect-catalog-source-5.1.0.yaml
   ```
   Confirm the catalog source has been deployed successfully before moving to the next step running the following command: 
   ```
   oc get pods -n openshift-marketplace | grep ibm-apiconnect
   ```
   You should get a response like this:
   ```
   ibm-apiconnect-catalog-8hk4q                                      1/1     Running     0             14h
   ```
3. Install APIC Operator (including DataPower):
   ```
   oc create -f subscriptions/${CP4I_VER}/04-api-connect-subscription.yaml
   ```
   Confirm the operators have been deployed successfully before moving to the next step running the following commands:
   ```
   oc get pods -n openshift-operators | grep datapower
   oc get pods -n openshift-operators | grep ibm-apiconnect
   ```
   You should get responses like these:
   ```
   datapower-operator-55cd67ddd9-m2s89                               1/1     Running     0          14h
   datapower-operator-conversion-webhook-974b5c64d-lql8r             1/1     Running     0          14h
   ```
   ```
   ibm-apiconnect-7fcdd447c7-qh8wh                                   1/1     Running     0          14h
   ```
4. Deploy APIC instance with some extra features enabled (this may take 30 minutes):
   ```
   scripts/07d-apic-inst-deploy-instana.sh
   ```
   Confirm the installation completed successfully after receiving the email before moving to the next step running the following commands:
   ```
   oc get apiconnectcluster -n tools
   ```
   Note this will take almost 30 minutes, so be patient, and at the end you should get a response like this:
   ```
   NAME        READY   STATUS   VERSION    RECONCILED VERSION   MESSAGE                        AGE
   apim-demo   6/6     Ready    10.0.7.0   10.0.7.0-5560        API Connect cluster is ready   14h
   ```
5. Configure APIC integration with Instana:
   ```
   scripts/07e-apic-instana-config.sh
   ```
6. Configure the email server in APIC:
   ```
   scripts/07f-apic-initial-config.sh
   ```
7. Create a Provider Organization for admin user:
   ```
   scripts/07g-apic-new-porg-cs.sh
   ```
</details>
&nbsp;

<details>
<summary>
Deploy Event Streams: 
</summary>

1. Install Event Streams Catalog Source:
   ```
   oc create -f catalog-sources/${CP4I_VER}/08-event-streams-catalog-source-3.3.1.yaml
   ```
   Confirm the catalog source has been deployed successfully before moving to the next step running the following command: 
   ```
   oc get pods -n openshift-marketplace | grep ibm-eventstreams
   ```
   You should get a response like this:
   ```
   ibm-eventstreams-catalog-f9zhs                                    1/1     Running     0             14h
   ```
2. Install Event Streams Operator:
   ```
   oc create -f subscriptions/${CP4I_VER}/05-event-streams-subscription.yaml
   ```
   Confirm the operator has been deployed successfully before moving to the next step running the following command:
   ```
   oc get pods -n openshift-operators | grep eventstreams-cluster
   ```
   You should get a response like this:
   ```
   eventstreams-cluster-operator-fb7796569-nxn8d                     1/1     Running     0          13h
   ```
3. Deploy Event Streams instance (this may take 8 minutes):
   ```
   oc create -f instances/${CP4I_VER}/${OCP_TYPE}/05-event-streams-instance.yaml
   ```
   Confirm the instance has been deployed successfully before moving to the next step running the following command:
   ```
   oc get eventstreams -n tools
   ```
   Note this will take few minutes, so be patient, and at some point you may see some errors, but at the end you should get a response like this:
   ```
   NAME      STATUS
   es-demo   Ready
   ```
4. Create topics and users:
   ```
   oc create -f resources/02a-es-initial-config.yaml
   ```
5. Enable Kafka Connect:
   ```
   scripts/08c-event-streams-kafka-connect-config.sh
   ```
   Confirm the instance has been deployed successfully before moving to the next step running the following command:
   ```
   oc get kafkaconnects -n tools
   ```
   Note this will take few minutes, but at the end you should get a response like this:
   ```
   NAME                  DESIRED REPLICAS   READY
   jgr-connect-cluster   1                  True
   ```
6. Enable Kafka Connector:
   ```
   scripts/08e-event-streams-kafka-connector-datagen-config.sh
   ```
   Confirm the instances has been deployed successfully before moving to the next step running the following command:
   ```
   oc get kafkaconnector -n tools
   ```
   Note this will take few minutes, but at the end you should get a response like this:
   ```
   NAME                 CLUSTER               CONNECTOR CLASS                                                         MAX TASKS   READY
   kafka-datagen        jgr-connect-cluster   com.ibm.eventautomation.demos.loosehangerjeans.DatagenSourceConnector   1           True
   kafka-datagen-avro   jgr-connect-cluster   com.ibm.eventautomation.demos.loosehangerjeans.DatagenSourceConnector   1           True
   ```
</details>
&nbsp;

<details>
<summary>
Deploy Event Endpoint Management: 
</summary>

1. Install EEM Catalog Source:
   ```
   oc create -f catalog-sources/${CP4I_VER}/13-eem-catalog-source-11.1.3.yaml
   ```
   Confirm the catalog source has been deployed successfully before moving to the next step running the following command: 
   ```
   oc get pods -n openshift-marketplace | grep ibm-eventendpointmanagement
   ```
   You should get a response like this:
   ```
   ibm-eventendpointmanagement-catalog-vm7zf                         1/1     Running     0              3d23h
   ```
2. Install EEM Operator:
   ```
   oc create -f subscriptions/${CP4I_VER}/09-eem-subscription.yaml
   ```
   Confirm the operator has been deployed successfully before moving to the next step running the following command:
   ```
   oc get pods -n openshift-operators | grep ibm-eem
   ```
   You should get a response like this:
   ```
   ibm-eem-operator-58b798fb99-lg9sp                                 1/1     Running     0              3d23h
   ```
3. Set passwords via environment variables:
   ```
   export EEM_ADMIN_PWD=admin
   export EEM_USER_PWD=admin
   ```
4. Deploy EEM Manager instance:
   ```
   scripts/19a-eem-manager-inst-deploy.sh
   ```
   Confirm the instance has been deployed successfully before moving to the next step running the following command:
   ```
   oc get eventendpointmanagement -n tools
   ```
   Note this will take few minutes, so be patient, but at the end you should get a response like this:
   ```
   NAME           PHASE     RECONCILED VERSION   UI ENDPOINT                                                                                       GATEWAY ENDPOINT
   eem-mgr-demo   Running   11.1.1               https://eem-mgr-demo-ibm-eem-manager-tools.apps.6597480c8e1478001153ba0d.cloud.techzone.ibm.com   https://eem-mgr-demo-ibm-eem-gateway-tools.apps.6597480c8e1478001153ba0d.cloud.techzone.ibm.com
   ```
5. Deploy EEM Gateway instance:
   ```
   scripts/19b-eem-gateway-inst-deploy.sh
   ```
   Confirm the instance has been deployed successfully before moving to the next step running the following command:
   ```
   oc get eventgateway -n tools
   ```
   Note this will take few minutes, so be patient, but at the end you should get a response like this:
   ```
   NAME          PHASE     RECONCILED VERSION   ENDPOINT
   eem-gw-demo   Running   11.1.1               https://eem-gw-demo-ibm-egw-rt-tools.apps.6597480c8e1478001153ba0d.cloud.techzone.ibm.com
   ```
6. Integrate EEM with APIC instance:
   1. Run script (wait for eem pod to restart):
      ```
      scripts/19c-eem-tls-profiles-apic-config.sh
      ```
   2. Run script:
      ```
      scripts/19d-eem-gateway-apic-config.sh
      ```
   3. Set environment variable:
      ```
      export EEM_APIC_INT=YES
      ```
7. Get token for post deployment configuration:

   Follow instructions listed [here](https://ibm.github.io/event-automation/eem/security/api-tokens/#creating-a-token)

8. Set environment variable for token:
   ```
   export EEM_TOKEN=<my-eem-token>
   ```
9. Populate EEM Catalog:
   ```
   scripts/19e-eem-manager-config.sh
   ```
</details>
&nbsp; 

<details>
<summary>
Deploy Enterprise Messaging - MQ: 
</summary>

1. Install MQ Catalog Source:
   ```
   oc create -f catalog-sources/${CP4I_VER}/09-mq-catalog-source-3.1.0.yaml 
   ```
   Confirm the catalog source has been deployed successfully before moving to the next step running the following command: 
   ```
   oc get pods -n openshift-marketplace | grep ibmmq
   ```
   You should get a response like this:
   ```
   ibmmq-operator-catalogsource-4h9ql                                1/1     Running     0              3d23h
   ```
2. Install MQ Operator:
   ```
   oc create -f subscriptions/${CP4I_VER}/06-mq-subscription.yaml
   ```
   Confirm the operator has been deployed successfully before moving to the next step running the following command:
   ```
   oc get pods -n openshift-operators | grep ibm-mq
   ```
   You should get a response like this:
   ```
   ibm-mq-operator-5965468479-btnkh                                  1/1     Running     0               3d23h
   ```
3. Set MQ namespace environment variable:
   ```
   export MQ_NAMESPACE=cp4i-mq
   ```
4. Create certificates and extra route:
   ```
   scripts/10a-qmgr-pre-config.sh
   ```
5. Create configmap with MQ configuration:
   ```
   oc create -f resources/03c-qmgr-mqsc-config.yaml
   ```
6. Deploy MQ Queue Manager instance:
   ```
   scripts/10b-qmgr-inst-deploy.sh
   ```
   Confirm the instance has been deployed successfully before moving to the next step running the following command:
   ```
   oc get queuemanager -n tools
   ```
   Note this will take few minutes, but at the end you should get a response like this:
   ```
   NAME        PHASE
   qmgr-demo   Running
   ```
7. Deploy Kafka Connect MQ Connectors:
   1. MQ Source Connector:
      ```
      oc create -f resources/02b-es-mq-source.yaml
      ```
   2. MQ Sink Connector:
      ```
      oc create -f resources/02c-es-mq-sink.yaml
      ```
</details>
&nbsp;

<details>
<summary>
Deploy App Connect: 
</summary>

1. Install App Connect Catalog Source:
   ```
   oc create -f catalog-sources/${CP4I_VER}/10-app-connect-catalog-source-11.3.0.yaml 
   ```
   Confirm the catalog source has been deployed successfully before moving to the next step running the following command: 
   ```
   oc get pods -n openshift-marketplace | grep appconnect
   ```
   You should get a response like this:
   ```
   appconnect-operator-catalogsource-qt2p5                           1/1     Running     0              3d23h
   ```
2. Install App Connect Operator:
   ```
   oc create -f subscriptions/${CP4I_VER}/07-app-connect-subscription.yaml
   ```
   Confirm the operator has been deployed successfully before moving to the next step running the following command:
   ```
   oc get pods -n openshift-operators | grep ibm-appconnect
   ```
   You should get a response like this:
   ```
   ibm-appconnect-operator-7d789b5b4c-cr8qw                          1/1     Running     2 (3d4h ago)    3d23h
   ```
3. Deploy Dashboard instance:
   ```
   oc create -f instances/${CP4I_VER}/${OCP_TYPE}/06-ace-dashboard-instance.yaml
   ```
   Confirm the instance has been deployed successfully before moving to the next step running the following command:
   ```
   oc get dashboard -n tools
   ```
   Note this will take few minutes, but at the end you should get a response like this:
   ```
   NAME            RESOLVEDVERSION   REPLICAS   CUSTOMIMAGES   STATUS   URL                                                                                   AGE
   ace-dashboard   12.0.10.0-r3      1          false          Ready    https://ace-dashboard-ui-tools.apps.6597480c8e1478001153ba0d.cloud.techzone.ibm.com   3d23h
   ```
4. Deploy Designer Authoring instance:  
   1. Deploy Designer Authoring instance
   ```
   oc create -f instances/${CP4I_VER}/${OCP_TYPE}/08-ace-designer-local-ai-instance.yaml
   ```
   Confirm the instance has been deployed successfully before moving to the next step running the following command:
   ```
   oc get designerauthoring -n tools
   ```
   Note this will take few minutes, but at the end you should get a response like this:
   ```
   NAME              RESOLVEDVERSION   URL                                                                                     CUSTOMIMAGES   STATUS   AGE
   ace-designer-ai   12.0.10.0-r3      https://ace-designer-ai-ui-tools.apps.6597480c8e1478001153ba0d.cloud.techzone.ibm.com   false          Ready    3d23h
   ```
5. Create Bar Auth Configuration:
   ```
   scripts/11-ace-config-barauth-github.sh
   ```
6. Create Policy Configuration to integrate with MQ:
      ```
      scripts/12a-ace-config-policy-mq.sh
      ```
7. Deploy Integration Runtime instances related to MQ and the API:
      ```
      scripts/12c-ace-is-apis-inst-deploy.sh
      ```
      You can check the status using the following command:
      ```
      oc get integrationruntimes -n tools
      ```
8. Configure Sales Force Connector:
      1. Set Environment Variables:  
         ```
         export SF_USER=fnaranjo@fxn.com
         export SF_PWD=Dr4g0nball1983grSxKlnXWtQpXTISUZbsFsm7
         export SF_CLIENT_ID=3MVG9FMtW0XJDLd0_VsoneRJQoAKAWhBwmWlGyDaNRQ7sGkk3ZIWO6uqHpZ1SX.khFqOx6G3ALcyL.zKi8iz8
         export SF_CLIENT_SECRET=2819D935729B9288EB456CB9CAB088D647353906784E8FFC6E9AD6AF41A14120
         export SF_LOGIN_URL=https://fxncom-dev-ed.my.salesforce.com
         ```
      2. Create Sales Force Account Configuration:
         ```
         scripts/12b-ace-config-accounts-sf.sh
         ```
      3. Set Environment Variable:
         ```
         export SF_CONNECTOR=YES
         ```
9. Deploy Integration Runtime instance related to SF:
      ```
      scripts/12d-ace-is-sf-inst-deploy.sh
      ```
10. Create Configurations related to ES:
      ```
      scripts/15a-ace-config-policy-es-scram.sh
      scripts/15b-ace-config-setdbparms-es-scram.sh
      scripts/15c-ace-config-truststore-es.sh
      ```
11. Deploy Integration Runtime instance related to ES:
      ```
      scripts/15d-ace-is-extra-inst-deploy.sh
      ```
12. Create Configuration for User Defined Policy:
      ```
      scripts/16-ace-config-policy-udp.sh
      ```
13. Create Configurations related to eMail server:
      ```
      scripts/17a-ace-config-policy-email.sh
      scripts/17b-ace-config-setdbparms-email.sh
      ```
14. Deploy Integration Runtime instance related to eMail:
      ```
      scripts/18a-ace-is-kafka-inst-deploy.sh
      ```
</details>
&nbsp; 

<details>
<summary>
Configure APIC for demo: 
</summary>

1. Publish draft assets:
   ```
   scripts/14a-apic-create-apis-draft.sh
   ```
2. Configure Catalogs:
   ```
   scripts/14b-apic-config-catalogs-publish-apis.sh
   ```
3. Set App Developer password:
   ```
   export APPDEV_PWD=F020kw31xx!
   ```
4. Create New Consumer Organization:
   ```
   scripts/14c-apic-new-consumer-org.sh
   ```
5. Create Apps and Subscriptions:
   ```
   scripts/14d-apic-create-apps-subscription.sh
   ```
</details>
&nbsp; 

<details>
<summary>
Install License Service: 
</summary>

1. Install License Service Catalog Source:
   ```
   oc create -f catalog-sources/${CP4I_VER}/02a-license-service-catalog-source.yaml
   ```
   Confirm the catalog source has been deployed successfully before moving to the next step running the following command: 
   ```
   oc get pods -n openshift-marketplace | grep ibm-licensing
   ```
   You should get a response like this:
   ```
   ibm-licensing-catalog-qqg67                                       1/1     Running     0              40s
   ```
2. Create namespace:
   ```
   oc create namespace ibm-licensing
   ```
3. Enable Operator Group in namespace:
   ```
   oc create -f resources/00-license-service-operatorgroup.yaml
   ```
4. Install License Service Operator (this may take 8 minutes):
   ```
   oc create -f subscriptions/${CP4I_VER}/00-license-service-subscription.yaml
   ```
   Confirm the operator has been deployed successfully before moving to the next step running the following command:
   ```
   oc get pod -n ibm-licensing | grep ibm-licensing
   ```
   You should get a response like this:
   ```
   ibm-licensing-operator-79759f7c69-zd679           1/1     Running   0          6m47s
   ibm-licensing-service-instance-59bf9dcd9c-svwqw   1/1     Running   0          3m50s
   ```
   Note: Make sure you wait long enough to see the instance as well as the operator.
5. Install License Reporter Catalog Source:
   ```
   oc create -f catalog-sources/${CP4I_VER}/02b-license-reporter-catalog-source.yaml
   ```
   Confirm the catalog source has been deployed successfully before moving to the next step running the following command: 
   ```
   oc get pods -n openshift-marketplace | grep ibm-license-service-reporter
   ```
   You should get a response like this:
   ```
   ibm-license-service-reporter-operator-catalog-rf8cg               1/1     Running     0              104s
   ```
6. Install License Reporter Operator:
   ```
   oc create -f subscriptions/${CP4I_VER}/00-license-reporter-subscription.yaml
   ```
   Confirm the operator has been deployed successfully before moving to the next step running the following command:
   ```
   oc get pod -n ibm-licensing | grep ibm-license-service-reporter
   ```
   You should get a response like this:
   ```
   ibm-license-service-reporter-operator-7c7549c696-q4776   1/1     Running   0          50s
   ```
7. Deploy a License Reporter instance:
   ```
   oc create -f instances/${CP4I_VER}/${OCP_TYPE}/00-license-reporter-instance.yaml
   ```
   Confirm the instance has been deployed successfully before moving to the next step running the following command:
   ```
   oc get pod -n ibm-licensing | grep lsr-instance
   ```
   After a few minutes you should get a response like this:
   ```
   ibm-license-service-reporter-ibm-lsr-instance-6c5dbbbc8d-hdwqk   4/4     Running   0          2m8s
   ``` 
8. Configure Data Source:
   ```
   scripts/04c-license-reporter-data-source-config.sh
   ```
9. Get License Service Reporter console access info:
   ```
   scripts/99-lsr-console-access-info.sh
   ```
</details>
&nbsp; 
<details>
<summary>
Example Payload: 
</summary>

1.- Use this example as the payload to send to the API:

```
{
  "metadata": {
    "code": "001"
  },
  "payload": {
    "id": "001",
    "fname": "Francisco",
    "lname": "Naranjo",
    "email": "fnaranjo@ec.ibm.com",
    "phone": "(593) 992-5345816",
    "company": "IBM",
    "comments": "Cloud Pak for Integration"
  }
}
```
</details>