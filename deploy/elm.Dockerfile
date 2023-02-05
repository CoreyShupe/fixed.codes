ARG RUST_WORKSPACE
FROM ${RUST_WORKSPACE} AS proxy_builder

ARG BUILD_PROFILE
ARG BUILD_PATH=${BUILD_PROFILE}

COPY . .

RUN cargo +nightly build --target x86_64-unknown-linux-musl --profile ${BUILD_PROFILE} -p static-proxy

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

FROM nginx:alpine AS runtime

RUN apk update && apk upgrade
RUN apk add --update \
    su-exec \
    tini \
    curl \
    vim \
    bash

ARG APP_NAME
ARG BUILD_PROFILE
ARG BUILD_PATH=${BUILD_PROFILE}

COPY $APP_NAME/assets /app/static
COPY --from=builder /app/elm_entry.js /app/static/elm_entry.js
COPY --from=proxy_builder /app/target/x86_64-unknown-linux-musl/${BUILD_PATH}/static-proxy /app/static-proxy

RUN adduser -D app -s /sbin/nologin

RUN chown -R app:app /app
RUN chmod +x /app/static-proxy

WORKDIR /app

ENTRYPOINT ["/sbin/tini", "--"]
CMD ["su-exec", "app", "/app/static-proxy"]
