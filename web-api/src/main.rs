#[actix_web::main]
async fn main() -> anyhow::Result<()> {
    web_commons::logger::attach_default_system_logger()?;

    // todo - web api service

    Ok(())
}
