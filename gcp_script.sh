#!/usr/bin/env bash
# phpmyadmin, certificate, mysql, persistent storage, wordpress
# Ref doc: https://cloud.google.com/kubernetes-engine/docs/tutorials/persistent-disk

# Deploy Cloud SQL

# Get buckets ?

# Get GKE cluster with 3nodes

# Prep manifests
#gcloud sql instances create test-instance --database-version=MYSQL_5_7 --cpu=2 --memory=4GB --region=europe-west1 --root-password=P@ssw0rd
#gcloud container clusters create test-k8s \
#    --num-nodes=3 --enable-autoupgrade --no-enable-basic-auth \
#    --no-issue-client-certificate --enable-ip-alias --metadata \
#    disable-legacy-endpoints=true

# Generals
REGION='europe-west1-b'
PROJECT_ID='<ID_PROJECT>'

gcloud config set compute/zone $REGION

git clone https://github.com/GoogleCloudPlatform/kubernetes-engine-samples
cd kubernetes-engine-samples/wordpress-persistent-disks
WORKING_DIR=$(pwd)

# GKE
CLUSTER_NAME=wordpress-test
gcloud container clusters create $CLUSTER_NAME \
    --num-nodes=3 --enable-autoupgrade --no-enable-basic-auth \
    --no-issue-client-certificate --enable-ip-alias --metadata \
    disable-legacy-endpoints=true

# Inside Cluster Shell
kubectl apply -f $WORKING_DIR/wordpress-volumeclaim.yaml
kubectl get persistentvolumeclaim

# Remote
INSTANCE_NAME=mysql-wordpress-instance
gcloud sql instances create $INSTANCE_NAME

export INSTANCE_CONNECTION_NAME=$(gcloud sql instances describe $INSTANCE_NAME \
    --format='value(connectionName)')
gcloud sql databases create wordpress --instance $INSTANCE_NAME

CLOUD_SQL_PASSWORD=$(openssl rand -base64 18)
gcloud sql users create wordpress --host=% --instance $INSTANCE_NAME \
    --password $CLOUD_SQL_PASSWORD

# Wordpress
SA_NAME=cloudsql-proxy
gcloud iam service-accounts create $SA_NAME --display-name $SA_NAME

SA_EMAIL=$(gcloud iam service-accounts list \
    --filter=displayName:$SA_NAME \
    --format='value(email)')
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --role roles/cloudsql.client \
    --member serviceAccount:$SA_EMAIL
