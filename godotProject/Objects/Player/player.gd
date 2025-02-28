class_name Player
extends CharacterBody2D


var ground_state := GroundPlayerState.new(self)
var air_state := AirPlayerState.new(self)
var state: PlayerState = ground_state


func _ready() -> void:
	transition(ground_state)


func transition(target: PlayerState, args := {}) -> void:
	state.exit()
	state = target
	state.enter(args)
