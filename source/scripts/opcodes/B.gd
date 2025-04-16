extends Node
class_name OpcodeB

# Jump Counter with offset

static func execute(core: CBMCore, opcode: int) -> Dictionary[String, bool]:
	var is_increment: bool = true
	var is_opcode: bool = true

	var x: int = (opcode & 0x0F00) >> 8

	var offset: int = core.register[x]
	if false: # Legacy
		offset = core.register[0x0]
	core.counter = (opcode & 0xFFF) + offset

	return {
		"increment": is_increment,
		"valid": is_opcode,
	}
