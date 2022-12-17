pub(crate) mod components;
pub mod router;

fn main() {
    yew::Renderer::<router::Root>::new().render();
}
