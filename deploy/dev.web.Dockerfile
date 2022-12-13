FROM rust:1.65-alpine AS builder

RUN mkdir /app_build
COPY . /app_build
WORKDIR /app_build
RUN cargo build -p web
RUN chmod +x web/target/debug/web

FROM scratch
COPY --from=builder web/target/debug/web /web

CMD ["/web"]