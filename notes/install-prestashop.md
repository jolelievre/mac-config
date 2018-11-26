Install test datas

# Clean up needed for StarterTheme tests
mysql -u root -e "DROP DATABASE IF EXISTS \`prestashop-develop\`;"

echo "* Installing PrestaShop, this may take a while ...";
php install-dev/index_cli.php \
	--language=en \
	--country=fr \
	--domain=local.prestashop-develop \
	--base_uri=/ \
	--db_server=127.0.0.1 \
	--db_user=root \
	--db_name=prestashop-develop \
	--db_create=1 \
	--firstname=Jo \
	--lastname=LELIEVRE \
	--name="Prestashop develop" \
	--email=jonathan.lelievre@prestashop.com \
	--password=prestashop
