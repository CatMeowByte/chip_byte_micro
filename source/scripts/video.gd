extends TextureRect
class_name TextureDisplay

@export_custom(PROPERTY_HINT_RANGE, "0.0,1.0,0.05,suffix:exp") var fade_modifier: float = 0.8

var _dat: PackedByteArray
var _img: Image
var _tex: ImageTexture
var _is_hires: bool = false


func _ready() -> void:
	_img = Image.create_empty(128, 64, false, Image.FORMAT_L8)
	_tex = ImageTexture.create_from_image(_img)
	set_texture(_tex)


func _process(_delta: float) -> void:
	var l8: PackedByteArray = _img.get_data()
	var out: PackedByteArray = l8.duplicate()

	if _is_hires:
		material.set("shader_parameter/texture_width", 128)
		material.set("shader_parameter/texture_height", 64)
		for i: int in _dat.size():
			var val: int = l8[i] * fade_modifier
			val = max(val, 0)
			out[i] = 255 if _dat[i] else val
	else:
		material.set("shader_parameter/texture_width", 64)
		material.set("shader_parameter/texture_height", 32)
		# lowres: draw 64x32 onto 128x64
		for y: int in 32:
			for x: int in 64:
				var src_i: int = y * 64 + x
				var v: int = _dat[src_i]
				for dy: int in 2:
					for dx: int in 2:
						var dst_x: int = x * 2 + dx
						var dst_y: int = y * 2 + dy
						var dst_i: int = dst_y * 128 + dst_x
						var val: int = l8[dst_i] * fade_modifier
						val = max(val, 0)
						out[dst_i] = 255 if v else val

	_img.set_data(128, 64, false, Image.FORMAT_L8, out)
	_tex.update(_img)


func flip(data: PackedByteArray, hires: bool = false) -> void:
	_dat = data.duplicate()
	_is_hires = hires
