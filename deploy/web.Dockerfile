FROM rust:1.65-alpine AS chef

ENV CARGO_NET_GIT_FETCH_WITH_CLI=true

RUN ((cat /etc/os-release | grep ID | grep alpine) \
    && apk add --update --no-cache alpine-sdk || true) \
    && cargo install cargo-chef --locked \
    && rm -rf $CARGO_HOME/registry/

WORKDIR app

FROM chef AS planner
COPY . .
RUN cargo chef prepare --release --recipe-path recipe.json

FROM chef AS builder

COPY --from=planner /app/recipe.json recipe.json

RUN cargo chef cook --release --recipe-path recipe.json

RUN cargo build --release -p web
RUN chmod +x target/release/web

FROM scratch
COPY --from=builder /app/target/release/web /web
COPY resources /resources

CMD ["/web"]