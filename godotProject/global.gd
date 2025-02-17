## Global singleton class, mainly for signals right now
extends Node


signal door_entered(door: NewDoor)
signal enemy_death(enemy: Enemy)
signal player_health_updated(health: int)
