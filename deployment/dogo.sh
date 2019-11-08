#!/bin/bash
source /do_auth
source $(dirname $0)/deploy.conf

function host_query_IP() {
    DO_BASE_NAME=$1

    if [ -z ${DO_BASE_NAME} ]; then
        echo "NO BASE NAME"
        exit 1
    fi

    DO_DROP_QUERY="*${DO_BASE_NAME}*"

    QUERY_IPS=($(doctl -t $DO_AUTH compute droplet list $DO_DROP_QUERY --no-header --format PublicIPv4))

    # DEBUG
    echo "${QUERY_IPS[@]}"
}

function doNOgo() {
    if [ -z "$1" ] || [ -z "$2" ]; then
        echo "Need base image name and number of vms to provision!"
        exit 1
    fi

    DO_BASE_NAME=$1
    if [ -z "$DO_SSH_IDS" ]; then
        echo "Please set your DO_SSH_IDS!"
        exit 1
    fi

    echo -e "\n=== DELETE OLD VMS ===\n"

    DO_DROP_QUERY="*$DO_BASE_NAME*"
    CURRENT_VMS=($(doctl -t $DO_AUTH compute droplet list $DO_DROP_QUERY --format ID --no-header))

    if [ ${#CURRENT_VMS[@]} -gt 0 ]; then
        for server in "${CURRENT_VMS[@]}"; do
            echo "Deleting: ${server}"
            doctl -t $DO_AUTH compute droplet delete ${server} --force
        done
    fi
}

function dogo() {
    if [ -z "$1" ] || [ -z "$2" ]; then
        echo "Need base image name and number of vms to provision!"
        exit 1
    fi

    DO_BASE_NAME=$1
    if [ -z "$DO_SSH_IDS" ]; then
        echo "Please set your DO_SSH_IDS!"
        exit 1
    fi

    echo -e "\n=== DELETE OLD VMS ===\n"

    DO_DROP_QUERY="*$DO_BASE_NAME*"
    CURRENT_VMS=($(doctl -t $DO_AUTH compute droplet list $DO_DROP_QUERY --format ID --no-header))

    if [ ${#CURRENT_VMS[@]} -gt 0 ]; then
        for server in "${CURRENT_VMS[@]}"; do
            echo "Deleting: ${server}"
            doctl -t $DO_AUTH compute droplet delete ${server} --force
        done
    fi

    echo -e "\n=== PROVISION NEW VMS ===\n"

    for server in $(seq 1 $2); do
        echo "Creating $DO_BASE_NAME-${server} with size $DO_SIZE in $DO_REGION given these tags $DO_TAGS"
        doctl -t $DO_AUTH compute droplet create $DO_BASE_NAME-${server} --size $DO_SIZE --image centos-7-x64 --region $DO_REGION --ssh-keys $DO_SSH_IDS --tag-names $DO_TAGS --wait
    done
}
