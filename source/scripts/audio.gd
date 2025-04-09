extends AudioStreamPlayer
class_name AudioStreamBeeper

var playback: AudioStreamGeneratorPlayback
var phase: float = 0.0
var volume_prev: float = 0.0

func _ready() -> void:
	assert(stream is AudioStreamGenerator)

	play()
	playback = get_stream_playback()

func tone_emit(volume: float, pitch: float) -> void:
	var frames: int = playback.get_frames_available()

	for i: float in frames:
		var volume_smooth: float = lerp(volume_prev, volume, i / float(frames))
		playback.push_frame(Vector2.ONE * sin(phase * TAU) * volume_smooth)
		phase = fmod(phase + pitch / stream.mix_rate, 1.0)

	volume_prev = volume
