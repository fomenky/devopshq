#!/usr/bin/env bash

echo -e "Executing ansible-galaxy with the following command line:\nansible-galaxy $@"

ansible-galaxy "$@"
