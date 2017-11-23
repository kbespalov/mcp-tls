## TLS Support at MCP

### Steps:
 -  Configuration of TLS at server's side (mysql, rabbitmq, nginx)
 -  Configuration of TLS at client's side (openstack components)


### Configuration of TLS at server's side

1. **Add the following classes to the cluster model of the nodes where the server is located**:

- RabbitMQ server:
    ```yml
    classes:
     ### Enable tls, contains paths to certs/keys
     - service.rabbitmq.server.ssl
     ### Definition of cert/key
     - system.salt.minion.cert.rabbitmq_server
     ```
- MySQL server (Galera Cluster):
     ```yml
    classes:
     ### Enable tls, contains paths to certs/keys
    - service.galera.ssl
    ### Definition of cert/key
    - system.salt.minion.cert.mysql.server
     ```

2. **Make sure each of nodes are trusts to CA certificates that coming from SaltMaster**:

    ```
    _param:
       salt_minion_ca_host: cfg01.${_param:cluster_domain}
    salt:
       minion:
          trusted_ca_minions:
            -  cfg01.${_param:cluster_domain}
    ```
    It's allow to distribute SaltMaster CA certificate across nodes using salt mine and install the cert as system wide.


3. **Refresh the pillar data to sync model at all nodes**:

    ```sh
     salt '*' saltutil.refresh_pillar
     salt '*' saltutil.sync_all
     ```    

4. **Generate server's certificates and distibute CA certificate:**
    ```
    salt '*' salt.minion.cert
    ```

5. **Apply the new state to the servers**

- RabbiMQ:
    ```sh
    salt -I 'rabbitmq:server' state.sls rabbitmq.server
    ```
- MySQL (Galera Cluster):
   ```sh
   # Will change configs files like my.cnf, but does not restart the service
   salt -C 'I@galera:master:enabled' state.sls galera
   salt -C 'I@galera:master:enabled' state.sls galera

   # Stop slaves and master in the following order
   salt -C 'I@galera:slave:enabled'  service.stop mysql -b 1
   salt -C 'I@galera:master:enabled' service.stop mysql -b 1

   # Run cluster boostrap process on master node in foreground
   salt -C 'I@galera:master:enabled' cmd.run "service mysql bootstrap" &
   # then start mysql on slaves nodes
   salt -C 'I@galera:slave:enabled' service.start mysql -b 1

   # Verify cluster size:
   salt -C 'I@galera:master:enabled' mysql.status | grep -A1 wsrep_cluster_size
   salt -C 'I@galera:slave:enabled' mysql.status | grep -A1 wsrep_cluster_size
   ```

### Configuration of TLS at client's side:

1. For each of the OpenStack services enable TLS protocol usage for messaging and database communications via changing a cluster model as it show in examples below:

* **controller node**:

	* database: https://github.com/kbespalov/mcp-tls/blob/master/classes/database/controller.yml
	* messaging: https://github.com/kbespalov/mcp-tls/blob/master/classes/messaging/controller.yml

* **compute node**:
	* messaging: https://github.com/kbespalov/mcp-tls/blob/master/classes/messaging/controller.yml

* **gateway node**:
  * messaging: https://github.com/kbespalov/mcp-tls/blob/master/classes/messaging/gateway.yml

* **AIO node**: https://github.com/kbespalov/mcp-tls/blob/master/classes/aio.yml.

  Detailed description of TLS configuration each of the OpenStack salt formulas you can find at README.rst at thier git repos.


2. **Refresh the pillar data to sync model at all nodes**:

    ```sh
     salt '*' saltutil.refresh_pillar
     salt '*' saltutil.sync_all
     ```    

3. **Apply the new state to the OpenStack services**:

    ```sh
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
    salt -C 'I@nova:compute:enabled' state.sls nova -b 1
    salt -C 'I@neutron:compute:enabled' state.sls neutron -b 1
    salt -C 'I@neutron:gateway:enabled' state.sls neutron -b 1
    ```

4. **Update nova cell's rabbitmq transport_url and sql_connection url at database**:
    ```
    > nova-manage cell_v2 list_cells

    +-------+--------------------------------------+
    |  Name |                 UUID                 |
    +-------+--------------------------------------+
    | cell0 | 00000000-0000-0000-0000-000000000000 |
    | cell1 | 9bef7261-862f-46f5-bb28-c5505a94fa41 |
    +-------+--------------------------------------+

    > nova-manage cell_v2 update_cell --cell_uuid 9bef7261-862f-46f5-bb28-c5505a94fa41
    > nova-manage cell_v2 update_cell --cell_uuid 00000000-0000-0000-0000-000000000000

    > nova-manage cell_v2 list_cells --verbose
    ```
