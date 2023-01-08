use drax::ctg;
use drax::nbt::{read_nbt, CompoundTag, Tag};
use drax::prelude::PacketComponent;
use mcprotocol::clientbound::play::ClientboundPlayRegistry::{
    ClientLogin, Commands, CustomPayload, LevelChunkWithLight, PlayerAbilities, PlayerPosition,
};
use mcprotocol::clientbound::play::{
    DelegateStr, LevelChunkData, LightUpdateData, RelativeArgument,
};
use mcprotocol::common::bit_set::BitSet;
use mcprotocol::common::chunk::Chunk;
use mcprotocol::common::play::{CommandEntry, CommandNode, Location, SimpleLocation};
use shovel::server::ServerPlayer;
use std::io::Cursor;

pub async fn dimension_from_protocol(protocol_version: i32) -> drax::prelude::Result<CompoundTag> {
    let mut buf = Cursor::new(match protocol_version {
        761 => Vec::from(*include_bytes!("761.b.nbt")),
        _ => Vec::from(*include_bytes!("761.b.nbt")),
    });
    read_nbt(&mut buf, 0x200000u64)
        .await
        .map(|x| x.expect("Compound tag should exist."))
}

pub async fn send_dimension_info(player: &mut ServerPlayer) -> drax::prelude::Result<()> {
    let biome_tag = dimension_from_protocol(761)
        .await
        .unwrap()
        .get_tag(&"minecraft:worldgen/biome".to_string())
        .cloned()
        .unwrap();

    let join_game_tag = ctg! {
        "minecraft:dimension_type": {
            "type": "minecraft:dimension_type",
            "value": [ctg!{
                "name": "minecraft:overworld",
                "id": 0,
                "element": {
                    "natural": 1u8,
                    "coordinate_scale": 1.0f64,
                    "natural": 1u8,
                    "coordinate_scale": 1.0f64,
                    "height": 384,
                    "min_y": -64i32,
                    "piglin_safe" : 0u8,
                    "has_raids": 1u8,
                    "logical_height": 384,
                    "ultrawarm": 0u8,
                    "bed_works": 1u8,
                    "respawn_anchor_works" : 0u8,
                    "ambient_light": 0.0f32,
                    "effects" : "minecraft:overworld",
                    "has_skylight": 1u8,
                    "monster_spawn_block_light_limit": 0,
                    "infiniburn": "#minecraft:infiniburn_overworld",
                    "has_ceiling": 0u8,
                    "monster_spawn_light_level" : {
                        "type": "minecraft:uniform",
                        "value": {
                            "min_inclusive": 0,
                            "max_inclusive": 7
                        }
                    }
                }
            }]
        },
        "minecraft:worldgen/biome": biome_tag,
        "minecraft:chat_type": {
            "type": "minecraft:chat_type",
            "value": [ctg!{
                "name": "minecraft:chat",
                "id": 0,
                "element": {
                    "narration": {
                        "translation_key": "chat.type.text.narrate",
                        "parameters": (Tag::ListTag(8, vec! [
                            Tag::string_tag("sender"),
                            Tag::string_tag("content"),
                        ]))
                    },
                    "chat": {
                        "translation_key": "chat.type.text",
                        "parameters": (Tag::ListTag(8, vec! [
                            Tag::string_tag("sender"),
                            Tag::string_tag("content"),
                        ]))
                    }
                }
            }]
        }
    };

    player
        .write_packet(&ClientLogin {
            player_id: 1,
            hardcore: false,
            game_type: 2,
            previous_game_type: 255,
            levels: vec!["minecraft:overworld".to_string()],
            codec: Some(join_game_tag),
            dimension_type: "minecraft:overworld".to_string(),
            dimension: "minecraft:overworld".to_string(),
            seed: 0,
            max_players: 20,
            chunk_radius: 0,
            simulation_distance: 10,
            reduced_debug_info: false,
            show_death_screen: true,
            is_debug: false,
            is_flat: false,
            last_death_location: None,
        })
        .await?;

    let mut brand_data = Cursor::new(Vec::new());
    DelegateStr::encode(&"Shovel Demo", &mut (), &mut brand_data).await?;
    player
        .write_packet(&CustomPayload {
            identifier: format!("minecraft:brand"),
            data: brand_data.into_inner(),
        })
        .await?;

    player
        .write_packet(&PlayerAbilities {
            flags: 0x3,
            flying_speed: 0.1,
            walking_speed: 0.1,
        })
        .await?;

    player
        .write_packet(&PlayerPosition {
            location: Location {
                inner_loc: SimpleLocation {
                    x: 0.0,
                    y: 50.0,
                    z: 0.0,
                },
                yaw: 0.0,
                pitch: 0.0,
            },
            relative_arguments: RelativeArgument::new(0x8),
            id: 0,
            dismount: false,
        })
        .await?;

    log::info!(
        "Successfully logged in player {} ({})",
        player.profile.name,
        player.profile.id
    );

    player
        .write_packet(&Commands {
            commands: vec![CommandNode::Root {
                entry: CommandEntry {
                    flags: 0,
                    redirect: 0,
                    children: vec![],
                },
            }],
            root_index: 0,
        })
        .await?;

    for x in -5..5 {
        for z in -5..5 {
            let mut chunk = Chunk::new(x, z);
            chunk.rewrite_plane(1, 3).expect("Plane should rewrite.");
            chunk.rewrite_plane(2, 3).expect("Plane should rewrite.");
            chunk.rewrite_plane(3, 1).expect("Plane should rewrite.");
            chunk.rewrite_plane(4, 2).expect("Plane should rewrite.");

            chunk.set_block_id(7, 25, 8, 2).expect("Block should set");

            player
                .write_packet(&LevelChunkWithLight {
                    chunk_data: LevelChunkData {
                        chunk,
                        block_entities: vec![],
                    },
                    light_data: LightUpdateData {
                        trust_edges: true,
                        sky_y_mask: BitSet::value_of(vec![])?,
                        block_y_mask: BitSet::value_of(vec![])?,
                        empty_sky_y_mask: BitSet::value_of(vec![])?,
                        empty_block_y_mask: BitSet::value_of(vec![])?,
                        sky_updates: vec![vec![]; 2048],
                        block_updates: vec![vec![]; 2048],
                    },
                })
                .await?;
        }
    }
    Ok(())
}
