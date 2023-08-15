#!/bin/bash

set -e

# устанавливаем сертификат ssl для NGINX_HOST
mkcert ${NGINX_HOST}
cat ${NGINX_HOST}.pem /root/.local/share/mkcert/rootCA.pem > build-ca.crt
mv build-ca.crt /root/mkcert/build-ca.crt

exec "$@"

# start cron, для работы контейнера
/usr/sbin/crond -f -l 8
