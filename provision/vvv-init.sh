#!/usr/bin/env bash

# Make a database, if we don't already have one
echo -e "\nCreating database 'yoast_acf_analysis_development' (if it's not already there)"
mysql -u root --password=root -e "CREATE DATABASE IF NOT EXISTS yoast_acf_analysis_development"
mysql -u root --password=root -e "GRANT ALL PRIVILEGES ON yoast_acf_analysis_development.* TO wp@localhost IDENTIFIED BY 'wp';"
echo -e "\n DB operations done.\n\n"

# Nginx Logs
mkdir -p ${VVV_PATH_TO_SITE}/log
touch ${VVV_PATH_TO_SITE}/log/error.log
touch ${VVV_PATH_TO_SITE}/log/access.log

cd ${VVV_PATH_TO_SITE}

noroot composer install

cd ${VVV_PATH_TO_SITE}/wp-content/plugins/yoast-acf-analysis
noroot composer install
noroot npm install

if [[ ! -d "${VVV_PATH_TO_SITE}/wp" ]]; then
  cp ${VVV_PATH_TO_SITE}/provision/.env.js ${VVV_PATH_TO_SITE}/wp-content/plugins/yoast-acf-analysis/tests/js/system/.env.js
fi

if ! $(noroot wp core is-installed); then
    noroot wp core install --url=yoast-acf-analysis.vvv.dev --title="Yoast ACF Analysis Development" --admin_name=admin --admin_email="admin@local.dev" --admin_password="password" --skip-email
    noroot wp plugin activate --all
    # This is needed because the test relies on at least one attachment existing
    noroot wp media import https://s.w.org/about/images/logos/wordpress-logo-notext-rgb.png
fi
