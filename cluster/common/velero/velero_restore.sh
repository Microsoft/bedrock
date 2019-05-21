#!/usr/bin/env bash

while getopts :b:p:s:l:v:n:r:f: option
do
 case "${option}" in
 b) VELERO_BUCKET=${OPTARG};;
 p) VELERO_PROVIDER=${OPTARG};;
 s) VELERO_SECRETS=${OPTARG};;
 l) VELERO_BACKUP_LOCATION_CONFIG=${OPTARG};;
 v) VELERO_VOLUME_SNAPSHOT_LOCATION_CONFIG=${OPTARG};;
 n) VELERO_BACKUP_NAME=${OPTARG};;
 r) VELERO_RESTORE_NAME=${OPTARG};;
 f) VELERO_RESTORE_FLAGS=${OPTARG};;
 *) echo "ERROR: Please refer to usage guide on GitHub" >&2
    exit 1 ;;
 esac
done

if ! hash velero 2>/dev/null; then
    echo "'velero' was not found in PATH. Please install the velero cli before running terraform."
    exit 1
fi

if [ -z "$VELERO_BACKUP_NAME" ] || [ -z "$VELERO_RESTORE_NAME" ]; then
    echo "ERROR: 'VELERO_BACKUP_NAME' or 'VELERO_RESTORE_NAME' is not set or set to an empty string."
    exit 1
fi

# Check Azure Specific settings
if [ -z "$VELERO_PROVIDER" ] && [ "$VELERO_PROVIDER" == "azure" ]; then
    if [ -z "$VELERO_SECRETS" ] && test -e "$VELERO_SECRETS"; then
        echo "ERROR: 'VELERO_SECRETS' is not set or does not exist but is required for the azure provider."
        exit 1
    fi

    if [[ "$VELERO_BACKUP_LOCATION_CONFIG" =~ "resourceGroup=" ]] && [[ "$VELERO_BACKUP_LOCATION_CONFIG" =~ "storageAccount=" ]]; then
        echo "'VELERO_BACKUP_LOCATION_CONFIG' contains the resourceGroup and storageAccount variable."
    else
        echo "ERROR: 'VELERO_BACKUP_LOCATION_CONFIG' does not have a resourceGroup or storageAccount variables set."
        exit 1
    fi

    if [[ "$VELERO_VOLUME_SNAPSHOT_LOCATION_CONFIG" =~ "apiTimeout=" ]]; then
        echo "'VELERO_VOLUME_SNAPSHOT_LOCATION_CONFIG' contains the apiTimeout variable."
    else
        echo "ERROR: 'VELERO_VOLUME_SNAPSHOT_LOCATION_CONFIG' does not have an apiTimeout variables set."
        exit 1
    fi
fi
# TODO: Check AWS/GCP specific settings here.

# Setup Velero on Cluster to do Restore
velero install \
    --provider "$VELERO_PROVIDER" \
    --bucket "$VELERO_BUCKET" \
    --secret-file "$VELERO_SECRETS" \
    --backup-location-config "$VELERO_BACKUP_LOCATION_CONFIG" \
    --snapshot-location-config "$VELERO_VOLUME_SNAPSHOT_LOCATION_CONFIG" \
    --restore-only \
    --wait

velero_install_result=$?
if [ $velero_install_result -ne 0 ]; then
    echo "ERROR: Velero failed to install."
    exit 1
fi

echo "Waiting for Velero resources to be synchronized. Default is 1min."
sleep 1m

if ! velero backup describe "$VELERO_BACKUP_NAME"; then
    echo "ERROR: Failed to find backup with name $VELERO_BACKUP_NAME."
    exit 1
fi

velero restore create "$VELERO_RESTORE_NAME" --from-backup "$VELERO_BACKUP_NAME" --wait "$VELERO_RESTORE_FLAGS"

velero_restore_result=$?
if [ $velero_restore_result -ne 0 ]; then
    echo "ERROR: Velero failed to restore backup. See: $velero_restore_result"
    exit 1
fi

# Velero restore is complete so let's remove it from the cluster. Flux will re-add if we want it in the cluster desired state.
kubectl delete namespace/velero clusterrolebinding/velero
kubectl delete crds -l component=velero
