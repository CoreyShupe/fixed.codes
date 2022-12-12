use std::path::{Path, PathBuf};

use actix_files::NamedFile;
use actix_web::{web, HttpRequest, Scope};

pub struct FileService {
    scope: Scope,
}

async fn resolve_file_internal(file: PathBuf) -> actix_web::Result<NamedFile> {
    Ok(NamedFile::open_async(file).await?)
}

impl FileService {
    pub fn construct() -> Self {
        Self::construct_from_path_prefix("")
    }

    pub fn construct_from_path_prefix<S: ToString>(str: S) -> Self {
        FileService {
            scope: web::scope(str.to_string().as_str()),
        }
    }

    pub fn register<S: ToString, P: AsRef<Path>>(mut self, route: S, file: P) -> Self {
        let file = file.as_ref().to_path_buf();
        if !file.exists() {
            log::warn!("File {:?} does not exist", file);
        }

        self.scope = self.scope.service(
            web::resource(route.to_string().as_str())
                .route(web::get().to(move |_: HttpRequest| resolve_file_internal(file.clone()))),
        );

        self
    }

    pub fn into_inner(self) -> Scope {
        self.scope
    }
}
