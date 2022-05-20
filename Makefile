EXEC := $(shell if [ -f /.dockerenv ]; then \
    	echo ""; \
	else \
    	echo "docker-compose exec symfony"; \
	fi)
CONSOLE = $(EXEC) bin/console
PROJECT := $(shell basename ${CURDIR})
# run once after composer create-project
init:
	sed -i -E 's/\[PROJECT\]/$(PROJECT)/g' docker-compose.yaml
	sed -i -E 's/\[PROJECT\]/$(PROJECT)/g' Dockerfile
	sed -i -E 's/\[PROJECT\]/$(PROJECT)/g' Makefile
	sed -i -E 's/\[PROJECT\]/${PROJECT}/g' sonar-project.properties
	sed -i -E 's/\[PROJECT\]/${PROJECT}/g' .env
	sed -i -E 's/\[PROJECT\]/${PROJECT}/g' .gitlab-ci.yml
	sed -i -E 's/2lenet\/project/2lenet\/${PROJECT}/g' composer.json
	sed -i -E 's/\[PROJECT\]/$(PROJECT)/g' dbtest/build.sh
	sed -i -E 's/\[PROJECT\]/$(PROJECT)/g' dbtest/Dockerfile
	echo "build dbtest"
	cd dbtest; ./build.sh

# Install project
install:
	docker-compose build
	docker-compose run symfony composer install
	docker-compose run symfony npm install
	docker-compose run symfony chmod -R 777 var

# Start project
start:
	docker-compose up -d
	@echo "Sf at http://127.0.0.1:8000/"
	@echo "PMA at http://127.0.0.1:9000/"

# Stop project
stop:
	docker-compose down --remove-orphans

build:
	docker build --build-arg app_version=dev-${CI_PIPELINE_ID} -t registry.2le.net/2le/[PROJECT] .
	docker push registry.2le.net/2le/[PROJECT]

# Clear cache
cc:
	$(CONSOLE) cache:clear

# Get into Symfony docker bash
console:
	docker-compose exec symfony bash

# Run migrations
prepare:
	bin/console doc:mi:mi --no-interaction --allow-no-migration
	# bin/console translation:pull loco --force
	bin/console assets:install --symlink
	bin/console c:c -vv
	bin/console c:w -vv
	chmod -R 777 var
	# chmod -R 777 data

cbmigrate:
	$(CONSOLE) d:m:g

# Build project assets
build-assets:
	$(CONSOLE) assets:install --symlink

# Download translations from Loco
translate:
	$(CONSOLE) translation:pull loco --force

# Push translate to Loco
push-translate:
	$(CONSOLE) translation:push loco --force --locales=fr_FR --domains=messages

# Start watching asset files
wp-watch:
	$(EXEC) ./node_modules/.bin/encore dev --watch

# Run tests
test:
	$(EXEC) cp phpunit.xml.dist phpunit.xml
	$(CONSOLE) doc:data:create --if-not-exists --env=test
	$(CONSOLE) doc:mi:mi --no-interaction --allow-no-migration --env=test
#	# $(CONSOLE doctrine:fixtures:load -n --env=test
	$(EXEC) bin/phpunit tests/ -v --coverage-clover phpunit.coverage.xml --log-junit phpunit.report.xml

lint:
	$(CONSOLE) lint:container
	$(CONSOLE) lint:twig templates
	$(EXEC) ./vendor/bin/phpcs
	$(EXEC) ./vendor/bin/phpstan analyse

format:
	$(EXEC) ./vendor/bin/phpcbf
