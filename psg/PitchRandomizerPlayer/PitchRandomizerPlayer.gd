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
var psps1 = []

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	
func prepare_to_play():
	var current_position: float = 0.0
	var final_position = stream.get_length()
	
	psps = []
	pspsi = 0
	
	while current_position < final_position:
		
		var psp = PitchScalePosition.new()
		psp.duration = rand_range(min_duration, max_duration)
		psp.pitch_scale = rand_range(min_pitch_scale, max_pitch_scale)
		
		psps.append(psp)
		
		current_position += psp.duration

func play(from_position: float = 0.0):
	psps1 = []
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
	
	#var psps1 = []
	#var current_position: float = 0.0
	
	#var pspo = psps[0]
	#current_position += pspo.duration
	
	#for pspn in psps.slice(1, psps.size()):
		
	#	if sign(pspo.pitch_scale - 1) != sign(pspn.pitch_scale - 1):
			
	#		var x1 = current_position
	#		var y1 = pspo.pitch_scale
	#		var x2 = current_position + pspn.duration
	#		var y2 = pspn.pitch_scale
			
	#		var zero_position = x1 - (((x2 - x1) / (y2 - y1)) * y1)
			
	#		psps1.append(zero_position)
	
	return psps1.duplicate()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if pitch_scale != prev_pitch_scale:
		if sign(pitch_scale - 1) != sign(prev_pitch_scale - 1):
			psps1.append(get_playback_position())
		prev_pitch_scale = pitch_scale
