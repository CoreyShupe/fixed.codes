FROM rust:1.65-alpine AS chef

ENV CARGO_NET_GIT_FETCH_WITH_CLI=true

RUN ((cat /etc/os-release | grep ID | grep alpine) \
    && apk add --update --no-cache alpine-sdk || true) \
    && cargo install cargo-chef --locked \
    && rm -rf $CARGO_HOME/registry/

WORKDIR app

FROM chef AS planner
COPY . .
RUN cargo chef prepare --recipe-path recipe.json

FROM chef AS builder

COPY --from=planner /app/recipe.json recipe.json

RUN cargo chef cook --recipe-path recipe.json

RUN cargo build -p web
RUN chmod +x target/debug/web

FROM scratch
COPY --from=builder /app/target/debug/web /web
COPY resources /resources

CMD ["/web"]