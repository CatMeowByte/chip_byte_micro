extends Node
class_name OpcodeA

# Jump Pointer

static func execute(core: CBMCore, opcode: int) -> Dictionary[String, bool]:
	var is_increment: bool = true
	var is_opcode: bool = true

	core.pointer = opcode & 0xFFF

	return {
		"increment": is_increment,
		"valid": is_opcode,
	}
