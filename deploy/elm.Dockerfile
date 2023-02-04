FROM wunsh/alpine-elm:latest as builder

RUN mkdir /app

ARG APP_NAME

WORKDIR /app
COPY $APP_NAME/elm.json .
COPY $APP_NAME/src src

RUN elm make src/Main.elm

FROM nginx

RUN mkdir /app

COPY --from=builder /app/index.js /app/index.js

ARG APP_NAME

COPY $APP_NAME/nginx.conf /etc/nginx/nginx.conf

CMD ["nginx"]
