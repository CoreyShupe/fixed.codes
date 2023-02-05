use actix_files::NamedFile;
use actix_web::dev::{fn_service, ServiceRequest, ServiceResponse};
use actix_web::{App, HttpServer};

#[actix_web::main]
async fn main() -> anyhow::Result<()> {
    web_commons::logger::attach_default_system_logger()?;

    HttpServer::new(|| {
        let files = actix_files::Files::new("/", "/app/static")
            .index_file("index.html")
            .default_handler(fn_service(|req: ServiceRequest| async {
                let (req, _) = req.into_parts();
                let file = NamedFile::open_async("/app/static/index.html").await?;
                let res = file.into_response(&req);
                Ok(ServiceResponse::new(req, res))
            }));
        App::new().service(files)
    })
    .bind(("0.0.0.0", 8080))?
    .run()
    .await?;

    Ok(())
}
