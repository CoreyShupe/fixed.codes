use strum::IntoEnumIterator;
use strum_macros::EnumIter;
use yew::html::ImplicitClone;
use yew::{function_component, html, Html};
use yew_router::{BrowserRouter, Routable, Switch};

use crate::components::nav::{ContentInfo, Named, NavBar};

#[non_exhaustive]
#[derive(Routable, EnumIter, Clone, Copy, PartialEq, Debug)]
pub enum Routes {
    #[at("/")]
    Root,
    #[at("/games")]
    Games,
    #[not_found]
    #[at("/404")]
    NotFound,
}

impl Named for Routes {
    fn name(&self) -> &'static str {
        match self {
            Routes::Root => "Home",
            Routes::Games => "Games",
            Routes::NotFound => unimplemented!(),
        }
    }
}

impl ImplicitClone for Routes {}

fn nav_base(route: Routes) -> Html {
    let included_routes = Routes::iter()
        .filter(|route| !matches!(route, Routes::NotFound))
        .collect::<Vec<Routes>>();
    let extra_content: Vec<ContentInfo> = vec![ContentInfo::ForeignLink(
        Box::new(ContentInfo::Image("github-mark-white.png".to_string())),
        "https://github.com/CoreyShupe".to_string(),
    )];
    html! {
        <NavBar<Routes>
            base_classes="root_navbar"
            active_route={route}
            included_routes={included_routes}
            extra_content={extra_content}
        />
    }
}

fn map_router(route: Routes) -> Html {
    let ported = match route {
        Routes::Root => html! {
            {"Hello World Root"}
        },
        Routes::Games => html! {
            {"Hello World Games"}
        },
        Routes::NotFound => html! {
            {"Hello World 404"}
        },
    };
    html! {
        <>
            {nav_base(route)}
            {ported}
        </>
    }
}

#[function_component(Root)]
pub fn root_component() -> Html {
    html! {
        <BrowserRouter>
            <Switch<Routes> render={map_router} />
        </BrowserRouter>
    }
}
