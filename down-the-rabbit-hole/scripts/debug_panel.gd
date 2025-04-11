extends PanelContainer

@onready var _button_container: VBoxContainer = $ButtonContainer
@onready var _damage_player_button: Button = $ButtonContainer/DamagePlayerButton


func _on_damage_player_button_pressed() -> void:
    Global.player_damage_requested.emit(1)
