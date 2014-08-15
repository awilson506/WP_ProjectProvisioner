#!/usr/bin/env bash
#
source config.sh


vagrant ssh -c "mysql -u root -p${MYSQL_ROOT_PASS} ${DATABASE_NAME} < /vagrant/data/database_dump.sql"