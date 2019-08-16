#!/bin/sh
while getopts :a:r:d:c: option
do
 case "${option}" in
 a) ACCOUNT_NAME=${OPTARG};;
 r) RESOURCE_GROUP_NAME=${OPTARG};;
 d) DB_NAME=${OPTARG};;
 c) COLLECTIONS=${OPTARG};;
 *) echo "Please refer to usage guide on GitHub" >&2
    exit 1 ;;
 esac
done

if [ -z $ACCOUNT_NAME ]; then
    echo "ACCOUNT_NAME is empty"
    exit 1;
elif [ -z $RESOURCE_GROUP_NAME ]; then
    echo "RESOURCE_GROUP_NAME is empty"
    exit 1;
elif [ -z $DB_NAME ]; then
    echo "DB_NAME is empty"
    exit 1;
elif [ -z $COLLECTIONS ]; then
    echo "COLLECTIONS is empty"
    exit 1;
else
    echo "Input is valid"
fi

# echo "az login with terraform service principal"
# echo "environment variables: clientId=$ARM_CLIENT_ID, tenantId=$ARM_TENANT_ID"
# az login --service-principal --username $ARM_CLIENT_ID --password $ARM_CLIENT_SECRET --tenant $ARM_TENANT_ID
echo "collections: \n$COLLECTIONS"

COLLECTION_ARRAY=($(echo "$COLLECTIONS" | tr '*' '\n'))
for i in "${COLLECTION_ARRAY[@]}"
do
    CURRENT_SETTINGS="$i"

    COLLECTION_SETTINGS=($(echo "$CURRENT_SETTINGS" | tr ',' '\n'))
    COLLECTION_NAME=${COLLECTION_SETTINGS[0]}
    PARTITION_KEY=${COLLECTION_SETTINGS[1]}
    THROUGH_PUT=${COLLECTION_SETTINGS[2]}
    echo "provisioning collection, name=$COLLECTION_NAME, partition=$PARTITION_KEY, throughput=$THROUGH_PUT"

    COLLECTION="$(az cosmosdb collection list --name $ACCOUNT_NAME --db-name $DB_NAME --resource-group $RESOURCE_GROUP_NAME --query "[?id=='$COLLECTION_NAME'].{id:id}" -o tsv)"
    if [ -z $COLLECTION ]; then
        az cosmosdb collection create --name $ACCOUNT_NAME --db-name $DB_NAME --collection-name $COLLECTION_NAME --resource-group $RESOURCE_GROUP_NAME --partition-key-path $PARTITION_KEY --throughput $THROUGH_PUT
        echo "created collection $COLLECTION_NAME"
    else
        echo "Collection $COLLECTION_NAME already created"
    fi
done