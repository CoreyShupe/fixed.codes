mod initial_state_handler;

use drax::prelude::ErrorType;
use drax::PinnedLivelyResult;
use log::LevelFilter;
use mcprotocol::clientbound::play::ClientboundPlayRegistry::KeepAlive;
use mcprotocol::clientbound::status::StatusResponse;
use mcprotocol::common::chat::Chat;
use mcprotocol::serverbound::play::ServerboundPlayRegistry;
use shovel::server::{MinecraftServerStatusBuilder, ServerPlayer};

use web_commons::logger::LoggerOptions;

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

pub async fn handover_authenticated_client(mut player: ServerPlayer) -> drax::prelude::Result<()> {
    initial_state_handler::send_dimension_info(&mut player).await?;
    player.disconnect("Dimension info is good").await
    // let mut seq = 0;
    // player.write_packet(&KeepAlive { id: 0 }).await?;
    // loop {
    //     seq = seq + 1;
    //     let packet = player.read_packet::<ServerboundPlayRegistry>().await?;
    //     match packet {
    //         ServerboundPlayRegistry::KeepAlive { .. } => {
    //             log::info!(
    //                 "Sending keep alive {seq} for player {}",
    //                 player.profile.name
    //             );
    //             player.write_packet(&KeepAlive { id: seq }).await?;
    //         }
    //         _ => {
    //             log::warn!("Received unhandled packet: {:?}", packet);
    //         }
    //     }
    // }
}

#[tokio::main]
pub async fn main() -> anyhow::Result<()> {
    web_commons::logger::attach_system_logger(LoggerOptions {
        log_level: LevelFilter::Debug,
        log_file: None,
    })?;
    log::info!("Server initializing!");

    if let Err(err) = shovel::spawn_server! {
        @bind "0.0.0.0:25565",
        @mc_status BasicStatus,
        client -> {
            log::info!("New client {:#?}", client.profile);
            client.compress_and_complete_login(COMPRESSION_THRESHOLD).await?;
            handover_authenticated_client(client).await
        }
    } {
        if matches!(err.error_type, ErrorType::EOF) {
            return Ok(());
        } else {
            log::error!("Server encountered an error: {:?}", err);
        }
    }
    Ok(())
}
