# Docker под 1С-Битрикс
Сборка представляет собой связку:
nginx + php-fpm + mysql + memcached

Сборка для работы внутри папки `/local` https://github.com/BendeRsay/local-docker

Подходит для версии 1С-Битрикc: Управление сайтом. Поддерживает технологию композитный сайт. Работает в https или http.

Здесь и дальше `localhost` может быть изменен на любой домен, который указывается в `.env`, а так же в вашем локальном `.hosts`

Для работы **https** локально требуется установить корневой сертификат ssl.

Есть **phpmyadmin** для просмотра БД. http://localhost:8181/

Есть **mailhog** для просмотра почты. http://localhost:8025/
> порты могут отличаться, зависит от настроек в `.env`

## Поддерживаются в любом сочетании:

**PHP:** 7.2, 7.3, 7.4, 8.0, 8.1, 8.2, 8.3, 8.4

**MySql:** 5.7, 8

## Установка

Клонируем проект

`git clone https://github.com/BendeRsay/docker.git`

Запускаем команду копирования служебных файлов

`make copyinitdata`

Настраиваем окружение в файле `.env`.

`NGINX_HOST` должен совпадать с настройками Главного модуля, "URL сайта (без http://, например www.mysite.com)". При запуске одновременно нескольких проектов, порты на контейнеры должны отличаться.

Перед первым запуском сделать `make dc-build`

Запускаем docker `make dc-up`

Рекомендуется всегда пользоваться командами `make dc-up` и `make dc-down` для запуска и остановки проекта в docker.
В `make dc-up` происходит установка домена и ip nginx в файл `.hosts` контейнера php.

Устанавливаем битрикс:

`http://localhost/bitrixsetup.php` - если проект новый.

`http://localhost/restore.php` - если восстанавливаем из бекапа битрикса.

Удаляем git и мусор, после установки 1C-Битрикс:

> `make setupclear` - Подразумевается использование: под каждый проект - свой git.

Внимание: 
 - Для корректной сборки cron образа Docker Compose должен быть больше 2 версии. Проверялось на v2.15.1.
 - Работа в windows только в wsl2.

## Структура проекта
```bash
-- docker
    -- bash_history # папка для хранения истории bash контейнеров
    -- conf # конфиги. ngnix и пр.
    -- dumps # папка для дампов БД
    -- images # папка с docker образами
    -- initdata # папка со служебными файлами
-- www # root директория проекта
-- .env.example # пример файла `.env`
-- .gitignore # список игнора
-- Makefile # команды make. Список команд make можно посмотреть так: `make` или `make help`
-- docker-compose.yml # конфиг контейнеров
-- README.md # этот файл
```
## memcached
Пример хранения данных сессии в **memcached**, настройки файла `bitrix/.settings.php`
````php
return [
//...        
    'session' => [
        'value' => [
            'mode' => 'default',
            'handlers' => [
                'general' => [
                    'type' => 'memcache',   
    			    'host' => 'memcached',
    			    'port' => '11211',
                ],           
            ],
        ]                   
    ] 
];
````
Подробней в https://dev.1c-bitrix.ru/learning/course/index.php?COURSE_ID=43&LESSON_ID=14026&LESSON_PATH=3913.3435.4816.14028.14026

## Настройки для портала Битрикс24

1. Перед сборкой и запуском проекта в .env раскомментировать переменную COMPOSE_PROFILES, проверить, что ее значение равно "portal"
2. Для корректной работы Push&Pull в админ. панели в настройках модуля (bitrix/admin/settings.php?mid=pull&lang=ru) указать "Путь для публикации команд", равным http://push-server-pub:9010/bitrix/pub/ . Либо сделать аналогичные настройки в /bitrix/.setting.php, подробней: https://dev.1c-bitrix.ru/learning/course/index.php?COURSE_ID=41&LESSON_ID=2033
