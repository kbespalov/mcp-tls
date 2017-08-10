RabbitMQ TLS

compute nodes:
  services list:
    - neutron.compute
    - nova.compute
  required states:
    - salt "cmp*" state.sls salt.minion.cert
    - salt "cmp*" state.highstate

controller nodes:
   services list:
    - neutron.server
    - nova.controller
    - glance.server
    - cinder.volume
    - cinder.controller
    - keystone.server
    - designate.server
    - rabbitmq.server
   required states:
    - salt -I 'rabbitmq:server' state.sls salt.minion.cert
    - salt -I 'rabbitmq:server' state.sls rabbitmq.server
    - salt "ctl*" state.highstate

gateway nodes:
  services list:
   - neutron.gateway
  required states:
   - salt "gtw*" state.sls salt.minion.cert
   - salt "gtw*" state.highstate
