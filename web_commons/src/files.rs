use std::fs;
use std::path::{Path, PathBuf};

use actix_files::NamedFile;
use actix_web::http::header::ContentType;
use actix_web::{web, HttpRequest, HttpResponse, Scope};
use mime::Mime;

pub struct FileService {
    scope: Scope,
}

async fn process_internal<P: AsRef<Path>>(
    file: P,
    content_type: ContentType,
) -> actix_web::Result<HttpResponse> {
    let mut response = HttpResponse::Ok();
    let response = response.insert_header(content_type).body(fs::read(file)?);
    Ok(response)
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

    pub fn single_file<S: ToString, P: AsRef<Path>>(route: S, file: P) -> Scope {
        Self::construct().register(route, file).into_inner()
    }

    pub fn insert_bundle(mut self, mut bundle: FileBundle) -> std::io::Result<Self> {
        bundle = bundle.compile_directory()?;
        self.scope = self.scope.service(bundle.scope);
        Ok(self)
    }

    pub fn static_raw<S: ToString, P: AsRef<Path>>(
        mut self,
        route: S,
        file: P,
        content_type: ContentType,
    ) -> Self {
        Self::check_file_exists(&file);
        let file = file.as_ref().to_path_buf();

        self.scope = self.scope.service(
            web::resource(route.to_string().as_str())
                .route(web::get().to(move |_: HttpRequest| {
                    process_internal(file.clone(), content_type.clone())
                })),
        );

        self
    }

    pub fn register<S: ToString, P: AsRef<Path>>(mut self, route: S, file: P) -> Self {
        Self::check_file_exists(&file);
        let file = file.as_ref().to_path_buf();

        self.scope = self.scope.service(
            web::resource(route.to_string().as_str())
                .route(web::get().to(move |_: HttpRequest| resolve_file_internal(file.clone()))),
        );

        self
    }

    fn check_file_exists<P: AsRef<Path>>(file: P) {
        if !file.as_ref().exists() {
            log::warn!("File {:?} does not exist", file.as_ref());
        }
    }

    pub fn into_inner(self) -> Scope {
        self.scope
    }
}

pub struct FileBundle {
    dir_path: PathBuf,
    scope: Scope,
}

impl FileBundle {
    pub fn construct<P: AsRef<Path>>(dir_path: P) -> Self {
        Self::construct_router(dir_path, "")
    }

    pub fn construct_router<P: AsRef<Path>, S: ToString>(dir_path: P, str: S) -> Self {
        Self {
            dir_path: dir_path.as_ref().to_path_buf(),
            scope: web::scope(str.to_string().as_str()),
        }
    }

    fn add_child(mut self, child: FileBundle) -> Self {
        self.scope = self.scope.service(child.scope);
        self
    }

    fn compile_directory(mut self) -> std::io::Result<Self> {
        let bundle_ignore = self.dir_path.join(".bundle_ignore");
        let mut ignored_paths = vec![bundle_ignore.clone()];
        if bundle_ignore.exists() {
            let contents = fs::read_to_string(bundle_ignore)?;
            ignored_paths.extend(
                contents
                    .split('\n')
                    .map(|s| s.trim())
                    .filter(|s| !s.is_empty())
                    .map(|s| self.dir_path.join(s)),
            );
        }

        for entry in fs::read_dir(&self.dir_path)? {
            let entry = entry?;
            let path = entry.path();

            if ignored_paths.contains(&path) {
                continue;
            }

            if path.is_dir() {
                let new_bundle = FileBundle::construct_router(
                    path.to_path_buf(),
                    path.strip_prefix(&self.dir_path)
                        .expect("Should be a sub dir")
                        .display()
                        .to_string(),
                )
                .compile_directory()?;
                self = self.add_child(new_bundle);
            } else {
                self = self.add_file(path);
            }
        }

        Ok(self)
    }

    fn add_file<P: AsRef<Path>>(mut self, path: P) -> Self {
        fn find_mime<P: AsRef<Path>>(path: P) -> Mime {
            mime_guess::from_path(path.as_ref().file_name().unwrap()).first_or_octet_stream()
        }

        let path = path.as_ref().to_path_buf();
        let mime = find_mime(&path);

        self.scope = self.scope.service(
            web::resource(path.file_name().unwrap().to_str().unwrap()).route(web::get().to(
                move |_: HttpRequest| process_internal(path.clone(), ContentType(mime.clone())),
            )),
        );

        self
    }
}
