use actix_web::{App, HttpServer};

#[actix_web::main]
async fn main() -> anyhow::Result<()> {
    web_commons::logger::attach_default_system_logger()?;

    HttpServer::new(|| App::new()).bind("0.0.0.0:3000")?;

    Ok(())
}
