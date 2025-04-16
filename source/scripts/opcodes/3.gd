extends Node
class_name Opcode3

# Skip next if x equal value

static func execute(core: CBMCore, opcode: int) -> Dictionary[String, bool]:
	var is_increment: bool = true
	var is_opcode: bool = true

	var x: int = (opcode & 0x0F00) >> 8

	if core.register[x] == opcode & 0xFF: core.counter += 2

	return {
		"increment": is_increment,
		"valid": is_opcode,
	}
