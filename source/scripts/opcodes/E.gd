extends Node
class_name OpcodeE

# Input

static func execute(core: CBMCore, opcode: int) -> Dictionary[String, bool]:
	var is_increment: bool = true
	var is_opcode: bool = true

	var x: int = (opcode & 0x0F00) >> 8

	match opcode & 0xFF:
				# If pressed
				0x9E:
					if Input.is_action_pressed("%X" % core.register[x]): core.counter += 2

				# If not pressed
				0xA1:
					if not Input.is_action_pressed("%X" % core.register[x]): core.counter += 2

	return {
		"increment": is_increment,
		"valid": is_opcode,
	}
