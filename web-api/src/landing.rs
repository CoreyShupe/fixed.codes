use actix_web::http::header::ContentType;
use std::path::Path;

use actix_web::web::ServiceConfig;
use web_commons::files::{FileBundle, FileService};

pub fn configure_landing_page(service: &mut ServiceConfig) {
    log::info!("Constructing landing page.");
    service.service(
        FileService::construct()
            .static_raw(
                "/",
                Path::new("resources/landing/index.html"),
                ContentType(web_commons::mime::TEXT_HTML),
            )
            .insert_bundle(FileBundle::construct(Path::new("resources/landing")))
            .expect("Failed to load file bundle on path resources/landing")
            .into_inner(),
    );
}
