extends Node
class_name Opcode0

# Core

static func execute(core: CBMCore, opcode: int) -> Dictionary[String, bool]:
	var is_increment: bool = true
	var is_opcode: bool = true

	var y: int = (opcode & 0x00F0) >> 4
	var z: int = (opcode & 0x000F)

	match y:
		# Shift down
		0xC:
			for i: int in range(core.video.width * core.video.height - 1, -1, -1):
				core.buffer[i] = core.buffer[i - z * core.video.width] if i >= z * core.video.width else 0

		0xE:
			match z:
				# Clear
				0x0:
					core.buffer.fill(0)

				# Return
				0xE:
					if core.stack.size():
						core.counter = core.stack[-1]
						core.stack.remove_at(core.stack.size() - 1)

				_: is_opcode = false

		0xF:
			match z:
				# Shift right
				0xB:
					for py: int in core.video.height:
						for px: int in range(core.video.width - 1, -1, -1):
							var i: int = py * core.video.width + px
							core.buffer[i] = core.buffer[i- 4] if px >= 4 else 0

				# Shift left
				0xC:
					for py: int in core.video.height:
						for px: int in range(core.video.width):
							var i: int = py * core.video.width + px
							core.buffer[i] = core.buffer[i + 4] if px <= core.video.width - 4 - 1 else 0

				# Exit
				0xD:
					var reset_event = InputEventAction.new()
					reset_event.action = "Reset"
					reset_event.pressed = false
					Input.parse_input_event(reset_event)
					print("0x00FD EXECUTED, EXPECTED BEHAVIOR UNVERIFIED!")

				# Small mode
				0xE:
					core.set_hires(false)

				# Big mode
				0xF:
					core.set_hires(true)

				_: is_opcode = false

		_: is_opcode = false

	return {
		"increment": is_increment,
		"valid": is_opcode,
	}
