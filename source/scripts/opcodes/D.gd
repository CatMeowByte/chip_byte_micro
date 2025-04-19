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

	var draw_16: bool = not z
	var sprite_w: int = 16 if draw_16 else 8
	var sprite_h: int = 16 if draw_16 else z

	for row: int in range(sprite_h):
		var offset: int = row * (2 if draw_16 else 1) # 2 bytes per row in 16
		var byte_hi: int = core.memory[core.pointer + offset]
		var byte_lo: int = core.memory[core.pointer + offset + 1] if draw_16 else 0

		for i: int in range(sprite_w):
			var src: int = byte_hi if i < 8 else byte_lo
			var bit: int = (src >> (7 - (i & 7))) & 1
			# Pixel position with edge wrap
			var draw_x = (core.register[x] + i) % core.video.width
			var draw_y = ( core.register[y] + row) % core.video.height
			var pos = draw_y * core.video.width + draw_x

			# Carry collision
			if core.buffer[pos] and bit: core.register[0xF] = 1
			core.buffer[pos] ^= bit

	return {
		"increment": is_increment,
		"valid": is_opcode,
	}
