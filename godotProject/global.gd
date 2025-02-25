## Global singleton class, mainly for signals right now
extends Node


signal door_entered(door: Door)
signal enemy_death(enemy: Enemy)
signal player_health_updated(health: int)
signal player_death
signal item_added(item_name: String)
signal spike_hit
signal checkpoint_entered(pos: Marker2D)
signal show_crown_anim


var root: Route
var paused := false
