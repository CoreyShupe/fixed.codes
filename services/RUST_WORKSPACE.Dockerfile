FROM clux/muslrust:nightly AS chef
USER root
RUN cargo install cargo-chef
WORKDIR /app

FROM chef AS planner

COPY . .
RUN cargo +nightly chef prepare --recipe-path recipe.json

FROM chef AS builder

COPY --from=planner /app/recipe.json recipe.json

ARG BUILD_PROFILE

RUN cargo +nightly chef cook --target x86_64-unknown-linux-musl --profile $BUILD_PROFILE --recipe-path recipe.json