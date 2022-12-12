use actix_web::{web, App, HttpRequest, HttpServer, Responder};
use log::LevelFilter;

async fn greet(_: HttpRequest) -> impl Responder {
    format!("Hello!")
}

#[actix_web::main]
async fn main() -> anyhow::Result<()> {
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
        .apply()?;

    HttpServer::new(|| {
        App::new()
            .route("/", web::get().to(greet))
    }).bind(("127.0.0.1", 8080))?.run().await.map_err(Into::into)
}
