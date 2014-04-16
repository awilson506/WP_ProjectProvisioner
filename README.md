# Wordpress Project Provisioner

Creates a project folder and prepares a vagrant setup for quick and easy local development setup.

Your wordpress project can be found in *document_root* You can work in here, and commit/push/pull as you need without messy vagrant files getting in the way.

# Instructions

1. Clone this repository using `git clone git@github.com:ciaranmg/WP_ProjectProvisioner.git [YOUR PROJECT NAME]`
2. Run installer.sh
3. It will ask you for:
  1. The domain you want your local dev site to be configured on
  2. The git repository for your project
  3. Database name
  4. Database User
  5. Database password
4. Then do the following:
  1. Copy a database dump, or sample database into the *data* folder. Make sure to call the file database_dump.sql
 

## What will happen

1. Your project will be cloned into the folder *document_root*
2. The latest version of wordpress will be cloned into *document_root/wp*
3. A local-config.php file will be created in *document_root*
4. A config.sh file will be created with your domain name, and database info for the vagrant provisioner

# Running Vagrant

1. Type `vagrant up` from your project folder
2. Vagrant will boot a virtual machine and provision it using vagrant_bootstrap.sh
3. If you have a database_dump.sql file in the data folder, that will be imported into the DB on the vagrant machine.
4. Once Vagrant has booted, you will see a message to update your hosts file to access the site.

