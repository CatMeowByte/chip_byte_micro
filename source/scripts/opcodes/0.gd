extends Node
class_name Opcode0

# Core

static func execute(core: CBMCore, opcode: int) -> Dictionary[String, bool]:
	var is_increment: bool = true
	var is_opcode: bool = true

	match opcode & 0xFF:
		# Null
		0x00:
			pass

		# Clear
		0xE0:
			core.buffer.fill(0)

		# Return
		0xEE:
			if core.stack.size():
				core.counter = core.stack[-1]
				core.stack.remove_at(core.stack.size() - 1)

		_: is_opcode = false

	return {
		"increment": is_increment,
		"valid": is_opcode,
	}
