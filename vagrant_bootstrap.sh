#!/usr/bin/env bash

# Configuration
echo "--- Setting configuration variables ---"

source config.sh

echo "--- Updating packages list ---"
sudo apt-get update

echo "--- Set up MySQL ---"
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password password $MYSQL_ROOT_PASS"
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password_again password $MYSQL_ROOT_PASS"


echo "--- Installing base packages ---"
sudo apt-get install -y vim curl python-software-properties

echo "--- Updating packages list ---"
sudo apt-get update

echo "--- We want the bleeding edge of PHP ---"
sudo add-apt-repository -y ppa:ondrej/php5

echo "--- Updating packages list ---"
sudo apt-get update

echo "--- Installing PHP-specific packages ---"
sudo apt-get install -y php5 apache2 libapache2-mod-php5 php5-curl php5-gd php5-mcrypt mysql-server-5.5 php5-mysql git-core zsh

echo "--- Installing and configuring Xdebug ---"
sudo apt-get install -y php5-xdebug

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

echo "--- Enabling mod-rewrite ---"
sudo a2enmod rewrite

# echo "--- Setting document root ---"
# sudo sudo rm -rf /var/www
# sudo sudo ln -fs /vagrant/public /var/www

echo "--- Enable colors on console --- "
sed -i 's/#force_color_prompt/force_color_prompt/g' ~/.bashrc
curl -L http://install.ohmyz.sh | sh

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


echo "--- Shell Settings ---"
export PATH=$PATH:vendor/bin

echo "--- Mounting the database ---"
echo "CREATE DATABASE ${DATABASE_NAME};" | mysql -u root -proot
echo "GRANT USAGE ON *.* to ${DATABASE_USER}@localhost identified by '$DATABASE_PASSWORD';" | mysql -u root -p${MYSQL_ROOT_PASS}
echo "GRANT ALL PRIVILEGES ON ${DATABASE_NAME}.* to ${DATABASE_USER}@localhost;" | mysql -u root -p${MYSQL_ROOT_PASS}
mysql -u root -p${MYSQL_ROOT_PASS} ${DATABASE_NAME} < /vagrant/data/database_dump.sql


echo "--- Done ---"
echo "You will need to add $BOX_IP $DOMAIN to your hosts file"
