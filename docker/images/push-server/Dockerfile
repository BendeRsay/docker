FROM node:18-alpine

WORKDIR /opt/push-server

RUN set -x && \
    apk add --update "libintl" && \
    apk add --virtual build_deps "gettext" &&  \
    cp /usr/bin/envsubst /usr/local/bin/envsubst && \
    apk del build_deps

ADD push-server.zip /opt/push-server
RUN unzip -n push-server.zip

ADD run.sh /opt/push-server
ADD config.template.json /etc/push-server/

ENTRYPOINT ["./run.sh"]