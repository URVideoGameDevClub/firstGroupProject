extends Node

signal player_health_updated(health: int)
signal player_respawned
signal player_damage_requested(damage: int)
signal player_death
signal door_entered(target_level: Main.ELevel, target_id: int)
signal checkpoint_entered(spawn_point: Vector2)
signal hurt_tp_area_entered
signal item_picked_up(item_kind: Main.ItemKind)

var main: Main