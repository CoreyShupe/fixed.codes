FROM rust:1.65-alpine AS chef

ARG CHEF_TAG=0.1.50

RUN ((cat /etc/os-release | grep ID | grep alpine) && apk add --no-cache musl-dev || true) \
    && cargo install cargo-chef --locked --version $CHEF_TAG \
    && rm -rf $CARGO_HOME/registry/

RUN rustup target add wasm32-unknown-unknown
RUN cargo install --locked trunk

WORKDIR /app

FROM chef AS planner
COPY . .
RUN cargo chef prepare --recipe-path recipe.json

FROM chef AS builder

COPY --from=planner /app/recipe.json recipe.json

ARG BUILD_PROFILE
ARG BUILD_PATH=$BUILD_PROFILE
ARG APP_NAME

RUN cargo chef cook --profile $BUILD_PROFILE --recipe-path recipe.json

COPY . .

RUN if [ "$BUILD_PROFILE" = "release" ]; then \
        trunk build --release; \
    else \
        trunk build; \
    fi

FROM nginxinc/nginx-unprivileged:1.22-alpine AS runtime

WORKDIR /app
COPY --from=builder /app/dist dist
COPY --from=builder /app/nginx.conf /etc/nginx/nginx.conf
