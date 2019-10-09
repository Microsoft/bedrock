#!/bin/bash
while getopts :o:c:r:a:b:n: option
do
 case "${option}" in
 o) OWNERS=${OPTARG};;
 c) CONTRIBUTORS=${OPTARG};;
 r) READERS=${OPTARG};;
 a) CONTRIBUTOR_CLUSTER_ROLE_FILE=${OPTARG};;
 b) READER_CLUSTER_ROLE_FILE=${OPTARG};;
  *) echo "Please refer to usage guide on GitHub" >&2
    exit 1 ;;
 esac
done

if ! kubectl apply -f "$CONTRIBUTOR_CLUSTER_ROLE_FILE"
then
    echo "Unable to deploy cluster role cluster-contributor."
    exit 1
fi

if ! kubectl apply -f "$READER_CLUSTER_ROLE_FILE"
then
    echo "Unable to deploy cluster role: cluster-reader."
    exit 1
fi

if [ -z $OWNERS ]; then
    echo "OWNERS is empty"
else
    echo "OWNERS: $OWNERS"

    OWNERs_YAML="---"
    OWNERs_YAML+="\napiVersion: rbac.authorization.k8s.io/v1"
    OWNERs_YAML+="\nkind: ClusterRoleBinding"
    OWNERs_YAML+="\nmetadata:"
    OWNERs_YAML+="\n  name: aks-cluster-admins"
    OWNERs_YAML+="\nroleRef:"
    OWNERs_YAML+="\n  apiGroup: rbac.authorization.k8s.io"
    OWNERs_YAML+="\n  kind: ClusterRole"
    OWNERs_YAML+="\n  name: cluster-admin"
    OWNERs_YAML+="\nsubjects:"

    OWNERS_ARRAY=($(echo "$OWNERS" | tr ',' '\n'))
    for i in "${OWNERS_ARRAY[@]}"
    do
        OWNERs_YAML+="\n  - apiGroup: rbac.authorization.k8s.io"
        OWNERs_YAML+="\n    kind: User"
        OWNERs_YAML+="\n    name: $i"
    done

    echo "owners yaml file:"
    echo -e "$OWNERs_YAML"
    echo "\napplying...\n"

    echo -e "$OWNERs_YAML" | kubectl apply -f -

    echo -e "\ndone!"
fi

if [ -z $CONTRIBUTORS ]; then
    echo "CONTRIBUTORS is empty"
else
    echo "CONTRIBUTORS: $CONTRIBUTORS"

    CONTRIBUTORs_YAML="---"
    CONTRIBUTORs_YAML+="\napiVersion: rbac.authorization.k8s.io/v1"
    CONTRIBUTORs_YAML+="\nkind: ClusterRoleBinding"
    CONTRIBUTORs_YAML+="\nmetadata:"
    CONTRIBUTORs_YAML+="\n  name: aks-cluster-contributors"
    CONTRIBUTORs_YAML+="\nroleRef:"
    CONTRIBUTORs_YAML+="\n  apiGroup: rbac.authorization.k8s.io"
    CONTRIBUTORs_YAML+="\n  kind: ClusterRole"
    CONTRIBUTORs_YAML+="\n  name: cluster-contributor"
    CONTRIBUTORs_YAML+="\nsubjects:"

    CONTRIBUTORS_ARRAY=($(echo "$CONTRIBUTORS" | tr ',' '\n'))
    for c in "${CONTRIBUTORS_ARRAY[@]}"
    do
        CONTRIBUTORs_YAML+="\n  - apiGroup: rbac.authorization.k8s.io"
        CONTRIBUTORs_YAML+="\n    kind: User"
        CONTRIBUTORs_YAML+="\n    name: $c"
    done


    echo "owners yaml file:"
    echo -e "$CONTRIBUTORs_YAML"
    echo "\napplying...\n"

    echo -e "$CONTRIBUTORs_YAML" | kubectl apply -f -

    echo -e "\ndone!"
fi


if [ -z $READERS ]; then
    echo "READERS is empty"
else
    echo "READERS: $READERS"

    READERs_YAML="---"
    READERs_YAML+="\napiVersion: rbac.authorization.k8s.io/v1"
    READERs_YAML+="\nkind: ClusterRoleBinding"
    READERs_YAML+="\nmetadata:"
    READERs_YAML+="\n  name: aks-cluster-readers"
    READERs_YAML+="\nroleRef:"
    READERs_YAML+="\n  apiGroup: rbac.authorization.k8s.io"
    READERs_YAML+="\n  kind: ClusterRole"
    READERs_YAML+="\n  name: cluster-reader"
    READERs_YAML+="\nsubjects:"

    READERS_ARRAY=($(echo "$READERS" | tr ',' '\n'))
    for r in "${READERS_ARRAY[@]}"
    do
        READERs_YAML+="\n  - apiGroup: rbac.authorization.k8s.io"
        READERs_YAML+="\n    kind: User"
        READERs_YAML+="\n    name: $r"
    done

    echo "owners yaml file:"
    echo -e "$READERs_YAML"
    echo "\napplying...\n"

    echo -e "$READERs_YAML" | kubectl apply -f -

    echo -e "\ndone!"
fi
