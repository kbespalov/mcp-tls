# Enabling RabbitMQ TLS in MCP

### 1. PKI. Certificates and keys provisioning

First of all to enable RabbitMQ TLS communication the following should be provided:
 - Private and public key pair of the rabbitmq server(s).
 - Certificate of the public key signed by CA.
 - CA certificate (must be distributed on all nodes which will use RMQ server with TLS).



Required key pairs and certificates can be provided by user or generated using PKI of the SaltStack in the MCP.

#### 1.1 Providing existening certs and keys for RabbitMQ

Specify desired location and a content of the required files in the reclass model of nodes with RabbitMQ server:

```yaml
rabbitmq:
  server:
     ssl:
       enabled: True
       key_file: /etc/rabbitmq/ssl/key.pem
       key:  {content here}
       ca_file: /etc/rabbitmq/ssl/ca.pem
       cacert_chain: {content here}
       cert_file: /etc/rabbitmq/ssl/cert.pem
       cert: {content here}
```

then  apply the state:

     salt -I 'rabbitmq:server' state.sls rabbitmq.server

To distribute Salt Master CA certificate across all nodes which will be connect to RabbitMQ via TLS you need to copy CA certificate using e.g.:

    salt-cp <targets> /path/to/your/ca.cert /usr/local/share/ca-certificates/rabbitmq-ca.cert

then install it as system-wide certificate:

    salt <targets> cmd.run update-ca-certificates

#### 1.2 Generating certs and keys using SaltStack PKI in MCP.

In MCP Generation and distribution of certs and keys performs by applying `salt.minion.cert` [1] state.
To generate cerificates and keys for RabbitMQ server using `salt.minion.cert` state you need include the following classes [2][3] in your reclass model:

    classes:
     - service.rabbitmq.server.ssl
     - system.salt.minion.cert.rabbitmq_server

then apply the following states:

    salt -I 'rabbitmq:server' state.sls salt.minion.cert
    salt -I 'rabbitmq:server' state.sls rabbitmq.server

As result of the state applying will be generated required keys and certificates signed by Salt Master CA [4].

To distribute Salt Master CA certificate across all nodes which will be connect to RabbitMQ via TLS you need to establish
trust for cerificates coming from salt.mine of the master node `cfg01`:     

    salt:
      minion:
        trusted_ca_minions:
           - cfg01.${_param:cluster_domain}

then apply the same state:

    salt <all nodes which will be use rmq tls>  state.sls salt.minion.cert

as result of the state applying the Salt Master CA certificate will be system-wide installed.

### Troubleshooting

- Issue 1. Non-synced pillar

Traceback

```
    Data failed to compile:
    Pillar failed to render with the following messages:
    Failed to load ext_pillar reclass: ext_pillar.reclass:
```
Solution:

```
     salt '*' saltutil.refresh_pillar
     salt '*' saltutil.sync_all
```

- Issue 2. Invalid rabbitmq-server keys and certs files permissions

Traceback
```
 AMQP server on 172.16.10.103:5671 is unreachable: EOF occurred in violation of protocol (_ssl.c:590). Trying again in 1 seconds. Client port: None
```
Solution:

Ensure that all keys and certificates accessable for read via `rabbitmq` server


### Links:
[1] https://github.com/salt-formulas/salt-formula-salt/blob/master/salt/minion/cert.sls
[2] https://github.com/salt-formulas/salt-formula-rabbitmq/blob/master/metadata/service/server/ssl.yml
[3] https://github.com/Mirantis/reclass-system-salt-model/tree/master/salt/minion/cert
[4] https://github.com/Mirantis/reclass-system-salt-model/blob/master/salt/minion/ca/salt_master.yml
