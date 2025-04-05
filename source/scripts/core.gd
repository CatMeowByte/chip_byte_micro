extends Node

@onready var Display: TextureRect = %Top/%Display

var memory: PackedByteArray # 4096 byte
var buffer: PackedByteArray # 2048 bit / 8 = 256 byte
var register: PackedByteArray # 16 byte
var stack: PackedInt32Array # 16 * 2 byte

var delay: int = 0 # 8 byte
var sound: int = 0 # 8 byte

var counter: int = 0 # 8 byte
var pointer: int = 0 # 2 byte


func _ready() -> void:
	memory.resize(4096)
	buffer.resize(64 * 32)

	cartridge_load("/media/beta/game/chip 8/IBM Logo.ch8")

func _process(_delta: float) -> void:
	buffer.fill(0)
	execute()
	Display.flip(buffer)

func cartridge_load(path: String) -> void:
	var cartridge: FileAccess = FileAccess.open(path, FileAccess.READ)
	pointer = 0x200
	while not cartridge.eof_reached():
		if pointer >= memory.size():
			printerr("CARTRIDGE LOAD: MEMORY OVERFLOW")
			break
		memory[pointer] = cartridge.get_8()
		pointer += 1

func execute() -> void:
	buffer[(randi_range(0, 31) * 64) + randi_range(0, 63)] = 1
