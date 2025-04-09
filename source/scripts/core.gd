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

	var x: int = (opcode & 0x0F00) >> 8
	var y: int = (opcode & 0x00F0) >> 4
	var z: int = (opcode & 0x000F)

	match opcode & 0xF000:
		# Core
		0x0000:
			match opcode & 0xFF:
				# Null
				0x00:
					pass

				# Clear
				0xE0:
					buffer.fill(0)

				# Return
				0xEE:
					if stack.size():
						counter = stack[-1]
						stack.remove_at(stack.size() - 1)

				_: is_opcode = false

		# Jump Counter
		0x1000:
			counter = opcode & 0xFFF
			is_increment = false

		# Call Counter
		0x2000:
			stack.append(counter)
			counter = opcode & 0xFFF
			is_increment = false

		# Skip next if x equal value
		0x3000:
			if register[x] == opcode & 0xFF: counter += 2

		# Skip next if x not equal value
		0x4000:
			if  register[x] != opcode & 0xFF: counter += 2

		# Skip next if x equal y
		0x5000:
			if opcode & 0xF == 0:
				if  register[x] ==  register[y]: counter += 2

		# Set Register
		0x6000:
			register[x] = opcode & 0xFF

		# Add Register
		0x7000:
			# Does not affect carry register[0xF]
			# Wrap around 8 bit
			register[x] = (register[x] + (opcode & 0xFF)) & 0xFF

		# Math and logic
		0x8000:
			var a: int = register[x]
			var b: int = register[y]
			match z:
				# Set
				0x0:
					register[x] = b

				# Bit OR
				0x1:
					register[x] = a | b

				# Bit AND
				0x2:
					register[x] = a & b

				# Bit XOR
				0x3:
					register[x] = a ^ b

				# Add with carry
				0x4:
					var sum: int = a + b
					register[0xF] = int(sum > 0xFF)
					register[x] = sum & 0xFF

				# Subtract x - y with carry if x bigger than y
				0x5:
					register[0xF] = int(a > b)
					register[x] = (a - b) & 0xFF

				# Bit shift right carry LSB
				0x6:
					if false: # Legacy
						register[x] = b
					register[0xF] = a & 0x1
					register[x] = a >> 1

				# Subtract y - x with carry if y bigger than x
				0x7:
					register[0xF] = int(b > a)
					register[x] = (b - a) & 0xFF

				# Bit shift left carry MSB
				0xE:
					if false: # Legacy
						register[x] = b
					register[0xF] = (a >> 7) & 0x1
					register[x] = (a << 1) & 0xFF

		# Skip next if x not equal y
		0x9000:
			if opcode & 0xF == 0:
				if  register[x] !=  register[y]: counter += 2

		# Jump Pointer
		0xA000:
			pointer = opcode & 0xFFF

		# Jump Counter with offset
		0xB000:
			var offset: int = register[x]
			if false: # Legacy
				offset = register[0x0]
			counter = (opcode & 0xFFF) + offset

		# Random number
		0xC000:
			register[x] = randi_range(0, 255) & (opcode & 0xFF)

		# Draw Sprite
		0xD000:

			register[0xF] = 0 # Reset carry collision

			for row: int in range(z):
				var byte: int = memory[pointer + row] # 1 byte width
				for i: int in range(8):
					var bit: int = (byte >> (7 - i)) & 1
					# Pixel position with edge wrap
					var draw_x = (register[x] + i) % VIDEO.WIDTH
					var draw_y = ( register[y] + row) % VIDEO.HEIGHT
					var pos = draw_y * VIDEO.WIDTH + draw_x

					# Carry collision
					if buffer[pos] and bit: register[0xF] = 1
					buffer[pos] ^= bit

		# Input
		0xE000:
			match opcode & 0xFF:
				# If pressed
				0x9E:
					if Input.is_action_pressed("%X" % register[x]): counter += 2

				# If not pressed
				0xA1:
					if not Input.is_action_pressed("%X" % register[x]): counter += 2

		# System
		0xF000:
			match opcode & 0xFF:
				# Get delay
				0x07:
					register[x] = delay

				# Wait for key
				0x0A:
					is_increment = false

					for key in range(16):
						if Input.is_action_just_released("%X" % key):
							register[x] = key
							is_increment = true
							break

				# Set delay
				0x15:
					delay = register[x]

				# Set sound
				0x18:
					sound = register[x]

				# Add Pointer with x
				0x1E:
					pointer += register[x]
					register[0xF] = int(pointer > 0xFFF)

				# Point to font
				0x29:
					pointer = 0x50 + (register[x] * 5)

				# Convert to decimal
				0x33:
					memory[pointer] = int(register[x] / 100)
					memory[pointer + 1] = int((register[x] / 10) % 10)
					memory[pointer + 2] = int(register[x] % 10)

				# Store Register to Memory
				0x55:
					for i in range(x + 1):
						memory[pointer + i] = register[i]
					if false: # Legacy
						pointer += x + 1

				# Load Memory to Register
				0x65:
					for i in range(x + 1):
						register[i] = memory[pointer + i]
					if false: # Legacy
						pointer += x + 1

				_: is_opcode = false

		_: is_opcode = false

	if not is_opcode: printerr("OPCODE INVALID: 0x%04X" % opcode)
	if is_increment: counter += 2 # 2 byte opcode size
	counter = clampi(counter, 0, 4096 - 2)

	delay = maxi(0 , delay - 1)
	sound = maxi(0 , sound - 1)
