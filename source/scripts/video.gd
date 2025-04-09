extends TextureRect
class_name TextureDisplay

@export var width: int = 64
@export var height: int = 32
@export_custom(PROPERTY_HINT_RANGE, "0.0,1.0,0.05,suffix:exp") var fade_modifier: float = 0.8

var _dat: PackedByteArray
var _img: Image
var _tex: ImageTexture


func _ready() -> void:
	_img = Image.create_empty(width, height, false, Image.FORMAT_L8)
	_tex = ImageTexture.create_from_image(_img)
	set_texture(_tex)

func _process(_delta: float) -> void:
	var l8: PackedByteArray = _dat.duplicate()
	for i: int in l8.size():
		var val: int = _img.get_data()[i] * fade_modifier
		val = max(val, 0)

		l8[i] = 255 if l8[i] else val

	_img.set_data(width, height, false, Image.FORMAT_L8, l8)
	_tex.update(_img)


func flip(data: PackedByteArray) -> void:
	_dat = data.duplicate()
