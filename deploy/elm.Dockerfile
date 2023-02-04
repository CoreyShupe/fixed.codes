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

RUN mkdir /app

ARG APP_NAME

COPY $APP_NAME/assets /usr/share/nginx/html

COPY --from=builder /app/elm_entry.js /usr/share/nginx/html/elm_entry.js

COPY $APP_NAME/nginx.conf /etc/nginx/nginx.conf

ENTRYPOINT ["/sbin/tini", "--"]
CMD ["su-exec", "nginx", "nginx"]
