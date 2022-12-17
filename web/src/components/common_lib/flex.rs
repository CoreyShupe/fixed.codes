use std::fmt::Display;

use yew::{function_component, html, Children, Classes, Html, Properties};

use crate::components::{GlobalState, NumState};

#[derive(PartialEq, Debug, Clone, Copy, Default)]
pub enum AlignItems {
    GlobalState(GlobalState),
    Normal,
    Stretch,
    Center,
    Start,
    End,
    FlexStart,
    FlexEnd,
    Baseline,
    FirstBaseline,
    LastBaseline,
    SafeCenter,
    UnsafeCenter,
    #[default]
    Omit,
}

impl Display for AlignItems {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        if matches!(self, Self::Omit) {
            return Ok(());
        }

        write!(f, "align-items: ")?;

        match self {
            AlignItems::GlobalState(state) => write!(f, "{}", state)?,
            AlignItems::Normal => write!(f, "normal")?,
            AlignItems::Stretch => write!(f, "stretch")?,
            AlignItems::Center => write!(f, "center")?,
            AlignItems::Start => write!(f, "start")?,
            AlignItems::End => write!(f, "end")?,
            AlignItems::FlexStart => write!(f, "flex-start")?,
            AlignItems::FlexEnd => write!(f, "flex-end")?,
            AlignItems::Baseline => write!(f, "baseline")?,
            AlignItems::FirstBaseline => write!(f, "first baseline")?,
            AlignItems::LastBaseline => write!(f, "last baseline")?,
            AlignItems::SafeCenter => write!(f, "safe center")?,
            AlignItems::UnsafeCenter => write!(f, "unsafe center")?,
            AlignItems::Omit => unreachable!(),
        }

        write!(f, ";")
    }
}

#[derive(PartialEq, Debug, Clone, Copy, Default)]
pub enum JustifyContent {
    GlobalState(GlobalState),
    Center,
    Start,
    End,
    FlexStart,
    FlexEnd,
    Left,
    Right,
    Normal,
    SpaceBetween,
    SpaceAround,
    SpaceEvenly,
    Stretch,
    SafeCenter,
    UnsafeCenter,
    #[default]
    Omit,
}

impl Display for JustifyContent {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        if matches!(self, Self::Omit) {
            return Ok(());
        }

        write!(f, "justify-content: ")?;

        match self {
            JustifyContent::GlobalState(state) => write!(f, "{}", state)?,
            JustifyContent::Center => write!(f, "center")?,
            JustifyContent::Start => write!(f, "start")?,
            JustifyContent::End => write!(f, "end")?,
            JustifyContent::FlexStart => write!(f, "flex-start")?,
            JustifyContent::FlexEnd => write!(f, "flex-end")?,
            JustifyContent::Left => write!(f, "left")?,
            JustifyContent::Right => write!(f, "right")?,
            JustifyContent::Normal => write!(f, "normal")?,
            JustifyContent::SpaceBetween => write!(f, "space-between")?,
            JustifyContent::SpaceAround => write!(f, "space-around")?,
            JustifyContent::SpaceEvenly => write!(f, "space-evenly")?,
            JustifyContent::Stretch => write!(f, "stretch")?,
            JustifyContent::SafeCenter => write!(f, "safe center")?,
            JustifyContent::UnsafeCenter => write!(f, "unsafe center")?,
            JustifyContent::Omit => unreachable!(),
        }

        write!(f, ";")
    }
}

#[derive(PartialEq, Debug, Clone, Copy, Default)]
pub enum FlexDirection {
    GlobalState(GlobalState),
    Row,
    RowReverse,
    Column,
    ColumnReverse,
    #[default]
    Omit,
}

impl Display for FlexDirection {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        if matches!(self, Self::Omit) {
            return Ok(());
        }

        write!(f, "flex-direction: ")?;

        match self {
            FlexDirection::GlobalState(state) => write!(f, "{}", state)?,
            FlexDirection::Row => write!(f, "row")?,
            FlexDirection::RowReverse => write!(f, "row-reverse")?,
            FlexDirection::Column => write!(f, "column")?,
            FlexDirection::ColumnReverse => write!(f, "column-reverse")?,
            FlexDirection::Omit => unreachable!(),
        }

        write!(f, ";")
    }
}

#[derive(PartialEq, Debug, Clone, Copy)]
pub enum FlexBasis {
    GlobalState(GlobalState),
    NumState(NumState),
    MaxContent,
    MinContent,
    FitContent,
    Content,
}

impl Display for FlexBasis {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            FlexBasis::GlobalState(state) => write!(f, "{}", state),
            FlexBasis::NumState(num) => write!(f, "{}", num),
            FlexBasis::MaxContent => write!(f, "max-content"),
            FlexBasis::MinContent => write!(f, "min-content"),
            FlexBasis::FitContent => write!(f, "fit-content"),
            FlexBasis::Content => write!(f, "content"),
        }
    }
}

#[derive(PartialEq, Debug, Clone, Copy, Default)]
pub enum FlexWrap {
    GlobalState(GlobalState),
    NoWrap,
    Wrap,
    WrapReverse,
    #[default]
    Omit,
}

impl Display for FlexWrap {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        if matches!(self, Self::Omit) {
            return Ok(());
        }

        write!(f, "flex-wrap: ")?;

        match self {
            FlexWrap::GlobalState(state) => write!(f, "{}", state)?,
            FlexWrap::NoWrap => write!(f, "nowrap")?,
            FlexWrap::Wrap => write!(f, "wrap")?,
            FlexWrap::WrapReverse => write!(f, "wrap-reverse")?,
            FlexWrap::Omit => unreachable!(),
        }

        write!(f, ";")
    }
}

#[derive(PartialEq, Debug, Clone, Copy)]
pub enum FlexSizeChange {
    GlobalState(GlobalState),
    Num(usize),
}

impl Display for FlexSizeChange {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            FlexSizeChange::GlobalState(state) => write!(f, "{}", state),
            FlexSizeChange::Num(num) => write!(f, "{}", num),
        }
    }
}

#[derive(PartialEq, Debug, Clone, Copy, Default)]
pub enum Flex {
    Defined {
        basis: FlexBasis,
        grow: FlexSizeChange,
        shrink: FlexSizeChange,
    },
    Num(usize),
    Auto,
    Initial,
    None,
    #[default]
    Omit,
}

impl Display for Flex {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        if matches!(self, Self::Omit) {
            return Ok(());
        }

        write!(f, "flex: ")?;

        match self {
            Flex::Defined {
                basis,
                grow,
                shrink,
            } => write!(f, "{} {} {}", grow, shrink, basis)?,
            Flex::Num(num) => write!(f, "{}", num)?,
            Flex::Auto => write!(f, "auto")?,
            Flex::Initial => write!(f, "initial")?,
            Flex::None => write!(f, "none")?,
            Flex::Omit => unreachable!(),
        };

        write!(f, ";")
    }
}

#[derive(Properties, PartialEq, Debug, Clone)]
pub struct FlexBoxProperties {
    #[prop_or_default]
    pub flex_direction: FlexDirection,
    #[prop_or_default]
    pub flex_wrap: FlexWrap,
    #[prop_or_default]
    pub flex: Flex,
    #[prop_or_default]
    pub justify_content: JustifyContent,
    #[prop_or_default]
    pub align_items: AlignItems,
    #[prop_or_default]
    pub class: Classes,
    pub children: Children,
    #[prop_or(false)]
    pub inline: bool,
}

#[function_component(FlexBox)]
pub fn flex_box(props: &FlexBoxProperties) -> Html {
    let str = format!(
        "display: {};{}{}{}{}{}",
        if props.inline { "inline-flex" } else { "flex" },
        props.flex_direction,
        props.flex_wrap,
        props.flex,
        props.justify_content,
        props.align_items
    );
    html! {
        <div class={props.class.clone()} style={str}>
            { for props.children.iter() }
        </div>
    }
}
