#!/bin/bash
source /do_auth

if [ -z "$1" ] || [ -z "$2" ]; then
    echo "Need base image name and number of vms to provision!"
    exit 1
fi

DO_BASE_NAME=$1
DO_SIZE=s-1vcpu-1gb
DO_REGION=nyc3
DO_SSH_IDS=$(doctl -t $DO_AUTH compute ssh-key list --no-header --format ID)
DO_TAGS=test,cicd
DO_DROPLET_COUNT=$2

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

echo -e "\n=== PROVISION ===\n"

for server in $(seq 1 $DO_DROPLET_COUNT); do
    echo "Creating $DO_BASE_NAME-${server} with size $DO_SIZE in $DO_REGION given these tags $DO_TAGS"
    doctl -t $DO_AUTH compute droplet create $DO_BASE_NAME-${server} --size $DO_SIZE --image centos-7-x64 --region $DO_REGION --ssh-keys $DO_SSH_IDS --tag-names $DO_TAGS --wait
done
