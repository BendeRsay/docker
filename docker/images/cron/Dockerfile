ARG COMPOSE_PROJECT_NAME
ARG PHP_VERSION

FROM ${COMPOSE_PROJECT_NAME}-php:${PHP_VERSION}

USER root
WORKDIR /root

# нужные пакеты
RUN apt-get update && apt-get install -y \
        cron

COPY ./crontab /etc/crontab

CMD ["cron", "-f"]