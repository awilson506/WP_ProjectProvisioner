set -o


echo  "
__        ______    ____                 _     _                       
\ \      / /  _ \  |  _ \ _ __ _____   _(_)___(_) ___  _ __   ___ _ __ 
 \ \ /\ / /| |_) | | |_) | '__/ _ \ \ / / / __| |/ _ \| '_ \ / _ \ '__|
  \ V  V / |  __/  |  __/| | | (_) \ V /| \__ \ | (_) | | | |  __/ |   
   \_/\_/  |_|     |_|   |_|  \___/ \_/ |_|___/_|\___/|_| |_|\___|_| 
"



read -p "Enter Domain Name for your DEV environment: " DOMAIN
echo " "

if test "$DOMAIN" == ""; then
	echo "$0: Domain is required " >&2
	exit 1;
fi

echo "Cloning Provisioner"
git clone git@github.com:ciaranmg/WP_ProjectProvisioner.git $DOMAIN
cd $DOMAIN


read -p "Enter repository URL (Enter for none) " REPO
echo " "

if test "$REPO" != ""; then
	echo "Cloning Project Repository"
	git clone $REPO document_root
else
	mkdir document_root
fi

read -p "Enter Database Name: " DBNAME
echo " "

read -p "Enter Database User: " DBUSER
echo " "

read -p "Enter Database Password: " DBPASS
echo " "

cat <<EOF | tee config.sh
BOX_IP="192.168.50.6"
DOMAIN="$DOMAIN"
MYSQL_ROOT_PASS="root"
DATABASE_NAME="$DBNAME"
DATABASE_USER="$DBUSER"
DATABASE_PASSWORD="$DBPASS"
EOF

