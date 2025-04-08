extends Node
class_name CBMCore

const VIDEO: Dictionary[String, int] = {
	WIDTH = 64,
	HEIGHT = 32,
}
const FONT: Array[int] = [
	0xE0, 0xA0, 0xA0, 0xA0, 0xE0, # 0
	0xC0, 0x40, 0x40, 0x40, 0xE0, # 1
	0xE0, 0x20, 0xE0, 0x80, 0xE0, # 2
	0xE0, 0x20, 0xE0, 0x20, 0xE0, # 3
	0xA0, 0xA0, 0xE0, 0x20, 0x20, # 4
	0xE0, 0x80, 0xE0, 0x20, 0xE0, # 5
	0xE0, 0x80, 0xE0, 0xA0, 0xE0, # 6
	0xE0, 0x20, 0x40, 0x40, 0x40, # 7
	0xE0, 0xA0, 0xE0, 0xA0, 0xE0, # 8
	0xE0, 0xA0, 0xE0, 0x20, 0xE0, # 9
	0xE0, 0xA0, 0xE0, 0xA0, 0xA0, # A
	0xC0, 0xA0, 0xE0, 0xA0, 0xC0, # B
	0xE0, 0x80, 0x80, 0x80, 0xE0, # C
	0xC0, 0xA0, 0xA0, 0xA0, 0xC0, # D
	0xE0, 0x80, 0xE0, 0x80, 0xE0, # E
	0xE0, 0x80, 0xE0, 0x80, 0x80  # F
]

var memory: PackedByteArray # 4096 byte
var buffer: PackedByteArray # should be 256 byte but 2048 for convenience
var register: PackedByteArray # 16 byte
var stack: PackedInt32Array # should be 16 * 2 byte but only exist int32

var delay: int = 0 # 1 byte
var sound: int = 0 # 1 byte

var counter: int = 0 # 2 byte
var pointer: int = 0 # 2 byte


func init() -> void:
	memory.resize(4096)
	buffer.resize(VIDEO.WIDTH * VIDEO.HEIGHT)
	register.resize(16)
	stack.resize(16)

	memory.fill(0)
	buffer.fill(0)
	register.fill(0)
	stack.fill(0)

	delay = 0
	sound = 0
	counter = 0x0FFE
	pointer = 0

	# Load font
	for i: int in FONT.size():
		memory[0x50 + i] = FONT[i]


func cartridge_load(path: String) -> void:
	if not path.to_lower().ends_with(".ch8"):
		printerr("CARTRIDGE INVALID: ", path)
		return

	init()

	var cartridge: FileAccess = FileAccess.open(path, FileAccess.READ)
	if not cartridge: return

	pointer = 0x200
	while not cartridge.eof_reached():
		if pointer >= memory.size():
			printerr("CARTRIDGE LOAD MEMORY OVERFLOW")
			break
		memory[pointer] = cartridge.get_8()
		pointer += 1

	counter = 0x200
	print("CARTRIDGE LOADED: ", path)


func execute() -> void:
	if counter < 0 or counter + 1 >= memory.size():
		printerr("COUNTER OUT OF BOUNDS: ", counter)
		return

	var opcode: int = memory[counter] << 8 | memory[counter + 1]
	var is_increment: bool = true
	var is_opcode: bool = true

	match opcode & 0xF000:
		# Core
		0x0000:
			match opcode & 0xFF:
				0x00:
					pass

				# Clear
				0xE0:
					buffer.fill(0)

				0xEE:
					pass

				_: is_opcode = false

		# Jump Counter
		0x1000:
			counter = opcode & 0xFFF
			is_increment = false

		# Set Register
		0x6000:
			register[(opcode & 0xF00) >> 8] = opcode & 0xFF

		# Add Register
		0x7000:
			# Does not affect carry register[0xF]
			# Wrap around 8 bit
			register[(opcode & 0xF00) >> 8] += opcode & 0xFF

		# Jump Pointer
		0xA000:
			pointer = opcode & 0xFFF

		# Draw Sprite
		0xD000:
			var x: int = register[(opcode & 0xF00) >> 8]
			var y: int = register[(opcode & 0xF0) >> 4]
			var h: int = opcode & 0xF

			register[0xF] = 0 # Reset carry collision

			for row: int in range(h):
				var byte: int = memory[pointer + row] # 1 byte width
				for i: int in range(8):
					var bit: int = (byte >> (7 - i)) & 1
					# Pixel position with edge wrap
					var draw_x = (x + i) % VIDEO.WIDTH
					var draw_y = (y + row) % VIDEO.HEIGHT
					var pos = draw_y * VIDEO.WIDTH + draw_x

					# Carry collision
					if buffer[pos] and bit: register[0xF] = 1
					buffer[pos] ^= bit

		# System
		0xF000:
			var i: int = register[(opcode & 0xF00) >> 8]
			match opcode & 0xFF:
				0x29:
					pointer = 0x50 + (i * 5)

				_: is_opcode = false

		_: is_opcode = false

	if not is_opcode: printerr("OPCODE INVALID: 0x%04X" % opcode)
	if is_increment: counter = clampi(counter + 2, 0, 4096 - 2)  # 2 byte opcode size
