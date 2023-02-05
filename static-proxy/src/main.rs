use actix_web::{App, HttpServer};

#[actix_web::main]
async fn main() -> anyhow::Result<()> {
    web_commons::logger::attach_default_system_logger()?;

    HttpServer::new(|| {
        let files = actix_files::Files::new("/", "/app/static").index_file("index.html");
        App::new().service(files)
    })
    .bind(("0.0.0.0", 8080))?
    .run()
    .await?;

    Ok(())
}
