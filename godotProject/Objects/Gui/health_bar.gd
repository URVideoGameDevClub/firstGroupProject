class_name HealthBar
extends Sprite2D


var current_health := 0
var crystals: Array[AnimatedSprite2D]


func _ready() -> void:
	Global.player_health_updated.connect(_on_player_health_updated)
	for child: AnimatedSprite2D in get_children():
		crystals.push_back(child)


func _on_player_health_updated(health: int) -> void:
	assert(health in range(0, 4))

	print(health)
	
	if health < current_health:
		for i: int in range(health, current_health):
			crystals[i].play(&"shatter")
	elif health > current_health:
		for i: int in range(current_health, health):
			crystals[i].play_backwards(&"shatter")
	
	current_health = health
