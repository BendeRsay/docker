#---------------
# [ ENV ]
#---------------
-include .env

.DEFAULT_GOAL := help

# получим и установим ip контейнера nginx
NGINX_IP = $(shell docker inspect -f '{{range .NetworkSettings.Networks}} {{.IPAddress}} {{end}}' ${COMPOSE_PROJECT_NAME}-nginx)

##
##╔                 ╗
##║  base commands  ║
##╚                 ╝

help: ##Show this help.
	@fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep | sed -e 's/\\$$//' | sed -e 's/##//'

copyinitdata: ## Копирует файлы по директориям из initdata
	cp .env.example .env
	cp -r ./docker/initdata/bash_history/* ./docker/bash_history/
	@$(MAKE) copybitrixsetup
	@$(MAKE) copyrestore

copybitrixsetup:
	@if wget --spider http://www.1c-bitrix.ru/download/scripts/bitrixsetup.php 2>/dev/null; then \
	  wget http://www.1c-bitrix.ru/download/scripts/bitrixsetup.php -O ./www/bitrixsetup.php; \
	else \
	  cp ./docker/initdata/bitrixsetup.php ./www/bitrixsetup.php; \
	fi

copyrestore:
	@if wget --spider http://www.1c-bitrix.ru/download/scripts/restore.php 2>/dev/null; then \
	  wget http://www.1c-bitrix.ru/download/scripts/restore.php -O ./www/restore.php; \
	else \
	  cp ./docker/initdata/restore.php ./www/restore.php; \
	fi

setupclear: ## Очищаем мусор после установки битрикса
	@$(MAKE) rmgit
	@$(MAKE) rmbitrix

rmgit: # Удаляет git
	rm -v ./www/.gitkeep
	rm -rfv .git

rmbitrix: # Удаляет мусор из www
	rm -v ./www/bitrixsetup.php
	rm -v ./www/restore.php

sethost: #установим host ip в .hosts контейнера php
	docker exec -it --user root ${COMPOSE_PROJECT_NAME}-php bash -c "echo '${NGINX_IP} ${NGINX_HOST}' >> /etc/hosts"

sertadd: #Обновим общесистемный список доверенных CA контейнера php
	docker exec -it --user root ${COMPOSE_PROJECT_NAME}-php bash -c "cat /usr/local/share/ca-certificates/rootCA.pem > /usr/local/share/ca-certificates/rootmkcertCA.crt && update-ca-certificates"

##
##╔                           ╗
##║  docker-compose commands  ║
##╚                           ╝

dc-ps: ## Список запущенных контейнеров.
	docker-compose ps

dc-build: ## Сборка образа php и cron в нужном порядке
	docker-compose build php
	docker-compose build cron

dc-up: ## Создаем(если нет) образы и контейнеры, запускаем контейнеры.
	docker-compose up -d
	@$(MAKE) sethost
	@$(MAKE) sertadd
	@$(MAKE) gh-check

dc-stop: ## Останавливает контейнеры.
	docker-compose stop

dc-down: ##Останавливает, удаляет контейнеры. docker-compose down --remove-orphans
	docker-compose down --remove-orphans

dc-down-clear: ##Останавливает, удаляет контейнеры и volumes. docker-compose down -v --remove-orphans
	docker-compose down -v --remove-orphans

dc-console-db: ##Зайти в консоль mysql
	docker-compose exec ${COMPOSE_PROJECT_NAME}-mysql mysql -u $(MYSQL_USER) --password=$(MYSQL_PASSWORD) $(MYSQL_DATABASE)

dc-console-php: ##php консоль под www-data
	docker exec -it --user www-data ${COMPOSE_PROJECT_NAME}-php bash

dc-console-php-root: ##php консоль под root
	docker exec -it --user root ${COMPOSE_PROJECT_NAME}-php bash

##
##╔                     ╗
##║  database commands  ║
##╚                     ╝

db-dump: ## Сделать дамп БД
	docker exec ${COMPOSE_PROJECT_NAME}-mysql mysqldump -u $(MYSQL_USER) --password=$(MYSQL_PASSWORD) $(MYSQL_DATABASE) --no-tablespaces | gzip > ./docker/dump.sql.gz
	@if [ -f ./docker/dump.sql.gz ]; then \
		mv  ./docker/dump.sql.gz ./docker/dumps/$(shell date +%Y-%m-%d_%H%M%S)_dump.sql.gz; \
	fi

db-restore: ## Восстановить данные в БД. Параметр path - путь до дампа. Пример: make db-restore path=./docker/dumps/2021-11-12_185741_dump.sql.gz
	gunzip < $(path) | docker exec -i ${COMPOSE_PROJECT_NAME}-mysql mysql -u $(MYSQL_USER) --password=$(MYSQL_PASSWORD) $(MYSQL_DATABASE)

gh-check: # Проверка git hooks
	@if [ ! -f .git/hooks/commit-msg ] \
	 || [ ! -f .git/hooks/pre-commit ] \
	 || [ ! -f .git/hooks/prepare-commit-msg ] \
	; then \
		echo "$$(tput setaf 1)\nХуки не установлены!\n$$(tput setaf 0)Выполните команду:\n\n $$(tput setaf 2)make gh \n"; \
	fi

gh: # Инициализация git hooks
	@cd .git/hooks && \
	ln -sf ../../docker/hooks/commit-msg commit-msg && \
	ln -sf ../../docker/hooks/pre-commit pre-commit && \
	ln -sf ../../docker/hooks/prepare-commit-msg prepare-commit-msg
