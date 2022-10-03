extends Control

var position = 0

var click_positions = []

export (float) var flexibility = 5.0

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	position = $PitchRandomizerPlayer.get_playback_position()
	
	$VBoxContainer/ProgressBar.value = position
	
func _on_LoadAudioFileButton_pressed():
	$FileDialog.access = $FileDialog.ACCESS_FILESYSTEM
	$FileDialog.current_dir = "/"
	$FileDialog.popup()

func _on_FileDialog_file_selected(path):
	
	$VBoxContainer/SongLabel.text = path.get_file()
	
	$PitchRandomizerPlayer.stream = load_audio_from_file(path)
	$PitchRandomizerPlayer.prepare_to_play()
	
	$VBoxContainer/ProgressBar.max_value = $PitchRandomizerPlayer.stream.get_length()

func load_audio_from_file(filepath: String) -> AudioStream:
	var exten = filepath.get_extension().to_lower()
	var file = File.new()
	var err = file.open(filepath, File.READ)
	
	if (err != OK):
		file.close()
		return null
		
	var data = file.get_buffer(file.get_len())
	file.close()
	
	return load_audio_from_bytes(data, exten)

func load_audio_from_bytes(data: PoolByteArray, exten: String) -> AudioStream:
	var stream
	match exten:
		"ogg": stream = AudioStreamOGGVorbis.new()
		"mp3": stream = AudioStreamMP3.new()
		"wav": stream = AudioStreamSample.new()
		_: return null
	
	stream.data = data
	stream.loop = false
	
	return stream

func _on_Button_pressed():
	click_positions = []
	$PitchRandomizerPlayer.play()

func _on_ClickButton_pressed():
	click_positions.append(position)


func _on_PitchRandomizerPlayer_finished():
	
	var pitch_scale_1_positions = $PitchRandomizerPlayer.get_pitch_scale_1_position().duplicate()
	var local_click_positions = click_positions.duplicate()
	
	print(pitch_scale_1_positions)
	print(local_click_positions)
	
	var num_clicks = local_click_positions.size()
	var num_correct = 0
	var num_1_positions = pitch_scale_1_positions.size()
	
	for cp in local_click_positions:
		var inverted_range = range(pitch_scale_1_positions.size())
		inverted_range.invert()
		for ip in inverted_range:
			var p = pitch_scale_1_positions[ip]
			if p - flexibility <= cp and cp <= p + flexibility:
				num_correct += 1
				pitch_scale_1_positions.remove(ip)
				print(pitch_scale_1_positions)
	
	if num_clicks == 0:
		if num_1_positions == 0:
			$PopupDialog/VBoxContainer/Label.text = "You correctly clicked 0 times. Score: 100%"
		else:
			$PopupDialog/VBoxContainer/Label.text = "You clicked 0 times. It returned to the original pitch " + str(num_1_positions) + " times. Score: 0%"
	else:	
		$PopupDialog/VBoxContainer/Label.text = "You got " + str(num_correct) + "/" + str(num_clicks) + " clicks correct. Score:" + str(100 * float(num_correct) / float(num_clicks)) + "%"
	
	$PopupDialog.show()
	


func _on_CloseButton_pressed():
	$PopupDialog.hide()


func _on_RandomizeButton_pressed():
	$PitchRandomizerPlayer.prepare_to_play()
	$PopupDialog.hide()

func _on_MinPitchScaleHSlider_value_changed(value):
	$PitchRandomizerPlayer.min_pitch_scale = value
	$VBoxContainer/MinPitchScaleHBoxContainer/Label.text = "Min pitch scale: " + str(value)

func _on_MaxPitchScaleHSlider_value_changed(value):
	$PitchRandomizerPlayer.max_pitch_scale = value
	$VBoxContainer/MaxPitchScaleHBoxContainer/Label.text = "Max pitch scale: " + str(value)

func _on_FlexibilityHSlider_value_changed(value):
	flexibility = value
	$VBoxContainer/FlexibiityHBoxContainer/Label.text = "Click flexibility (seconds): " + str(value)


func _on_MinDurationHSlider_value_changed(value):
	$PitchRandomizerPlayer.min_duration = value
	$VBoxContainer/MinDurationHBoxContainer/Label.text = "Min pitch shift duration (seconds): " + str(value)


func _on_MaxDurationHSlider_value_changed(value):
	$PitchRandomizerPlayer.max_duration = value
	$VBoxContainer/MaxDurationHBoxContainer/Label.text = "Max pitch shift duration (seconds): " + str(value)
