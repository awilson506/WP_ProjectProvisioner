#!/usr/bin/env bash

# Configuration
echo "
---------------------------------------------------------------------------------
|                                                                               |
|                         Setting configuration variables                       |
|                                                                               |
---------------------------------------------------------------------------------
"

source config.sh

echo "
---------------------------------------------------------------------------------
|                                                                               |
|                          Updating packages list                               |
|                                                                               |
---------------------------------------------------------------------------------
"
sudo touch /home/vagrant/provision_log.log
sudo apt-get update >> /home/vagrant/provision_log.log

echo "
---------------------------------------------------------------------------------
|                                                                               |
|                              Configure MySQL                                  |
|                                                                               |
---------------------------------------------------------------------------------
"
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password password $MYSQL_ROOT_PASS"
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password_again password $MYSQL_ROOT_PASS"


echo "
---------------------------------------------------------------------------------
|                                                                               |
|                          Installing base packages                             |
|                                                                               |
---------------------------------------------------------------------------------
"
sudo apt-get install -y vim curl python-software-properties >> /home/vagrant/provision_log.log

echo "
---------------------------------------------------------------------------------
|                                                                               |
|                          Updating packages list                               |
|                                                                               |
---------------------------------------------------------------------------------
"
sudo apt-get update >> /home/vagrant/provision_log.log

sudo add-apt-repository -y ppa:ondrej/php5 >> /home/vagrant/provision_log.log

sudo apt-get update >> /home/vagrant/provision_log.log

echo "
---------------------------------------------------------------------------------
|                                                                               |
|                        Installing PHP and Xdebug                              |
|                                                                               |
---------------------------------------------------------------------------------
"
sudo apt-get install -y php5 apache2 libapache2-mod-php5 php5-curl php5-gd php5-mcrypt mysql-server-5.5 php5-mysql git-core zsh >> /home/vagrant/provision_log.log

sudo apt-get install -y php5-xdebug >> /home/vagrant/provision_log.log

cat << EOF | sudo tee -a /etc/php5/mods-available/xdebug.ini
xdebug.cli_color=1
xdebug.show_local_vars=1
xdebug.default_enable=1
xdebug.idekey = "vagrant"
xdebug.remote_enable = 1
xdebug.remote_autostart = 0
xdebug.remote_port = 9000
xdebug.remote_handler=dbgp
xdebug.remote_log="/home/vagrant/xdebug.log"
xdebug.remote_host=10.0.2.2 ; IDE-Environments IP, from vagrant box.
EOF

echo "
---------------------------------------------------------------------------------
|                                                                               |
|                             Setting up Apache                                 |
|                                                                               |
---------------------------------------------------------------------------------
"

sudo a2enmod rewrite


echo "--- Set apache host name --- "
cat << EOF | sudo tee /etc/apache2/httpd.conf
ServerName localhost
EOF

echo "--- Turn on PHP error reporting. ---"
sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php5/apache2/php.ini
sed -i "s/display_errors = .*/display_errors = On/" /etc/php5/apache2/php.ini

sed -i 's/AllowOverride None/AllowOverride All/' /etc/apache2/apache2.conf

echo "--- Configure Apache Virtual host---"

cat <<EOF |sudo tee  /etc/apache2/sites-available/$DOMAIN.conf
    <VirtualHost *:80>

    DocumentRoot /vagrant

    ServerName $DOMAIN

    ErrorLog /home/vagrant/error.log
    CustomLog /home/vagrant/access.log combined

    <Directory /vagrant/>
        AllowOverride All
        Order Allow,Deny
        Allow from all
        Require all granted
    </Directory>
    SetEnv APPLICATION_ENV dev
</VirtualHost>
EOF

sudo a2ensite $DOMAIN.conf

echo "--- Restarting Apache ---"
sudo service apache2 restart



echo "
---------------------------------------------------------------------------------
|                                                                               |
|                            Configuring Terminal                               |
|                                                                               |
---------------------------------------------------------------------------------
"

sed -i 's/#force_color_prompt/force_color_prompt/g' ~/.bashrc
sudo curl -L http://install.ohmyz.sh | sh

export PATH=$PATH:vendor/bin


echo "
---------------------------------------------------------------------------------
|                                                                               |
|                            Configuring the database                           |
|                                                                               |
---------------------------------------------------------------------------------
"
echo "CREATE DATABASE ${DATABASE_NAME};" | mysql -u root -proot
echo "GRANT USAGE ON *.* to ${DATABASE_USER}@localhost identified by '$DATABASE_PASSWORD';" | mysql -u root -p${MYSQL_ROOT_PASS}
echo "GRANT ALL PRIVILEGES ON ${DATABASE_NAME}.* to ${DATABASE_USER}@localhost;" | mysql -u root -p${MYSQL_ROOT_PASS}

if [ -f /home/vagrant/data/database_dump.sql ]; then

echo "
---------------------------------------------------------------------------------
|                                                                               |
|                            Mounting the database                              |
|                                                                               |
---------------------------------------------------------------------------------
"
    mysql -u root -p${MYSQL_ROOT_PASS} ${DATABASE_NAME} < /home/vagrant/data/database_dump.sql
fi

echo "
---------------------------------------------------------------------------------
|                                                                               |
|                                    Done                                       |
|          You will need to add $BOX_IP $DOMAIN to your hosts file              |
|                                                                               |
---------------------------------------------------------------------------------
"

