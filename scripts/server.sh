#!/bin/bash -xe
exec > >(tee -i /tmp/"$(basename "$0" .sh)"_"$(date '+%Y-%m-%d_%H-%M-%S')".log) 2>&1

# The script to apply the state in order to enable TLS for the following servers:
# - rabbitmq
# - mysql (galera cluster)

salt '*' saltutil.refresh_pillar
salt '*' saltutil.sync_all

# Apply RabbitMQ state
salt -C 'I@rabbitmq:server:enabled:enabled' state.sls rabbitmq

# Apply Galera state + manual restart
salt -C 'I@galera:master:enabled' state.sls galera
salt -C 'I@galera:master:enabled' state.sls galera

salt -C 'I@galera:slave:enabled'  service.stop mysql -b 1
salt -C 'I@galera:master:enabled' service.stop mysql -b 1
salt -C 'I@galera:master:enabled' cmd.run "service mysql start --service-startup-timeout=60 --wsrep-new-cluster"
salt -C 'I@galera:slave:enabled' service.start mysql -b 1
