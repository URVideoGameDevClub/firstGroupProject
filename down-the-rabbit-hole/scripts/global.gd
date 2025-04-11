extends Node

signal player_health_updated(health: int)
signal player_respawned
signal player_damage_requested(damage: int)

var main: Main