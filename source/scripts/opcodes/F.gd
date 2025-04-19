extends Node
class_name OpcodeF

# System

static func execute(core: CBMCore, opcode: int) -> Dictionary[String, bool]:
	var is_increment: bool = true
	var is_opcode: bool = true

	var x: int = (opcode & 0x0F00) >> 8

	match opcode & 0xFF:
		# Get delay
		0x07:
			core.register[x] = core.delay

		# Wait for key
		0x0A:
			is_increment = false

			if core.flags.is_awaiting_key and not core.flags.is_halting:
				core.flags.is_awaiting_key = false
				for key in range(16):
					if Input.is_action_just_released("%X" % key):
						core.register[x] = key
						is_increment = true
						break
			else:
				core.flags.is_halting = true
				core.flags.is_awaiting_key = true

		# Set delay
		0x15:
			core.delay = core.register[x]

		# Set sound
		0x18:
			core.sound = core.register[x]

		# Add Pointer with x
		0x1E:
			core.pointer += core.register[x]
			core.register[0xF] = int(core.pointer > 0xFFF)

		# Point to font
		0x29:
			core.pointer = 0x50 + (core.register[x] * 5)

		0x30:
			core.pointer = 0xA0 + (core.register[x] * 10)

		# Convert to decimal
		0x33:
			core.memory[core.pointer] = int(core.register[x] / 100)
			core.memory[core.pointer + 1] = int((core.register[x] / 10) % 10)
			core.memory[core.pointer + 2] = int(core.register[x] % 10)

		# Store Register to Memory
		0x55:
			for i in range(x + 1):
				core.memory[core.pointer + i] = core.register[i]
			if false: # Legacy
				core.pointer += x + 1

		# Load Memory to Register
		0x65:
			for i in range(x + 1):
				core.register[i] = core.memory[core.pointer + i]
			if false: # Legacy
				core.pointer += x + 1

		# Store Register to Storage
		0x75:
			for i in range(x + 1):
				core.storage[i] = core.register[i]

		# Load Storage to Register
		0x85:
			for i in range(x + 1):
				core.register[i] = core.storage[i]

		_: is_opcode = false

	return {
		"increment": is_increment,
		"valid": is_opcode,
	}
