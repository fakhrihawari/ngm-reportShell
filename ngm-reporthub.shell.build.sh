# #######################################################
# #
# # Ubuntu LTS 14.04 (ubuntu/trusty64)
# # 
# # Description: ngm build script
# #  - nginx v1.4.6
# #  - git v1.9.1
# #  - node v0.12.9
# #  - npm v3.4.0
# #  - pm2 v0.15.10
# #  - sailsjs v0.11.2
# #  - sails-postgresql
# #  - bower v1.6.5
# #  - grunt v0.4.x
# #  - grunt-cli v0.1.13
# #  - mongodb v3.0.7
# #  - Postgresql v9.3 + PostGIS + v2.1
# #
# # Notes: 
# #  - To create ppk:$ puttygen ngm.pem -o ngm.ppk -O private
# #
# # Steps: 
# #		1) Launch AWS Instance
# #		2) Copy Postgresql immap_afg.gz to /home/ubuntu/data
# #		3) Copy MongoDB lists to /home/ubuntu/data
# #		4) Run this script!
# #
# #######################################################

# refresh cache
echo "------------ Update repos ------------" 
sudo apt-get update
# build essential
echo "------------ Build essential ------------" 
sudo apt-get install -y gcc make build-essential checkinstall zip



####################################################### APT-GET INSTALLS
# nodejs
echo "------------ Get NodeJS 0.12 ------------" 
# v0.12.15
curl -sL https://deb.nodesource.com/setup_0.12 | sudo bash
echo "------------ Install NodeJS ------------" 
sudo apt-get install -y nodejs
echo "------------ Install Nginx ------------" 
sudo apt-get install -y nginx
echo "------------ Install Git ------------" 
sudo apt-get install -y git


####################################################### UPDATE NODE
# sudo npm cache clean -f
# sudo npm install -g n
# sudo n stable

######################################################## NPM FIX PERMISSIONS
# echo "------------ Make npm directory ------------" 
# mkdir ~/.npm
# sudo chown -R $USER:$GROUP ~/.npm
# mkdir ~/.node-gyp
# sudo chown -R $USER:$GROUP ~/.node-gyp



######################################################## NPM INSTALLS
echo "------------ npm install npm ------------" 
sudo npm install -g npm@3.4.0
npm -v
echo "------------ npm install gulp ------------" 
sudo npm install -g gulp@3.9.1
gulp -v
echo "------------ npm install pm2 ------------" 
sudo npm install -g pm2@0.15.10
pm2 -v
echo "------------ npm install sails + postgresql ------------"
sudo npm install -g --unsafe-perm sails@0.11.2
sudo npm install -g sails-postgresql@0.11.2
sails -v
echo "------------ npm install bower ------------" 
sudo npm install -g bower@1.6.5
bower -v
echo "------------ npm grunt ------------" 
sudo npm install -g grunt@0.4.5
sudo npm install -g grunt-cli@0.1.13



####################################################### Python 
echo "------------ Install Python ------------"
sudo apt-get install -y python2.7-dev
sudo apt-get install -y libpq-dev
sudo apt-get install -y python-pip
sudo apt-get install -y python-numpy
sudo pip install pandas
sudo pip install --upgrade pandas
sudo pip install sqlalchemy
sudo pip install psycopg2
sudo pip install xlrd



####################################################### Phantomjs
echo "------------ Install PhantomJS ------------"
sudo apt-get install -y build-essential g++ flex bison gperf ruby perl libsqlite3-dev libfontconfig1-dev libicu-dev libfreetype6 libssl-dev libpng-dev libjpeg-dev python libx11-dev libxext-dev
cd /usr/local/share/
sudo git clone https://github.com/pfitzpaddy/ubuntu-lts-14.04-phantomjs2.git
sudo cp /usr/local/share/ubuntu-lts-14.04-phantomjs2/phantomjs /usr/bin/phantomjs
phantomjs -v



# ####################################################### PostGIS
echo "------------ Install Postgresql ------------" 
sudo apt-get install -y postgresql-9.3-postgis-2.1 postgresql-contrib
# create user
sudo -u postgres psql -c "CREATE ROLE ngmadmin WITH LOGIN SUPERUSER PASSWORD 'ngmadmin';"
sudo -u postgres psql -c "CREATE DATABASE immap_afg WITH OWNER ngmadmin;"
sudo -u postgres psql -d immap_afg -c "CREATE EXTENSION postgis;"

# add pgpass for command line access
echo -e "localhost:5432:immap_afg:ngmadmin:ngmadmin" | sudo tee ~/.pgpass
sudo chmod 0600 ~/.pgpass

# udpate listen_addresses
sudo sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/g" /etc/postgresql/9.3/main/postgresql.conf
# update pg_hba.conf
sudo sed -i '$a host    all             all             0.0.0.0/0               md5' /etc/postgresql/9.3/main/pg_hba.conf
# restart
sudo /etc/init.d/postgresql restart



####################################################### MongoDB
echo "------------ Install MongoDB ------------" 
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 7F0CEB10
echo "deb http://repo.mongodb.org/apt/ubuntu trusty/mongodb-org/3.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-3.0.list
sudo apt-get update
sudo apt-get install -y mongodb-org

# LISTEN TO
sudo sed -i 's@bindIp: 127.0.0.1@#bindIp: 127.0.0.1@g' /etc/mongod.conf
sudo service mongod restart


####################################################### Applications folder
sudo mkdir /home/ubuntu/nginx
sudo mkdir /home/ubuntu/nginx/www
sudo chown ubuntu /home/ubuntu/nginx/www -R



####################################################### ngm-ReportPrint
cd /home/ubuntu/nginx/www
sudo git clone https://github.com/pfitzpaddy/ngm-reportPrint.git



####################################################### ngm-ReportHub
cd /home/ubuntu/nginx/www

# UPDATE TO YOUR FORKED REPO!
sudo git clone https://github.com/<your.fork>/ngm-reportHub.git

# build Hub app
cd /home/ubuntu/nginx/www/ngm-reportHub
sudo npm install --allow-root
# sudo bower ( lib dependices conflict )
wget https://www.dropbox.com/s/5obb3lqo9el8my2/bower_components.zip?dl=1
unzip bower_components.zip?dl=1
sudo rm bower_components.zip\?dl\=1
sudo gulp



####################################################### ngm-ReportEngine
cd /home/ubuntu/nginx/www

# UPDATE TO YOUR FORKED REPO!
sudo git clone https://github.com/<your.fork>/ngm-reportEngine.git

# build sails app
cd /home/ubuntu/nginx/www/ngm-reportEngine
# sudo bower ( lib dependices conflict )
wget https://www.dropbox.com/s/ie8l41wgvwe0xke/node_modules.zip?dl=1
unzip node_modules.zip?dl=1
sudo rm node_modules.zip\?dl\=1


# connection config sails li
echo -e "/**
 * Local environment settings
 *
 * For more information, check out:
 */

module.exports = {
	connections: {
		ngmReportHubServer: {
			adapter: 'sails-mongo',
			host: 'localhost',
			port: 27017,
			// user: 'username',
			// password: 'password',
			database: 'ngmReportHub',
			schema: true
		},
		ngmHealthClusterServer: {
			adapter: 'sails-mongo',
			host: 'localhost',
			port: 27017,
			// user: 'username',
			// password: 'password',
			database: 'ngmHealthCluster',
			schema: true
		},
		ngmEprServer: {
			adapter: 'sails-mongo',
			host: 'localhost',
			port: 27017,
			// user: 'username',
			// password: 'password',
			database: 'ngmEpr',
			schema: false
		},
		ngmPostgreServer: {
			adapter: 'sails-postgresql',
			host: 'localhost',
			port: 5432,
			user: 'ngmadmin',
			password: 'ngmadmin',
			database: 'immap_afg'
		}
	}
}" | sudo tee /home/ubuntu/nginx/www/ngm-reportEngine/config/local.js



# ####################################################### Nginx
# update nginx conf
echo "------------ Configure Nginx ------------"
cd /etc/nginx/sites-available/
sudo sed -i "s/sendfile on;/sendfile off;/g" /etc/nginx/nginx.conf
# update nginx web default conf
echo -e "##
# You should look at the following URL's in order to grasp a solid understanding
# of Nginx configuration files in order to fully unleash the power of Nginx.
# http://wiki.nginx.org/Pitfalls
# http://wiki.nginx.org/QuickStart
# http://wiki.nginx.org/Configuration
#
# Generally, you will want to move this file somewhere, and start with a clean
# file but keep this around for reference. Or just disable in sites-enabled.
#
# Please see /usr/share/doc/nginx-doc/examples/ for more detailed examples.
##

server {
\tsendfile off;
\tlisten 80 default_server;
\tlisten [::]:80 default_server ipv6only=on;

\tserver_name vm.reporthub.immap.org;

\troot /home/ubuntu/nginx/www/ngm-reportHub/app/promo/;

\tlocation / {
\t\ttry_files \$uri \$uri/ /index.html;
\t}

\tlocation /desk {
\t\talias /home/ubuntu/nginx/www/ngm-reportHub/app/;
\t\ttry_files \$uri \$uri/ /index.html;
\t}

\tlocation /desk/ {
\t\talias /home/ubuntu/nginx/www/ngm-reportHub/app/;
\t\ttry_files \$uri \$uri/ /index.html;
\t}

\tlocation /desk/bower_components {
\t\talias /home/ubuntu/nginx/www/ngm-reportHub/bower_components/;
\t}
\tlocation /desk/bower_components/ {
\t\talias /home/ubuntu/nginx/www/ngm-reportHub/bower_components/;
\t}

\tlocation /scripts/ {
\t\talias /home/ubuntu/nginx/www/ngm-reportHub/app/scripts/;
\t\t}

\tlocation /views/ {
\t\talias /home/ubuntu/nginx/www/ngm-reportHub/app/views/;
\t}

\tlocation /report/ {
\t\talias /home/ubuntu/nginx/www/ngm-reportPrint/pdf/; 
\t}

\tlocation /api/ {
\t\tproxy_bind \$server_addr;
\t\tproxy_pass http://127.0.0.1:1337/;
\t\tproxy_http_version 1.1;
\t\tproxy_set_header Upgrade \$http_upgrade;
\t\tproxy_set_header Connection 'upgrade';
\t\tproxy_set_header Host \$host;
\t\tproxy_set_header Access-Control-Allow-Origin *;
\t\tproxy_cache_bypass \$http_upgrade;
\t\t}

}" | sudo tee /etc/nginx/sites-available/default
# symb link
sudo ln -s /etc/nginx/sites-available/default /etc/nginx/sites-enabled/default
# reload configuration
sudo service nginx restart


###################################################### Postgresql Backup/Restore
# echo "------------ Backup Postgresql ------------"
# cd /home/ubuntu/data/postgres
# pg_dump immap_afg -U ngmadmin -h localhost | gzip > immap_afg.gz

echo "------------ Restore Postgresql ------------"
sudo gunzip -c /home/ubuntu/data/postgres/immap_afg.gz | psql -U ngmadmin -h localhost -d immap_afg


####################################################### MongoDB export
# backup mongodb scripts
# mongodump --out /home/ubuntu/data/mongo/dump


# restore mongodb scripts
mongorestore --drop -d ngmReportHub /home/ubuntu/data/mongo/ngmReportHub
mongorestore --drop -d ngmHealthCluster /home/ubuntu/data/mongo/ngmHealthCluster
mongorestore --drop -d ngmEpr /home/ubuntu/data/mongo/ngmEpr


# import collection
mongoimport -d ngmHealthCluster -c activities --drop --headerline --type csv --file /home/ubuntu/data/csv/activities.csv
mongoimport -d ngmHealthCluster -c donors --drop --headerline --type csv --file /home/ubuntu/data/csv/donors.csv
mongoimport -d ngmHealthCluster -c stockitems --drop --headerline --type csv --file /home/ubuntu/data/csv/stockitems.csv
mongoimport -d ngmReportHub -c organizations --drop --headerline --type csv --file /home/ubuntu/data/csv/organizations.csv

# # ethiopian health facilities
# mongoimport -d ngmReportHub -c admin3facilities --drop --file /home/ubuntu/data/json/admin3facilities.json
# # export CSV
# mongoimport -d ngmHealthCluster -c reporthub_indicators_hct --drop --jsonArray --file /home/ubuntu/data/json/reporthub_indicators_hct.json
# mongoexport --db ngmHealthCluster --collection reporthub_indicators_hct --type=csv --fields id,title,districts,white_area_districts,idp_districts,wa_idp_districts,bphs_districts,bphs_services,hc_districts,hc_services,categories,bphs_data,hc_data --out /home/ubuntu/data/json/reporthub_indicators_hct.csv



