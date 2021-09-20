#!/usr/bin/env bash

#WORKDIR=$(docker-compose --file docker-compose.yml run --rm -u utente php pwd)
WORKDIR=/var/www
PROJECT_NAME=$(basename $(pwd) | tr  '[:upper:]' '[:lower:]')
COMPOSE_OVERRIDE=

#isPhpServiceUp() {
#
#    IS_RUNNING=`docker-compose \
#        --file docker-compose.yml \
#        ${COMPOSE_OVERRIDE} \
#        -p ${PROJECT_NAME} \
#        ps -q php`
#
#    if [[ "$IS_RUNNING" != "" ]]; then
#        return 1
#    fi
#}

copyHostData() {

    mkdir -p app/config/jwt
    openssl genrsa -passout pass:134170ec040d3cddaa43979485d9579e -out ../app/config/jwt/private.pem -aes256 4096
    openssl rsa -pubout -passin pass:134170ec040d3cddaa43979485d9579e -in ../app/config/jwt/private.pem -out ../app/config/jwt/public.pem

    openssl req -x509 -nodes -days 365 -newkey rsa:2048 -subj "/C=US/ST=Ferrara/L=Ferrara/O=DotEnv Test Certificate/CN=127.0.0.1" -keyout nginx/ssl/domain.key -out nginx/ssl/domain.crt

    mkdir -p php/git/
    cp .git/config php/git/

    if [[ ! -d php/ssh ]]; then
        mkdir -p php/ssh
    fi
    cp ~/.ssh/id_rsa php/ssh/
    cp ~/.ssh/id_rsa.pub php/ssh/
    cp ~/.ssh/known_hosts php/ssh/
}

echo "Run command $1 for ${PROJECT_NAME}"

if [[ -f "docker-compose.override.yml" ]]; then
    COMPOSE_OVERRIDE="--file docker-compose.override.yml"
fi


if [[ "$1" = "up" ]]; then

    shift 1

    docker-compose \
        --file docker-compose.yml \
        --env-file .env \
        ${COMPOSE_OVERRIDE} \
        -p ${PROJECT_NAME} \
        up -d --force-recreate  --remove-orphans

elif [[ "$1" = "build" ]]; then

    shift 1

    copyHostData

    docker-compose \
        --file docker-compose.yml \
        --env-file .env \
        ${COMPOSE_OVERRIDE} \
        -p ${PROJECT_NAME} \
        build

elif [[ "$1" = "enter" ]]; then

    docker exec -it "ad-api_dotenvrepo_php" /bin/bash

elif [[ "$1" = "messenger-send" ]]; then

    docker exec -it "${PROJECT_NAME}_dotenvrepo_php" sh -c "bin/console app:messages:test"
    #docker exec -it "${PROJECT_NAME}_dotenvrepo_php" sh -c "bin/console messenger:consume async -vv --time-limit=60"

elif [[ "$1" = "messenger-consume" ]]; then
    docker exec -it "${PROJECT_NAME}_dotenvrepo_php" sh -c "bin/console messenger:consume async -vv --time-limit=60"
elif [[ "$1" = "test" ]]; then

    echo "Cache clear"
    docker exec -it  "${PROJECT_NAME}_dotenvrepo_php" sh -c "bin/console cache:clear --env=test"
    docker exec -it  "${PROJECT_NAME}_dotenvrepo_php" sh -c "bin/console redis:flushall -n --env=test"

    echo "Create JWT Token"
    docker exec -it  "${PROJECT_NAME}_dotenvrepo_php" sh -c "mkdir -p var/test/jwt"
    docker exec -it  "${PROJECT_NAME}_dotenvrepo_php" sh -c "openssl genrsa -out var/test/jwt/private.pem -aes256 -passout pass:vendend-ad-test 4096"
    docker exec -it  "${PROJECT_NAME}_dotenvrepo_php" sh -c "openssl rsa -pubout -in var/test/jwt/private.pem -passin pass:vendend-ad-test -out var/test/jwt/public.pem"


    echo "Creating database"
    docker exec -it  "${PROJECT_NAME}_dotenvrepo_php" sh -c "bin/console doctrine:database:drop --force --env=test"
    docker exec -it  "${PROJECT_NAME}_dotenvrepo_php" sh -c "bin/console doctrine:database:create --env=test"
    docker exec -it  "${PROJECT_NAME}_dotenvrepo_php" sh -c "bin/console doctrine:schema:update --force --env=test"
    echo "Run phpStan"
    docker exec -it  "${PROJECT_NAME}_dotenvrepo_php" sh -c "./vendor/bin/phpstan analyze src/ tests/"
    echo "Run fixtures"
    docker exec -it  "${PROJECT_NAME}_dotenvrepo_php" sh -c "bin/console doctrine:fixtures:load --group=test --env=test -n"
    echo "Run test suites"
    docker exec -it  "${PROJECT_NAME}_dotenvrepo_php" sh -c "php bin/phpunit --stop-on-failure"

elif [[ "$1" = "test-coverage" ]]; then

    echo "Cache clear"
    docker exec -it  "${PROJECT_NAME}_dotenvrepo_php" sh -c "bin/console cache:clear --env=test"
    docker exec -it  "${PROJECT_NAME}_dotenvrepo_php" sh -c "bin/console redis:flushall -n --env=test"
    echo "Creating database"
    docker exec -it  "${PROJECT_NAME}_dotenvrepo_php" sh -c "bin/console doctrine:database:drop --force --env=test"
    docker exec -it  "${PROJECT_NAME}_dotenvrepo_php" sh -c "bin/console doctrine:database:create --env=test"
    docker exec -it  "${PROJECT_NAME}_dotenvrepo_php" sh -c "bin/console doctrine:schema:update --force --env=test"
    echo "Run phpStan"
    docker exec -it  "${PROJECT_NAME}_dotenvrepo_php" sh -c "./vendor/bin/phpstan analyze src/ tests/"
    echo "Run fixtures"
    docker exec -it "${PROJECT_NAME}_dotenvrepo_php"  sh -c "bin/console doctrine:fixtures:load --group=test --env=test -n"
    echo "Run test suites"
    docker exec -it  "${PROJECT_NAME}_dotenvrepo_php" sh -c "phpdbg -qrr vendor/bin/simple-phpunit --stop-on-failure --coverage-html tests/coverage-report"

elif [[ "$1" = "test-text" ]]; then

    echo "Cache clear"
    docker exec -it  "${PROJECT_NAME}_dotenvrepo_php" sh -c "bin/console cache:clear --env=test"
    docker exec -it  "${PROJECT_NAME}_dotenvrepo_php" sh -c "bin/console redis:flushall -n --env=test"
    echo "Creating database"
    docker exec -it  "${PROJECT_NAME}_dotenvrepo_php" sh -c "bin/console doctrine:database:drop --force --env=test"
    docker exec -it  "${PROJECT_NAME}_dotenvrepo_php" sh -c "bin/console doctrine:database:create --env=test"
    docker exec -it  "${PROJECT_NAME}_dotenvrepo_php" sh -c "bin/console doctrine:schema:update --force --env=test"
    echo "Run phpStan"
    docker exec -it  "${PROJECT_NAME}_dotenvrepo_php" sh -c "./vendor/bin/phpstan analyze src/ tests/"
    echo "Run fixtures"
    docker exec -it "${PROJECT_NAME}_dotenvrepo_php"  sh -c "bin/console doctrine:fixtures:load --group=test --env=test -n"
    echo "Run test suites"
    docker exec -it  "${PROJECT_NAME}_dotenvrepo_php" sh -c "php bin/phpunit --testdox"

elif [[ "$1" = "down" ]]; then

    shift 1
    docker-compose \
	    --file docker-compose.yml \
        --env-file .env \
        ${COMPOSE_OVERRIDE} \
		down

elif [[ "$1" = "purge" ]]; then

    docker-compose \
	    --file docker-compose.yml \
	    ${COMPOSE_OVERRIDE} \
		down
		docker system prune -a
    docker rmi "$(docker images -a -q)"
    docker rm "$(docker ps -a -f status=exited -q)"
    docker volume prune

elif [[ "$1" = "log" ]]; then

    docker-compose \
        --file docker-compose.yml \
        ${COMPOSE_OVERRIDE} \
        -p ${PROJECT_NAME} \
        logs -f


else
    docker-compose \
        --file docker-compose.yml \
        --env-file .env \
        ${COMPOSE_OVERRIDE} \
        -p ${PROJECT_NAME} \
        ps
fi
