FROM rust:1.65-alpine AS builder

RUN apk add --update --no-cache alpine-sdk

RUN mkdir /app_build
COPY . /app_build
WORKDIR /app_build
RUN cargo build -p web
RUN chmod +x target/debug/web

FROM scratch
COPY --from=builder target/debug/web /web

CMD ["/web"]