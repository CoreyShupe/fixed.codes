FROM rust:1.65-alpine AS chef
RUN apk add --update --no-cache alpine-sdk
RUN cargo install cargo-chef
WORKDIR app

FROM chef AS planner
COPY . .
RUN cargo chef prepare --recipe-path recipe.json

FROM chef AS builder
RUN apk add --update --no-cache alpine-sdk

COPY --from=planner /app/recipe.json recipe.json

RUN cargo chef cook --recipe-path recipe.json

COPY . .

RUN cargo build -p web
RUN chmod +x target/debug/web

FROM scratch
COPY --from=builder /app/target/debug/web /web
COPY resources /resources

CMD ["/web"]