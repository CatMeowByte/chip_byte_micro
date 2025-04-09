extends TouchScreenButton
class_name TouchScreenButtonAction

var _tex: Array[Texture2D]


func _ready() -> void:
	_tex = [texture_normal, texture_pressed]


func _input(_event: InputEvent) -> void:
	texture_normal = _tex[int(Input.is_action_pressed(action))]
