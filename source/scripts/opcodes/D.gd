extends Node
class_name OpcodeD

# Draw sprite

static func execute(core: CBMCore, opcode: int) -> Dictionary[String, bool]:
	var is_increment: bool = true
	var is_opcode: bool = true

	var x: int = (opcode & 0x0F00) >> 8
	var y: int = (opcode & 0x00F0) >> 4
	var z: int = (opcode & 0x000F)

	core.register[0xF] = 0 # Reset carry collision

	for row: int in range(z):
		var byte: int = core.memory[core.pointer + row] # 1 byte width
		for i: int in range(8):
			var bit: int = (byte >> (7 - i)) & 1
			# Pixel position with edge wrap
			var draw_x = (core.register[x] + i) % core.VIDEO.WIDTH
			var draw_y = ( core.register[y] + row) % core.VIDEO.HEIGHT
			var pos = draw_y * core.VIDEO.WIDTH + draw_x

			# Carry collision
			if core.buffer[pos] and bit: core.register[0xF] = 1
			core.buffer[pos] ^= bit

	return {
		"increment": is_increment,
		"valid": is_opcode,
	}
