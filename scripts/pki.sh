#!/bin/bash -xe
exec > >(tee -i /tmp/"$(basename "$0" .sh)"_"$(date '+%Y-%m-%d_%H-%M-%S')".log) 2>&1

salt '*' saltutil.refresh_pillar
salt '*' saltutil.sync_all

# The scipt generates required server's certs and distribute a CA cert across
# all nodes according trusted_ca_minions param.

salt '*' state.sls salt.minion.cert
