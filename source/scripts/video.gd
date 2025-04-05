extends TextureRect

@export var width: int = 64
@export var height: int = 32
@export_custom(PROPERTY_HINT_NONE, "suffix:frames") var fade_duration: int = 2

var _dat: PackedByteArray
var _img: Image
var _tex: ImageTexture


func _ready() -> void:
	_img = Image.create_empty(width, height, false, Image.FORMAT_L8)
	_tex = ImageTexture.create_from_image(_img)
	set_texture(_tex)

func _process(_delta: float) -> void:
	var l8: PackedByteArray = _dat.duplicate()
	var fade: int = 255 / fade_duration
	for i: int in l8.size():
		var val: float = _img.get_data()[i] - fade
		val = max(val, 0)

		l8[i] = 255 if l8[i] else int(val)

	_img.set_data(width, height, false, Image.FORMAT_L8, l8)
	_tex.update(_img)


func flip(data: PackedByteArray) -> void:
	_dat = data.duplicate()
