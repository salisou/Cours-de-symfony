#!/bin/sh
set -e
sleep 15
echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
echo ">>>>>>>>>>>>>>>>>> PHP >>>>>>>>>>>>>>>>>>>>>>"
echo ">>>>>>>>>>>>> docker-entrypoint >>>>>>>>>>>>>"
echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"

mkdir -p var/cache var/log
#setfacl -R -m u:www-data:rwX -m u:"$(whoami)":rwX var
#setfacl -dR -m u:www-data:rwX -m u:"$(whoami)":rwX var

cp -f .env.dev .env

composer clear-cache

COMPOSER_MEMORY_LIMIT=-1 composer install --prefer-dist --no-progress --no-suggest --no-interaction

php bin/console cache:clear --env=dev
# php bin/console redis:flushall -n --env=dev

php bin/console doctrine:schema:drop --force --no-interaction
php bin/console doctrine:schema:update --force --no-interaction
#php bin/console messenger:consume async -vv --time-limit=1
#php bin/console doctrine:fixtures:load --group=dev -n --env=dev

php bin/console assets:install

# Permissions hack because setfacl does not work on Mac and Windows
chown -R www-data var

#exec docker-php-entrypoint "$@"
exec /usr/bin/supervisord -c /docker/php/supervisor.conf
