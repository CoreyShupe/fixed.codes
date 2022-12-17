use std::fmt::{Debug, Display, Formatter};
use yew::{function_component, html, Html, Properties};

pub mod common_lib;
pub mod nav;

#[derive(PartialEq, Debug, Clone, Copy)]
pub enum GlobalState {
    Inherit,
    Initial,
    Revert,
    RevertLayer,
    Unset,
}

impl Display for GlobalState {
    fn fmt(&self, f: &mut Formatter<'_>) -> std::fmt::Result {
        match self {
            GlobalState::Inherit => write!(f, "inherit"),
            GlobalState::Initial => write!(f, "initial"),
            GlobalState::Revert => write!(f, "revert"),
            GlobalState::RevertLayer => write!(f, "revert-layer"),
            GlobalState::Unset => write!(f, "unset"),
        }
    }
}

#[derive(PartialEq, Debug, Clone, Copy)]
pub enum NumState {
    Percent(usize),
    Pixels(usize),
    FontSize(usize),
    Auto,
}

impl Display for NumState {
    fn fmt(&self, f: &mut Formatter<'_>) -> std::fmt::Result {
        match self {
            NumState::Percent(num) => write!(f, "{}%", num),
            NumState::Pixels(num) => write!(f, "{}px", num),
            NumState::FontSize(num) => write!(f, "{}em", num),
            NumState::Auto => write!(f, "auto"),
        }
    }
}
