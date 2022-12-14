FROM rust:1.65-alpine AS chef

ARG CHEF_TAG=0.1.50

RUN ((cat /etc/os-release | grep ID | grep alpine) && apk add --no-cache musl-dev || true) \
    && cargo install cargo-chef --locked --version $CHEF_TAG \
    && rm -rf $CARGO_HOME/registry/

WORKDIR /app

FROM chef AS planner
COPY . .
RUN cargo chef prepare --recipe-path recipe.json

FROM chef AS builder

COPY --from=planner /app/recipe.json recipe.json

ARG BUILD_PROFILE
ARG BUILD_PATH=$BUILD_PROFILE

RUN cargo chef cook --profile $BUILD_PROFILE --recipe-path recipe.json

COPY . .

ARG APP_NAME

RUN cargo build --profile $BUILD_PROFILE -p $APP_NAME
RUN chmod +x target/$BUILD_PATH/$APP_NAME

COPY resources/$APP_NAME /resources
RUN ls /resources
RUN ls /resources/landing

FROM alpine

RUN apk add --update \
    su-exec \
    tini \
    curl \
    vim \
    openssl \
    bash

RUN adduser -D app -s /sbin/nologin

WORKDIR /app

ARG BUILD_PROFILE
ARG BUILD_PATH=$BUILD_PROFILE
ARG APP_NAME

COPY --from=builder /app/target/$BUILD_PATH/$APP_NAME /app/executable
COPY resources/$APP_NAME /app/resources

RUN chown -R app:app /app/

ENTRYPOINT ["/sbin/tini", "--"]
CMD ["su-exec", "app", "/app/executable"]