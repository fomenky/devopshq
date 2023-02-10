#!/usr/bin/env bash

echo -e "Executing ansible with the following command line:\nansible-playbook $@"

ansible-playbook "$@"
