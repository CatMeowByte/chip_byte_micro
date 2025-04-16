extends Node
class_name Opcode8

# Math and logic

static func execute(core: CBMCore, opcode: int) -> Dictionary[String, bool]:
	var is_increment: bool = true
	var is_opcode: bool = true

	var x: int = (opcode & 0x0F00) >> 8
	var y: int = (opcode & 0x00F0) >> 4
	var z: int = (opcode & 0x000F)

	var a: int = core.register[x]
	var b: int = core.register[y]

	match z:
		# Set
		0x0:
			core.register[x] = b

		# Bit OR
		0x1:
			core.register[x] = a | b

		# Bit AND
		0x2:
			core.register[x] = a & b

		# Bit XOR
		0x3:
			core.register[x] = a ^ b

		# Add with carry
		0x4:
			var sum: int = a + b
			core.register[x] = sum & 0xFF
			core.register[0xF] = int(sum > 0xFF)

		# Subtract x - y with carry if x bigger than y
		0x5:
			core.register[x] = (a - b) & 0xFF
			core.register[0xF] = int(a >= b)

		# Bit shift right carry LSB
		0x6:
			if false: # Legacy
				core.register[x] = b
			core.register[x] = a >> 1
			core.register[0xF] = a & 0x1

		# Subtract y - x with carry if y bigger than x
		0x7:
			core.register[x] = (b - a) & 0xFF
			core.register[0xF] = int(b >= a)

		# Bit shift left carry MSB
		0xE:
			if false: # Legacy
				core.register[x] = b
			core.register[x] = (a << 1) & 0xFF
			core.register[0xF] = (a >> 7) & 0x1

		_: is_opcode = false

	return {
		"increment": is_increment,
		"valid": is_opcode,
	}
