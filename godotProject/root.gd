extends Node

const YOU_DIED_SCENE = preload("res://udied.tscn")

# An enum! This is basically just a set of named constant integers
enum GameState { IN_GAME, DEAD, MENU }

# Persistent data about the game state, will probably later add an inventory var etc.
# since when we switch levels the player gets deleted and forgets what it had
# but the root won't get deleted! In the future we could also use static classes/vars
# for persistent data.
var game_state = GameState.IN_GAME

func _ready():
	# this will probably cause a crash later lol
	get_tree().get_nodes_in_group("player")[0].player_death.connect(func():
				add_child(YOU_DIED_SCENE.instantiate())
				game_state = GameState.DEAD
				get_tree().get_nodes_in_group("player")[0].queue_free()
				)
