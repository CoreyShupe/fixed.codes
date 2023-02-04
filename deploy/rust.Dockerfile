ARG RUST_WORKSPACE
FROM ${RUST_WORKSPACE} AS builder

ARG APP_NAME
ARG BUILD_PROFILE
ARG BUILD_PATH=${BUILD_PROFILE}
COPY . .

RUN cargo +nightly build --target x86_64-unknown-linux-musl --profile ${BUILD_PROFILE} -p ${APP_NAME}
RUN chmod +x target/x86_64-unknown-linux-musl/${BUILD_PATH}/${APP_NAME}

FROM alpine AS runtime

RUN apk update && apk upgrade
RUN apk add --update \
    su-exec \
    tini \
    curl \
    vim \
    openssl \
    openssl-dev \
    bash \
    ca-certificates \
    pkgconfig

WORKDIR /app

ARG APP_NAME
ARG BUILD_PROFILE
ARG BUILD_PATH=${BUILD_PROFILE}

COPY --from=builder /app/target/x86_64-unknown-linux-musl/${BUILD_PATH}/${APP_NAME} /app/executable

RUN adduser -D app -s /sbin/nologin
RUN chown -R app:app /app/

ENTRYPOINT ["/sbin/tini", "--"]
CMD ["su-exec", "app", "/app/executable"]