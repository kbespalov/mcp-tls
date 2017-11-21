Configuring TLS communications
------------------------------


**Note:** by default system wide installed CA certs are used, so ``cacert_file`` param is optional, as well as ``cacert``.


- **RabbitMQ TLS**

.. code-block:: yaml

 nova:
   compute:
      message_queue:
        port: 5671
        ssl:
          enabled: True
          (optional) cacert: cert body if the cacert_file does not exists
          (optional) cacert_file: /etc/openstack/rabbitmq-ca.pem
          (optional) version: TLSv1_2


- **MySQL TLS**

.. code-block:: yaml

 nova:
   controller:
      database:
        ssl:
          enabled: True
          (optional) cacert: cert body if the cacert_file does not exists
          (optional) cacert_file: /etc/openstack/mysql-ca.pem

- **Openstack HTTPS API**


Set the ``https`` as protocol for ``identity``, ``network`` and ``glance`` sections at ``nova:compute`` and ``nova:controller`` :

.. code-block:: yaml

 nova:
  compute and controller :
      identity:
         protocol: https
         (optional) cacert_file: /etc/openstack/proxy.pem
      network:
         protocol: https
         (optional) cacert_file: /etc/openstack/proxy.pem
      glance:
         protocol: https
         (optional) cacert_file: /etc/openstack/proxy.pem

If Ironic is used, then  specify ``https`` as protocol for ``nova:compute:ironic`` section:

.. code-block:: yaml

 nova:
   compute:
      ironic:
        protocol: https
        (optional) cacert_file: /etc/openstack/proxy.pem
