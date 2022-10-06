extends AudioStreamPlayer

class PitchScalePosition:
	var duration: float
	var pitch_scale: float
	
	func _to_string():
		return "(d: %s, ps: %s)" % [duration, pitch_scale]

# min and max length in seconds
export (float) var min_duration
export (float) var max_duration
export (float) var min_pitch_scale
export (float) var max_pitch_scale

# array of PitchScalePositions in order
var psps = []
var pspsi: int = 0

var tween

var prev_pitch_scale = pitch_scale

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	
func prepare_to_play():
	var current_position: float = 0.0
	var final_position = stream.get_length()
	var last_psp_normal = true
	
	psps = []
	pspsi = 0
	
	while current_position < final_position:
		
		var psp = PitchScalePosition.new()
		psp.duration = rand_range(min_duration, max_duration)
		
		if last_psp_normal:
			psp.pitch_scale = rand_range(min_pitch_scale, max_pitch_scale)
			last_psp_normal = false
		else:
			psp.pitch_scale = 1
			last_psp_normal = true
		
		psps.append(psp)
		
		current_position += psp.duration
	
	print(psps)

func play(from_position: float = 0.0):
	stop()
	if (tween != null): tween.stop()
	pspsi = 0
	pitch_scale = 1
	prev_pitch_scale = pitch_scale
	play_next_adjust_pitch()
	.play(from_position)

func play_next_adjust_pitch():
	
	if (pspsi == psps.size()):
		return
	
	tween = get_tree().create_tween()
	tween.tween_property(self, "pitch_scale", psps[pspsi].pitch_scale, psps[pspsi].duration)
	tween.tween_callback(self, "play_next_adjust_pitch")
	pspsi += 1

func get_pitch_scale_1_position() -> Array:
	
	var psps1 = []
	var current_position = 0.0
	
	for psp in psps:
		
		current_position += psp.duration
		
		if (psp.pitch_scale == 1):
			psps1.append(current_position)
		
	
	print(psps1)
	
	return psps1.duplicate()
