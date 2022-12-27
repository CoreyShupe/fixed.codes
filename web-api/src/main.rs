use actix_web::{route, App, HttpResponse, HttpResponseBuilder, HttpServer};

#[route("/", method = "HEAD", method = "GET")]
async fn index_ok() -> HttpResponseBuilder {
    HttpResponse::Ok()
}

#[actix_web::main]
async fn main() -> anyhow::Result<()> {
    web_commons::logger::attach_default_system_logger()?;

    HttpServer::new(|| App::new().service(index_ok))
        .bind(("0.0.0.0", 3000))?
        .run()
        .await?;

    Ok(())
}
