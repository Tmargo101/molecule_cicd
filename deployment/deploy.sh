#!/bin/bash
source $(dirname $0)/deploy.conf
source $(dirname $0)/dogo.sh

# Remove old host file
rm -f $HOST_LOC


# WEB SERVERS
echo -e $WEB_GROUP >> $HOST_LOC
dogo ${BRANCH_NAME}-web $WEB_SERVER_AMT
hostsIP=($(host_query_IP ${BRANCH_NAME}))

if [ ${#hostsIP[@]} -eq 0 ]; then
    echo "No hosts to move forward with"
    exit 0
fi

i=0
for server in "${hostsIP[@]}"; do
    echo "web${i} ansible_host=${server}" >> $HOST_LOC
    ((i++))
done

# OTHER SERVERS


#### DEPLOY #####

#Need to wait for infrastructure to come up. This number arbitrary.
echo -e "\n=== Waiting for Infrastructure ===\n"
sleep 20
/usr/bin/ansible-playbook -i $HOST_LOC $PLAYBOOK_LOC
