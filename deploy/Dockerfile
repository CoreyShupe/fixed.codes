FROM lukemathwalker/cargo-chef:0.1.50-rust-1.65 AS chef
WORKDIR /app

FROM chef AS planner
COPY . .
RUN cargo chef prepare --recipe-path recipe.json

FROM chef AS builder
RUN apk add --update --no-cache alpine-sdk

COPY --from=planner /app/recipe.json recipe.json

ARG BUILD_PROFILE

RUN cargo chef cook --profile $BUILD_PROFILE --recipe-path recipe.json

COPY . .

ARG APP_NAME

RUN cargo build --profile $BUILD_PROFILE -p $APP_NAME
RUN chmod +x target/$BUILD_PROFILE/$APP_NAME

FROM scratch
ARG BUILD_PROFILE
ARG APP_NAME
COPY --from=builder /app/target/$BUILD_PROFILE/$APP_NAME /app
COPY resources /resources

CMD ["/app"]