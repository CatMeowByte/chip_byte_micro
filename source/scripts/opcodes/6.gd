extends Node
class_name Opcode6

# Set Register

static func execute(core: CBMCore, opcode: int) -> Dictionary[String, bool]:
	var is_increment: bool = true
	var is_opcode: bool = true

	var x: int = (opcode & 0x0F00) >> 8

	core.register[x] = opcode & 0xFF

	return {
		"increment": is_increment,
		"valid": is_opcode,
	}
