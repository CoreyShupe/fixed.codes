# https://fixed.codes

Repository for hosting the `https://fixed.codes` website in its entirety. <br />
Most of the code base will be written as rust workspace modules providing Actix services. <br />

## Service Architecture

[`web`](web-api/) - The main web service that serves the base layer of the website and calls into all other
modules. <br />
[`web commons`](./web_commons/) - A rust module which provides a foundational building layer for all other
modules. <br />