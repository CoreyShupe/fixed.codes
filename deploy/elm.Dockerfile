FROM alpine as builder

RUN wget -O - 'https://github.com/elm/compiler/releases/download/0.19.1/binary-for-linux-64-bit.gz' \
    | gunzip -c >/usr/local/bin/elm \
    && chmod +x /usr/local/bin/elm

RUN apk update
RUN apk add --update nodejs npm

RUN mkdir /app

ARG APP_NAME

WORKDIR /app
COPY $APP_NAME/elm.json .
COPY $APP_NAME/src src

RUN elm make src/Main.elm --output /app/elm_entry.js --optimize

FROM nginx:alpine

RUN apk update && apk upgrade
RUN apk add --update \
    su-exec \
    tini \
    curl \
    vim \
    bash

ARG APP_NAME

COPY $APP_NAME/assets /app
COPY --from=builder /app/elm_entry.js /app/elm_entry.js

COPY $APP_NAME/nginx.conf /etc/nginx/nginx.conf

RUN adduser -D app -s /sbin/nologin

RUN chown -R app:app /app
RUN chown -R app:app /var/cache/nginx
RUN chown -R app:app /var/log/nginx
RUN touch /var/run/nginx.pid
RUN chown -R app:app /var/run/nginx.pid

USER app

RUN touch /var/log/nginx/error.log
RUN touch /var/log/nginx/access.log

ENTRYPOINT ["/sbin/tini", "--"]
CMD ["nginx"]
