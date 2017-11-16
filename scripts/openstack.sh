#!/bin/bash -x
exec > >(tee -i /tmp/"$(basename "$0" .sh)"_"$(date '+%Y-%m-%d_%H-%M-%S')".log) 2>&1

salt '*' saltutil.refresh_pillar
salt '*' saltutil.sync_all

# The script to apply the state in order to enable TLS for openstack services

salt -C 'I@keystone:server:enabled' state.sls keystone.server:enabled -b 1
salt -C 'I@glance:server:enabled' state.sls glance -b 1
salt -C 'I@nova:controller:enabled' state.sls nova -b 1
salt -C 'I@cinder:controller:enabled' state.sls cinder -b 1
salt -C 'I@cinder:volume:enabled' state.sls cinder -b 1
salt -C 'I@neutron:server:enabled' state.sls neutron -b 1
salt -C 'I@neutron:gateway:enabled' state.sls neutron -b 1
salt -C 'I@heat:server:enabled' state.sls heat -b 1
salt -C 'I@barbican:server:enabled' state.sls barbican -b 1
salt -C 'I@designate:server:enabled' state.sls designate -b 1
