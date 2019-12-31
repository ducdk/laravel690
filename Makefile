DOCKER_COMPOSE?=docker-compose -f docker-compose.yml -f docker-compose.local.yml
RUN=$(DOCKER_COMPOSE) run --rm backend
EXEC?=$(DOCKER_COMPOSE) exec backend
EXEC_NGINX?=$(DOCKER_COMPOSE) exec frontend
CONSOLE=artisan
COMPOSER=$(EXEC) composer
COMPOSER_REQUIRE=$(COMPOSER) require
COMPOSER_REQUIRE_DEV=$=$(COMPOSER_REQUIRE) --dev
PHPCSFIXER?=$(EXEC) vendor/bin/php-cs-fixer
BEHAT_ARGS?=-vvv
PHPUNIT_ARGS?=-v
PHPSPEC_ARGS?=--format=pretty
ARGS = $(filter-out $@,$(MAKECMDGOALS))

##
## Helpers
##---------------------------------------------------------------------------


console:
	$(EXEC) bash

console-nginx:
	$(EXEC_NGINX) bash

npm:
	$(EXEC_NGINX) npm ${ARGS}

npm-run-prod:
	$(EXEC_NGINX) npm run prod

npm-run-dev:
	$(EXEC_NGINX) npm run dev

composer:
	$(COMPOSER) ${ARGS}

composer-require:
	$(COMPOSER_REQUIRE) ${ARGS}

composer-require-dev:
	$(COMPOSER_REQUIRE_DEV) ${ARGS}

##
## Tests
##---------------------------------------------------------------------------

test: up tu tf                                                                                         ## Run the all tests

test-behat:                                                                                            ## Run behat tests
	$(EXEC) vendor/bin/behat $(BEHAT_ARGS)

test-unit:                                                                                             ## Run phpunit tests
	$(EXEC) vendor/bin/phpunit $(PHPUNIT_ARGS)

test-fastest:                                                                                             ## Run phpunit tests
	$(EXEC) find /app/tests/ -name "*Test.php" | /app/vendor/liuggio/fastest/fastest -p 2 -x phpunit.xml "vendor/phpunit/phpunit/phpunit {};"

test-phpspec:                                                                                          ## Run phpspec tests
	$(EXEC) vendor/bin/phpspec run $(PHPSPEC_ARGS)

tu: tup test-unit                                                                                      ## Run phpunit tests

tup: up

tf: tfp test-behat                                                                                     ## Run the PHP functional tests

ly:
	$(EXEC) $(CONSOLE) lint:yaml config

artisan:
	$(EXEC) $(CONSOLE) ${ARGS}

phing:
	$(EXEC) vendor/bin/phing ${ARGS}

phpcs: vendor                                                                                          ## Lint PHP code
	$(PHPCSFIXER) fix --diff --dry-run --no-interaction -v

phpcsfix: vendor                                                                                       ## Lint and fix PHP code to follow the convention
	$(PHPCSFIXER) fix

##
## Docker compose
##---------------------------------------------------------------------------

build:
	$(DOCKER_COMPOSE) build --force-rm

up:
	$(DOCKER_COMPOSE) up -d --remove-orphans

start: build up

stop:                                                                                                  ## Remove docker containers
	$(DOCKER_COMPOSE) kill
	$(DOCKER_COMPOSE) rm -v --force

# Rules from files
vendor: composer.lock
	$(COMPOSER) install -n

composer.lock: composer.json
	@echo compose.lock is not up to date.
