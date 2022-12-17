use super::common_lib::flex::*;
use yew::html::ImplicitClone;
use yew::{classes, function_component, html, Classes, Html, Properties};
use yew_router::{prelude::Link, Routable};

pub trait Named {
    fn name(&self) -> &'static str;
}

#[derive(PartialEq, Clone, Debug)]
pub enum ContentInfo {
    ForeignLink(Box<ContentInfo>, String),
    Image(String),
}

impl Into<Html> for &ContentInfo {
    fn into(self) -> Html {
        match self {
            ContentInfo::ForeignLink(info, link) => html! {
                <a href={link.to_string()}>
                    {Into::<Html>::into(info.as_ref())}
                </a>
            },
            ContentInfo::Image(link) => html! { <img src={link.to_string()}/> },
        }
    }
}

impl Into<Html> for ContentInfo {
    fn into(self) -> Html {
        Into::<Html>::into(&self)
    }
}

#[derive(PartialEq, Properties)]
pub struct Props<E>
where
    E: Routable + PartialEq + ImplicitClone + Named + 'static,
{
    #[prop_or_default]
    pub extra_content: Vec<ContentInfo>,
    #[prop_or_default]
    pub active_route: Option<E>,
    #[prop_or_default]
    pub included_routes: Vec<E>,
    #[prop_or_default]
    pub base_classes: Classes,
    #[prop_or_default]
    pub nav_item_container_classes: Classes,
    #[prop_or_default]
    pub content_item_container_classes: Classes,
    #[prop_or_default]
    pub nav_item_classes: Classes,
    #[prop_or_default]
    pub content_item_classes: Classes,
}

#[function_component(NavBar)]
pub fn nav_component<E>(props: &Props<E>) -> Html
where
    E: Routable + PartialEq + ImplicitClone + Named + 'static,
{
    html! {
        // main navigation "row box"
        <FlexBox
            class={props.base_classes.clone()}
            justify_content={JustifyContent::SpaceBetween}
            align_items={AlignItems::Stretch}
        >
            <FlexBox
                class={props.nav_item_container_classes.clone()}
                justify_content={JustifyContent::Center}
                align_items={AlignItems::Center}
            >
                {
                    for props.included_routes.iter().map(|route| {
                        let active = props.active_route.as_ref().map_or(false, |active| active == route);

                        let nav_item_classes = if active {
                            let mut clone = props.nav_item_classes.clone();
                            clone.push(classes!("active"));
                            clone
                        } else {
                            props.nav_item_classes.clone()
                        };

                        html! {
                            <div class={nav_item_classes}>
                                <Link<E> to={route.clone()} >
                                    {route.name()}
                                </Link<E>>
                            </div>
                        }
                    })
                }
            </FlexBox>
            <FlexBox
                class={props.content_item_container_classes.clone()}
                justify_content={JustifyContent::SpaceBetween}
                align_items={AlignItems::Center}
            >
                {
                    for props.extra_content.iter().map(|content| {
                        html! {
                            <div class={props.content_item_classes.clone()}>
                                {content.clone()}
                            </div>
                        }
                    })
                }
            </FlexBox>
        </FlexBox>
    }
}
