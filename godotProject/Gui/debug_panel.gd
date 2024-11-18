extends CanvasLayer


@onready var panel_container := $PanelContainer


var labels: Array[Node] = []


func _ready() -> void:
	labels = panel_container.get_children()

