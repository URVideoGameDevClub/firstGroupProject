class_name HealthBar
extends TextureRect

var _crystals: Array[AnimatedSprite2D]
var _health := 3


func _enter_tree() -> void:
    Global.player_health_updated.connect(_on_player_health_updated)


func _ready() -> void:
    for child: AnimatedSprite2D in get_children():
        _crystals.push_back(child)
        child.play_backwards(&"shatter")


func _on_player_health_updated(health: int) -> void:
    assert(health in range(0, 4), "health '%d' out of range(0, 4)" % health)
    
    if health < _health:
        for i: int in range(health, _health):
            _crystals[i].play(&"shatter")
    elif health > _health:
        for i: int in range(_health, health):
            _crystals[i].play_backwards(&"shatter")
    
    _health = health
    