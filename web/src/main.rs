use actix_web::middleware::Logger;
use actix_web::{web, App, HttpRequest, HttpServer, Responder};
use log::LevelFilter;
use std::fs;
use std::path::Path;
use web_commons::files::FileService;

async fn greet(_: HttpRequest) -> impl Responder {
    // todo: make a simple greet page
    format!("Hello!")
}

#[actix_web::main]
async fn main() -> anyhow::Result<()> {
    if Path::new("output.log").exists() {
        fs::remove_file("output.log")?;
    }

    fern::Dispatch::new()
        .format(move |out, message, record| {
            out.finish(format_args!(
                "{} [{}/{}]: {}",
                chrono::Local::now().format("[%Y-%m-%d][%H:%M:%S]"),
                record.target(),
                record.level(),
                message
            ))
        })
        .level(LevelFilter::Debug)
        .chain(std::io::stdout())
        .chain(fern::log_file("output.log")?)
        .apply()?;

    HttpServer::new(|| {
        App::new()
            .wrap(Logger::new("{%a} | \"%r\" %s | took %Dms (%b bytes)"))
            .route("/", web::get().to(greet))
            .service(
                FileService::construct()
                    .register("favicon.ico", Path::new("favicon.ico"))
                    .into_inner(),
            )
    })
    .bind(("127.0.0.1", 8080))?
    .run()
    .await
    .map_err(Into::into)
}
