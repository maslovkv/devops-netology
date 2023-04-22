#!/usr/bin/env bash
SCRIPT_DIR=$( readlink -e "$( dirname -- "${BASH_SOURCE[0]}" )" )

ubu_id=$(docker run -dt --name ubuntu  pycontribs/ubuntu)
cen_id=$(docker run -dt --name centos7  pycontribs/centos:7)
fed_id=$(docker run -dt --name fedora  pycontribs/fedora)
all_aid="${fed_id} ${cen_id} ${ubu_id}"

ansible-playbook -i ${SCRIPT_DIR}/inventory/prod.yml ${SCRIPT_DIR}/site.yml --vault-password-file ${SCRIPT_DIR}/ansible_vault_pass

#docker stop $all_aid  > /dev/null
#docker rm $all_aid > /dev/null
