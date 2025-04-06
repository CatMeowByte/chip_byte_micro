extends Node

@export var Core: CBMCore
@export var Display: TextureDisplay

func _ready():
	get_window().files_dropped.connect(on_files_dropped)
	Core.init()


func _process(_delta: float) -> void:
	for i in range(128):
		Core.execute()
	Display.flip(Core.buffer)


func on_files_dropped(files: PackedStringArray) -> void:
	Core.cartridge_load(files[0])
