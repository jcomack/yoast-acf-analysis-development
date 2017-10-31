#!/usr/bin/env bash

# Variables to use for proper provisioning.
DOMAIN=`get_primary_host "${VVV_SITE_NAME}".test`
DOMAINS=`get_hosts "${DOMAIN}"`
SITE_TITLE=`get_config_value 'site_title' "${DOMAIN}"`
WP_VERSION=`get_config_value 'wp_version' 'latest'`
WP_TYPE=`get_config_value 'wp_type' "single"`
DB_NAME=`get_config_value 'db_name' "${VVV_SITE_NAME}"`
DB_NAME=${DB_NAME//[\\\/\.\<\>\:\"\'\|\?\!\*-]/}

# Make a database, if we don't already have one.
echo -e "\nCreating database '${DB_NAME}' (if it's not already there)"
mysql -u root --password=root -e "CREATE DATABASE IF NOT EXISTS ${DB_NAME}"
mysql -u root --password=root -e "GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO wp@localhost IDENTIFIED BY 'wp';"
echo -e "\n DB operations done.\n\n"

# Nginx Logs
mkdir -p ${VVV_PATH_TO_SITE}/log
touch ${VVV_PATH_TO_SITE}/log/error.log
touch ${VVV_PATH_TO_SITE}/log/access.log

# Install and configure the latest stable version of WordPress
if [[ ! -f "${VVV_PATH_TO_SITE}/public_html/wp-load.php" ]]; then
    echo "Downloading WordPress..."
	noroot wp core download --version="${WP_VERSION}"
    echo "Downloading WordPress complete"
fi

if [[ ! -f "${VVV_PATH_TO_SITE}/public_html/wp-config.php" ]]; then
  echo "Configuring WordPress Stable..."
  noroot wp core config --dbname="${DB_NAME}" --dbuser=wp --dbpass=wp --quiet --extra-php <<PHP
define( 'WP_DEBUG', true );
PHP
  echo "Configuring WordPress complete"
fi

if ! $(noroot wp core is-installed); then
  echo "Installing WordPress Stable..."

  if [ "${WP_TYPE}" = "subdomain" ]; then
    INSTALL_COMMAND="multisite-install --subdomains"
  elif [ "${WP_TYPE}" = "subdirectory" ]; then
    INSTALL_COMMAND="multisite-install"
  else
    INSTALL_COMMAND="install"
  fi

  noroot wp core ${INSTALL_COMMAND} --url="${DOMAIN}" --quiet --title="${SITE_TITLE}" --admin_name=admin --admin_email="admin@local.test" --admin_password="password" --skip-email

  # This is needed because the test relies on at least one attachment existing
  noroot wp media import https://s.w.org/about/images/logos/wordpress-logo-notext-rgb.png
  echo "WordPress installation complete"

  echo "Installing necessary plugins..."
  cd ${VVV_PATH_TO_SITE}
  noroot composer install -q
  echo "Installing necessary plugins complete"

  echo "Installing Yoast ACF Analysis dependencies..."
  cd ${VVV_PATH_TO_SITE}/public_html/wp-content/plugins/yoast-acf-analysis
  noroot composer install -q
  echo "Installing dependencies complete"

  echo "Installing Node dependencies"
  noroot npm install
  echo "Installing Node dependencies complete"

  echo "Configuring Yoast ACF Analysis..."
  cp ${VVV_PATH_TO_SITE}/provision/.env.js ${VVV_PATH_TO_SITE}/public_html/wp-content/plugins/yoast-acf-analysis/tests/js/system/.env.js
  cp ${VVV_PATH_TO_SITE}/public_html/wp-content/plugins/yoast-acf-analysis/tests/js/system/nightwatch.conf.example.js ${VVV_PATH_TO_SITE}/public_html/wp-content/plugins/yoast-acf-analysis/tests/js/system/nightwatch.conf.js

  sed -i "s#{{DOMAIN}}#http://${DOMAINS}#" "${VVV_PATH_TO_SITE}/public_html/wp-content/plugins/yoast-acf-analysis/tests/js/system/nightwatch.conf.js"
  echo "Configuring complete"

  noroot wp plugin activate --all
else
  echo "Updating WordPress Stable..."
  cd ${VVV_PATH_TO_SITE}/public_html

  noroot wp core update --version="${WP_VERSION}"
fi

sed -i "s#{{DOMAINS_HERE}}#${DOMAINS}#" "${VVV_PATH_TO_SITE}/provision/vvv-nginx.conf"
