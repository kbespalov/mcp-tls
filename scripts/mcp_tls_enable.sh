#!/bin/bash -x
exec > >(tee -i /tmp/"$(basename "$0" .sh)"_"$(date '+%Y-%m-%d_%H-%M-%S')".log) 2>&1

salt '*' saltutil.refresh_pillar
salt '*' saltutil.sync_all

# Generate required certificates and distribute CA cert across all nodes
# according trusted_ca_minions param.

salt '*' state.sls salt.minion.cert

# Apply changes to infra services

salt -C 'I@galera:master' state.sls galera
salt -C 'I@galera:slave' state.sls galera
salt -C 'I@rabbitmq:server' state.sls rabbitmq

# Workaround to restart Galera cluster

salt -C 'I@galera:slave'  cmd.run "pkill -9 mysql" -b 1
salt -C 'I@galera:master' cmd.run "pkill -9 mysql" -b 1

# Start Galera Master
salt -C 'I@galera:master' cmd.run "rm -rdf /var/run/mysqld"
salt -C 'I@galera:master' cmd.run "mkdir /var/run/mysqld"
salt -C 'I@galera:master' cmd.run "chown mysql:mysql /var/run/mysqld"
salt -C 'I@galera:master' cmd.run "service mysql bootstrap"

# Start Galera Slave's
salt -C 'I@galera:slave'  service.start mysql

# Apply changes to openstack services

salt -C 'I@keystone:server' state.sls keystone.server -b 1
salt -C 'I@glance:server' state.sls glance -b 1
salt -C 'I@nova:controller' state.sls nova -b 1
salt -C 'I@cinder:controller' state.sls cinder -b 1
salt -C 'I@cinder:volume' state.sls cinder
salt -C 'I@neutron:server' state.sls neutron -b 1
salt -C 'I@neutron:gateway' state.sls neutron
salt -C 'I@heat:server' state.sls heat -b 1
salt -C 'I@barbican:server' state.sls barbican -b 1
salt -C 'I@designate:server' state.sls heat -b 1
