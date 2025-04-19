extends Node

@export var Core: CBMCore
@export var Display: TextureDisplay
@export var Audio: AudioStreamBeeper
@export var BeeperSprite: AnimatedSprite2D

func _ready():
	get_window().files_dropped.connect(on_files_dropped)
	Core.init()


func _process(_delta: float) -> void:
	for i in range(128):
		Core.execute()
	Core.state_update()
	Display.flip(Core.buffer, Core.flags.is_hires)
	Audio.tone_emit(float(Core.sound > 0) * 0.5, 523.25)
	BeeperSprite.frame = int(Core.sound > 0)


func _input(event: InputEvent) -> void:
	if event.is_action_released("Reset"):
		Core.init()


func on_files_dropped(files: PackedStringArray) -> void:
	Core.cartridge_load(files[0])
