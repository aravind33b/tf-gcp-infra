#!/bin/bash

DBHOST="127.0.0.1"
DBPORT="5432"

DBUSER=$(curl http://metadata.google.internal/computeMetadata/v1/instance/attributes/DB_USER -H "Metadata-Flavor: Google")
DBPASS=$(gcloud secrets versions access latest --secret="db-password")
DBNAME=$(curl http://metadata.google.internal/computeMetadata/v1/instance/attributes/DB_NAME -H "Metadata-Flavor: Google")

# DBUSER="babuaravind"
# DBPASS=$(gcloud secrets versions access latest --secret="db-password")
# DBNAME="webapp"

echo "DBHOST=$DBHOST" > /usr/local/bin/.env
echo "DBPORT=$DBPORT" >> /usr/local/bin/.env
echo "DBUSER=$DBUSER" >> /usr/local/bin/.env
echo "DBPASS=$DBPASS" >> /usr/local/bin/.env
echo "DBNAME=$DBNAME" >> /usr/local/bin/.env

# setting permisions
chmod 600 /usr/local/bin/.env
chown csye6225:csye6225 /usr/local/bin/.env

echo "$0" > /var/startup-script.log
