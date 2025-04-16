extends Node
class_name Opcode5

# Skip next if x equal y

static func execute(core: CBMCore, opcode: int) -> Dictionary[String, bool]:
	var is_increment: bool = true
	var is_opcode: bool = true

	var x: int = (opcode & 0x0F00) >> 8
	var y: int = (opcode & 0x00F0) >> 4

	if opcode & 0xF == 0:
		if core.register[x] == core.register[y]: core.counter += 2

	return {
		"increment": is_increment,
		"valid": is_opcode,
	}
