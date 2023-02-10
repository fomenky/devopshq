#!/usr/bin/env bash

/usr/bin/ssh -o StrictHostKeyChecking=no -i "${GIT_KEY}" "$@"
