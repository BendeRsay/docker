FROM alpine:latest

# нужные пакеты
RUN apk update && apk add --no-cache \
        mc \
        tzdata \
        curl

# Собираем mkcert
RUN  curl -JLO "https://dl.filippo.io/mkcert/latest?for=linux/amd64" \
        && chmod +x mkcert-v*-linux-amd64 \
        && cp mkcert-v*-linux-amd64 /usr/local/bin/mkcert

WORKDIR /root/mkcert
RUN mkcert -install

COPY ./ssl.sh /root/mkcert/ssl.sh

CMD ["/bin/sh", "/root/mkcert/ssl.sh"]
