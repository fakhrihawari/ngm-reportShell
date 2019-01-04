# #######################################################
# #
# # Ubuntu LTS 14.04 (ubuntu/trusty64)
# # 
# # Description: ngm build script
# #  - nginx v1.4.6
# #  - git v1.9.1
# #  - node v0.12.9
# #  - npm v3.4.0
# #  - pm2 v2.2.3
# #  - sailsjs v0.11.4
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


######################################################## NPM UPDATES
sudo npm install -g n
sudo n 8.10.0
cd /home/ubuntu/nginx/www/ngm-reportEngine
sudo npm install sails-postgresql@0.11.4
sudo npm install async@2.6.1
sudo npm install --save bcrypt-nodejs
cd /home/ubuntu/nginx/www/ngm-reportHub
sudo npm install gulp-uglify-es --save-dev 
sudo npm install -g pm2@2.2.3 --allow-root
sudo pm2 update


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
echo -e "192.168.33.16:5432:immap_afg:ngmadmin:ngmadmin" | sudo tee ~/.pgpass
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
# sudo git clone https://github.com/pfitzpaddy/ngm-reportPrint.git


####################################################### ngm-ReportHub

## UPDATE TO YOUR FORKED REPO!
## https://help.github.com/articles/changing-a-remote-s-url/
# sudo git clone https://github.com/<your.fork>/ngm-reportHub.git


# build HUB app BOWER and NODE
cd /home/ubuntu/nginx/www/ngm-reportHub

## ONLINE
## node_modules
# wget https://www.dropbox.com/s/ie8l41wgvwe0xke/node_modules.zip?dl=1
# unzip node_modules.zip?dl=1
# sudo rm node_modules.zip\?dl\=1

## bower_components
# wget https://www.dropbox.com/s/5obb3lqo9el8my2/bower_components.zip?dl=1
# unzip bower_components.zip?dl=1
# sudo rm bower_components.zip\?dl\=1

## LOCAL
# node_modules
sudo cp ../data/config/reportHub/node_modules.zip /home/ubuntu/nginx/www/ngm-reportHub
unzip node_modules.zip
sudo rm node_modules.zip

# bower_components
sudo cp ../data/config/reportHub/bower_components.zip /home/ubuntu/nginx/www/ngm-reportHub
unzip bower_components.zip
sudo rm bower_components.zip



####################################################### ngm-ReportEngine

## UPDATE TO YOUR FORKED REPO!
## https://help.github.com/articles/changing-a-remote-s-url/
# sudo git clone https://github.com/<your.fork>/ngm-reportEngine.git

## build ENGINE app NODE
cd /home/ubuntu/nginx/www/ngm-reportEngine

## ONLINE
# wget https://www.dropbox.com/s/ie8l41wgvwe0xke/node_modules.zip?dl=1
# unzip node_modules.zip?dl=1
# sudo rm node_modules.zip\?dl\=1

## LOCAL
# node_modules
sudo cp ../data/config/reportEngine/node_modules.zip /home/ubuntu/nginx/www/ngm-reportEngine
unzip node_modules.zip
sudo rm node_modules.zip


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
		ngmEthCtcServer: {
			adapter: 'sails-mongo',
			host: 'localhost',
			port: 27017,
			// user: 'username',
			// password: 'password',
			database: 'ngmEthCtc',
			schema: false
		},
		ngmAfNutritionServer: {
			adapter: 'sails-mongo',
			host: 'localhost',
			port: 27017,
			// user: 'username',
			// password: 'password',
			database: 'ngmAfNutrition',
			schema: false
		},
		ngmiMMAPServer: {
			adapter: 'sails-mongo',
			host: 'localhost',
			port: 27017,
			// user: 'username',
			// password: 'password',
			database: 'ngmiMMAP',
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



############################ KOBO CONF
echo -e "
module.exports.kobo = {
	NUTRITION_KOBO_URL:'https://kc.humanitarianresponse.info/api/v1/data/226108?format=json',
	NUTRITION_KOBO_PK: 226108,
	NUTRITION_KOBO_USER:'nutritionaf',
	NUTRITION_KOBO_PASSWORD:'nutrition@12345af',
	CTC_KOBO_URL:'https://kc.humanitarianresponse.info/api/v1/data/181320?format=json',
	CTC_KOBO_PK: 181320,
	CTC_KOBO_USER:'pfitzpaddy',
	CTC_KOBO_PASSWORD:'P@trick7',
	EHA_KOBO_URL:'https://kc.humanitarianresponse.info/api/v1/data/106227?format=json',
	EHA_KOBO_PK: 106227,
	EHA_KOBO_USER:'eha',
	EHA_KOBO_PASSWORD:'ehaTeam1234',
};" | sudo tee /home/ubuntu/nginx/www/ngm-reportEngine/config/kobo.js

############################ GOOGLE CONF
echo -e "
module.exports.google = {
	PRODUCTS_DOC_ID:'1rpcHKu2BGmw-viVK9tp-aoON8P1HddDEVvZnw6Lfo68',
	PRODUCTS_API_KEY:'AIzaSyBAEOsvp2SBxxXFABenHzHBcqoGoqO_wvs',
};" | sudo tee /home/ubuntu/nginx/www/ngm-reportEngine/config/google.js



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
# sudo ln -s /etc/nginx/sites-available/default /etc/nginx/sites-enabled/default
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
mongorestore --drop -d ngmAfNutrition /home/ubuntu/data/mongo/ngmAfNutrition
mongorestore --drop -d ngmEpr /home/ubuntu/data/mongo/ngmEpr
mongorestore --drop -d ngmEthCtc /home/ubuntu/data/mongo/ngmEthCtc
mongorestore --drop -d ngmHealthCluster /home/ubuntu/data/mongo/ngmHealthCluster
mongorestore --drop -d ngmiMMAP /home/ubuntu/data/mongo/ngmiMMAP
mongorestore --drop -d ngmReportHub /home/ubuntu/data/mongo/ngmReportHub


# # import collection
mongoimport -d ngmHealthCluster -c activities --drop --headerline --type csv --file /home/ubuntu/data/csv/activities.csv
mongo
use ngmHealthCluster
db.getCollection('activities').find({activity_type_id:'hardware_materials_distribution'}).forEach(function (d) { if( d.kit_details.length ) { d.kit_details = JSON.parse(d.kit_details); db.getCollection('activities').save(d); } });
exit
# mongoimport -d ngmHealthCluster -c donors --drop --headerline --type csv --file /home/ubuntu/data/csv/donors.csv
# mongoimport -d ngmHealthCluster -c stockitems --drop --headerline --type csv --file /home/ubuntu/data/csv/stockitems.csv
# mongoimport -d ngmReportHub -c organizations --drop --headerline --type csv --file /home/ubuntu/data/csv/organizations.csv

# mongoimport -d ngmReportHub -c admin3facilities --drop --headerline --type csv --file /home/ubuntu/data/csv/et_admin3_health_centers.csv
# mongoimport -d ngmReportHub -c admin3facilities --headerline --type csv --file /home/ubuntu/data/csv/et_admin3_hospitals.csv
# mongoimport -d ngmReportHub -c admin3facilities --headerline --type csv --file /home/ubuntu/data/csv/et_admin3_idp_camps.csv

# # import admins
# mongoimport -d ngmReportHub -c admin1 --type json --file /home/ubuntu/data/json/sy_admin_1.json --jsonArray
# mongoimport -d ngmReportHub -c admin2 --type json --file /home/ubuntu/data/json/sy_admin_2.json --jsonArray
# mongoimport -d ngmReportHub -c admin3 --type json --file /home/ubuntu/data/json/sy_admin_3.json --jsonArray

# # # ethiopian health facilities
# # mongoimport -d ngmReportHub -c admin3sites --drop --file /home/ubuntu/data/json/admin3sites.json
# mongoimport -d ngmReportHub -c dutystation --drop --headerline --type csv --file /home/ubuntu/data/csv/dutystation.csv

# # # export CSV
# # mongoimport -d ngmHealthCluster -c reporthub_indicators_hct --drop --jsonArray --file /home/ubuntu/data/json/reporthub_indicators_hct.json
# mongoexport --db ngmReportHub  --collection user -q "{ 'admin0pcode': 'ET' }" --type=csv --fields id,admin0pcode,cluster,organization,username,name,position,phone,email,skype,visits,createdAt,updatedAt --out /home/ubuntu/data/csv/cdc/et_users.csv
# mongoexport --db ngmReportHub --collection admin1 -q "{ 'admin0pcode': 'ET' }" --type=csv --fields adminRpcode,adminRname,adminRtype_name,adminRlng,adminRlat,adminRzoom,admin0pcode,admin0name,admin0type_name,admin0lng,admin0lat,admin0zoom,admin1pcode,admin1name,admin1type_name,admin1lng,admin1lat,admin1zoom --out /home/ubuntu/data/csv/cdc/duty_station.csv
# mongoexport --db ngmReportHub --collection admin1 -q "{ 'admin0pcode': 'CD' }" --type=csv --fields adminRpcode,adminRname,adminRtype_name,adminRlng,adminRlat,adminRzoom,admin0pcode,admin0name,admin0type_name,admin0lng,admin0lat,admin0zoom,admin1pcode,admin1name,admin1type_name,admin1lng,admin1lat,admin1zoom --out /home/ubuntu/data/csv/cdc/cd_duty_station.csv

# mongoexport --db ngmReportHub --collection admin3sites -q "{ 'site_type_id': 'idp_site' }" --type=csv --fields admin0lat,admin0lng,admin0name,admin0pcode,admin0type,admin0zoom,admin1lng,admin1lat,admin1name,admin1pcode,admin1type,admin1zoom,admin2lat,admin2lng,admin2name,admin2pcode,admin2type,admin3lat,admin3lng,admin3name,admin3pcode,admin3type,admin3zoom,adminRlat,adminRlng,adminRname,adminRpcode,adminRtype_name,adminRzoom,site_class,site_id,site_lat,site_lng,site_name,site_status,site_type_name, --out /home/ubuntu/data/csv/sites/idp_sites.csv

# # trainings
# mongoexport --db ngmHealthCluster  --collection trainingparticipants  --type=csv --fields adminRpcode,adminRname,admin0pcode,admin0name,organization_id,organization_tag,organization,implementing_partners,cluster_id,cluster,name,position,phone,email,username,project_id,project_acbar_partner,project_hrp_code,project_code,project_status,project_title,project_description,project_start_date,project_end_date,project_budget,project_budget_currency,mpc_purpose,mpc_purpose_cluster_id,inter_cluster_activities,project_donor,strategic_objectives,report_id,report_active,report_status,report_month,report_year,report_submitted,reporting_period,reporting_due_date,training_id,training_title,training_topics,training_start_date,training_end_date,training_days_number,training_conducted_by,training_supported_by,trainee_affiliation_id,trainee_affiliation_name,trainee_health_worker_id,trainee_health_worker_name,trainee_men,trainee_women,location_id,admin1pcode,admin1name,admin2pcode,admin2name,admin3pcode,admin3name,facility_id,facility_class,facility_status,facility_implementation_id,facility_implementation_name,facility_type_id,facility_type_name,facility_name,facility_hub_id,facility_hub_name,conflict,admin1lng,admin1lat,admin2lng,admin2lat,admin3lat,facility_lng,facility_lat --out /home/ubuntu/data/csv/trainings/trainingparticipants.csv

# mongoexport --db ngmReportHub  --collection admin1 -q '{ admin0pcode: "ET" }' --type=csv --fields admin1pcode,admin1name --out /home/ubuntu/data/csv/ethiopia/admin1Et.csv
# mongoexport --db ngmReportHub  --collection admin2 -q '{ admin0pcode: "ET" }' --type=csv --fields admin2pcode,admin2name,admin1pcode --out /home/ubuntu/data/csv/ethiopia/admin2Et.csv
# mongoexport --db ngmReportHub  --collection admin3 -q '{ admin0pcode: "ET" }' --type=csv --fields admin3pcode,admin3name,admin1pcode,admin2pcode, --out /home/ubuntu/data/csv/ethiopia/admin3Et.csv
# mongoexport --db ngmReportHub  --collection admin3sites -q '{ admin0pcode: "ET" }' --type=csv --fields admin1pcode,admin1name,admin2pcode,admin2name,admin3pcode,admin3name,facility_id,facility_type,facility_name --out /home/ubuntu/data/csv/ethiopia/sitesEt.csv

# CD
# mongoimport -d ngmReportHub -c admin1 --type json --file /home/ubuntu/data/admins/CD/json/cd_admin_1.json --jsonArray
# mongoimport -d ngmReportHub -c admin2 --type json --file /home/ubuntu/data/admins/CD/json/cd_admin_2.json --jsonArray

# SS
# mongoimport -d ngmHealthCluster -c activities --drop --headerline --type csv --file /home/ubuntu/data/csv/activities.csv
# mongoimport -d ngmReportHub -c admin1 --type json --file /home/ubuntu/data/admins/SS/ss_admin_1.json --jsonArray
# mongoimport -d ngmReportHub -c admin2 --type json --file /home/ubuntu/data/admins/SS/ss_admin_2.json --jsonArray



## START THE ENGINE!
# cd /home/ubuntu/nginx/www/ngm-reportEngine
# sudo sails lift



