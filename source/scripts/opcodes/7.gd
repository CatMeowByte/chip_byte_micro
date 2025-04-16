extends Node
class_name Opcode7

# Add Register

static func execute(core: CBMCore, opcode: int) -> Dictionary[String, bool]:
	var is_increment: bool = true
	var is_opcode: bool = true

	var x: int = (opcode & 0x0F00) >> 8

	# Does not affect carry register[0xF]
	# Wrap around 8 bit
	core.register[x] = (core.register[x] + (opcode & 0xFF)) & 0xFF

	return {
		"increment": is_increment,
		"valid": is_opcode,
	}
