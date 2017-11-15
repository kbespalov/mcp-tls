#!/bin/bash

set -e

salt -C 'I@galera:slave'  cmd.run "pkill -9 mysql" -b 1
salt -C 'I@galera:master' cmd.run "pkill -9 mysql" -b 1

salt -C 'I@galera:master' cmd.run "rm -rdf /var/run/mysqld"
salt -C 'I@galera:master' cmd.run "mkdir /var/run/mysqld"
salt -C 'I@galera:master' cmd.run "chown mysql:mysql /var/run/mysqld"

salt -C 'I@galera:master' cmd.run "service mysql bootstrap"
salt -C 'I@galera:slave' service.start mysql
