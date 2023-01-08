use drax::PinnedLivelyResult;
use mcprotocol::clientbound::status::StatusResponse;
use mcprotocol::common::chat::Chat;
use shovel::server::MinecraftServerStatusBuilder;

pub struct BasicStatus;

impl MinecraftServerStatusBuilder for BasicStatus {
    fn build_status(&self, client_count: usize) -> PinnedLivelyResult<StatusResponse> {
        Box::pin(async move {
            let mut chat = Chat::text("");
            let mut line_1 = Chat::text("Hello, this is a demo for Shovel.\n");
            line_1.modify_style(|s| s.color("gold"));
            let mut line_2 = Chat::text("This server is simply a showcase.");
            line_2.modify_style(|s| s.color("red"));
            chat.append_extra(vec![line_1, line_2]);

            Ok(shovel::status_builder! {
                description: chat,
                max: 100,
                online: client_count as isize,
            })
        })
    }
}

pub const COMPRESSION_THRESHOLD: i32 = 1024;

#[tokio::main]
pub async fn main() -> anyhow::Result<()> {
    web_commons::logger::attach_default_system_logger()?;

    (shovel::spawn_server! {
        @bind "0.0.0.0:25565",
        @mc_status BasicStatus,
        client -> {
            client.compress_and_complete_login(COMPRESSION_THRESHOLD).await?;
            client.disconnect("This is as far as I've gotten...").await?;
            Ok(())
        }
    })
    .map_err(|err| anyhow::format_err!("{:?}", err))
}
