FROM rust:1.67-alpine AS chef

RUN rustup update nightly
RUN rustup default nightly

ARG CHEF_TAG=0.1.50

RUN ((cat /etc/os-release | grep ID | grep alpine) && apk add --no-cache musl-dev || true) \
    && cargo install cargo-chef --locked --version $CHEF_TAG \
    && rm -rf $CARGO_HOME/registry/

WORKDIR /app

FROM chef AS planner

COPY . .
RUN cargo +nightly chef prepare --recipe-path recipe.json

FROM chef AS builder

COPY --from=planner /app/recipe.json recipe.json

ARG BUILD_PROFILE

RUN apk add --update \
    openssl \
    openssl-dev \
    pkgconfig

RUN cargo +nightly chef cook --profile $BUILD_PROFILE --recipe-path recipe.json