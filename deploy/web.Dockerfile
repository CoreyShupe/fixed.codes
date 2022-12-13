FROM rust:1.65-alpine AS builder

RUN apk add --update --no-cache alpine-sdk

RUN mkdir /app_build
COPY . /app_build
WORKDIR /app_build
RUN cargo build -p web --release
RUN chmod +x target/release/web

FROM scratch
COPY --from=builder target/release/web /web

CMD ["/web"]