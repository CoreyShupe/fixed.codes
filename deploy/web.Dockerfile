FROM rust:1.65-alpine AS builder

RUN mkdir /app_build
COPY . /app_build
WORKDIR /app_build
RUN cargo build -p web --release
RUN chmod +x web/target/release/web

FROM scratch
COPY --from=builder web/target/release/web /web

CMD ["/web"]