extends Node
class_name Opcode1

# Jump Counter

static func execute(core: CBMCore, opcode: int) -> Dictionary[String, bool]:
	var is_increment: bool = true
	var is_opcode: bool = true

	core.counter = opcode & 0xFFF
	is_increment = false

	return {
		"increment": is_increment,
		"valid": is_opcode,
	}
