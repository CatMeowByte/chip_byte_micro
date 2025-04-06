extends TouchScreenButton
class_name TouchScreenButtonAction

var _tex: Array[Texture2D]


func _ready() -> void:
	_tex = [get_texture_normal(), get_texture_pressed()]


func _input(_event: InputEvent) -> void:
	set_texture_normal(_tex[int(Input.is_action_pressed(get_action()))])
