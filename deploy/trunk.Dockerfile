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
ARG APP_NAME

RUN cargo chef cook --profile $BUILD_PROFILE --recipe-path recipe.json

RUN rustup target add wasm32-unknown-unknown
RUN cargo install --locked trunk

COPY $APP_NAME .

RUN if [ "$BUILD_PROFILE" = "release" ]; then \
        trunk build --release; \
    else \
        trunk build; \
    fi

FROM nginx:alpine AS runtime

RUN apk add --update \
    su-exec \
    tini \
    curl \
    vim \
    openssl \
    bash

WORKDIR /app
COPY --from=builder /app/dist dist
COPY --from=builder /app/nginx.conf /etc/nginx/nginx.conf

RUN adduser -D app -s /sbin/nologin
RUN chown -R app:app /app/

ENTRYPOINT ["/sbin/tini", "--"]
CMD ["su-exec", "app", "nginx"]
