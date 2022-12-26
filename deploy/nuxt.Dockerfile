FROM node:18.12.1-alpine as build

RUN apk add --update \
    su-exec \
    tini \
    curl \
    vim \
    openssl \
    bash

ARG $APP_NAME

WORKDIR /app
COPY $APP_NAME/package.json .
COPY $APP_NAME/yarn.lock .
RUN yarn install

COPY $APP_NAME .
RUN yarn generate --fail-on-error

FROM build as runtime

WORKDIR /app
COPY --from=build /app/dist dist

RUN adduser -D app -s /sbin/nologin
RUN chown -R app:app /app/

ENTRYPOINT ["/sbin/tini", "--"]
CMD ["su-exec", "app", "yarn", "start"]
