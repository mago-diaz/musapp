extends Control

var _note_control
var _note
var _pitch_control
var _pitch
var _instrument_control
var _piano
var _instrument
var _visible = true
var minutes
var seconds
var total_time
var p_button
var r_button
var p_box
var current_song
var _instrument_index

# Called when the node enters the scene tree for the first time.
func _ready():
	_note_control = $HBoxContainer/Grabacion/NoteHbox/Note
	_pitch_control = $HBoxContainer/Grabacion/PitchHbox/Pitch
	_instrument_control = $HBoxContainer/Grabacion/InstrumentHbox/Instrument
	_piano = $HBoxContainer/Piano
	_note = _note_control.get_selected_id()
	_pitch = _pitch_control.get_selected_id() + 2 
	_instrument_index = _instrument_control.get_selected_id()
	_piano.create_piano(_note,_pitch, _instrument_index-1, _visible)
	p_button = $HBoxContainer/Grabacion/PlayHbox/Play
	r_button = $HBoxContainer/Grabacion/RecorderHbox/Record
	p_box = $HBoxContainer/Grabacion/PlayHbox
	p_box.set_visible(false)

func change_visible(Visible):
	_visible = Visible

func _on_button_down():
	_piano.stop_all_notes()
	
func _change_note(index):
	_note = index
	_piano.create_piano(_note,_pitch, _instrument_index-1, _visible)

func _change_pitch(index):
	_pitch = index + 2
	_piano.create_piano(_note,_pitch, _instrument_index-1, _visible)
	
func _change_instrument(index):
	_instrument_index = index
	_piano.create_piano(_note,_pitch, _instrument_index-1, _visible)


func _set_to_play_song(note, pitch, index_instrument):
	_note = note
	_note_control.select(_note)
	_pitch = pitch
	_pitch_control.select(_pitch - 2)
	_instrument_index = index_instrument +1
	_instrument_control.select(_instrument_index)
	_piano.create_piano(_note,_pitch, _instrument_index-1, _visible)

func disabled_control_buttons(value):
	_note_control.set_disabled(value)
	_pitch_control.set_disabled(value)
	_instrument_control.set_disabled(value)
		
func _on_record_toggled(button_pressed):
	if button_pressed:
		_piano.record_song()
		p_box.set_visible(false)
		disabled_control_buttons(true)
		seconds = 0 
		minutes = 0
		$HBoxContainer/Grabacion/RecorderHbox/Timer.start()
		r_button.text = "Detener Grabacion 00:00"
	else:
		_piano.stop_record_song()


func _on_piano_record_stopped():
	$HBoxContainer/Grabacion/RecorderHbox/Timer.stop()
	r_button.set_pressed_no_signal(false)
	if _piano.get_song()["notes"] != []:
		p_box.set_visible(true)
		current_song = _piano.get_song()
		total_time = minutes * 60 + seconds
	elif current_song:
		p_box.set_visible(true)
		_piano.set_song(current_song)
	r_button.text = "Volver a Responder (Grabar)"
	disabled_control_buttons(false)


func _on_play_toggled(button_pressed):
	if button_pressed:
		_piano.play_and_set_song()
		seconds = 0 
		minutes = 0
		disabled_control_buttons(true)
		p_button.text = "Detener 00:00"
		$HBoxContainer/Grabacion/PlayHbox/Timer.start()
	else:
		manually_stop_song()

func song_is_playing():
	return _piano.song_is_playing()

func stop_all_notes():
	_piano.stop_all_notes()
	_piano.stop_record_song()

func manually_stop_song():
	_piano.manually_stop_song()


func _on_piano_song_stopped():
	p_button.text = "Reproducir"
	p_button.set_pressed(false)
	r_button.set_disabled(false)
	disabled_control_buttons(false)
	$HBoxContainer/Grabacion/PlayHbox/Timer.stop()

func _on_piano_song_playing():
	r_button.text = "Volver a Responder (Grabar)"
	r_button.set_pressed(false)
	r_button.set_disabled(true)
	p_button.text = "Detener"
	p_button.set_pressed(true)
	
func get_answer():
	return _piano.get_song()

func load_answer(song):
	_piano.set_song(song)
	r_button.set_disabled(true)
	r_button.set_visible(false)
	disabled_control_buttons(true)
	p_box.set_visible(true)
	disable_input(true)


func disable_input(value):
	_piano.set_checking_piano(value)

func _on_timer_timeout():
	if seconds == 59:
		seconds = 0
		minutes += 1
	else:
		seconds += 1
	var string_seconds = str(seconds) if seconds > 9 else "0" + str(seconds)
	r_button.text = "Detener Grabacion 0" + str(minutes) + ":" + string_seconds



func _on_timer_timeout_play():
	if seconds == 59:
		seconds = 0
		minutes += 1
	else:
		seconds += 1
	var string_seconds = str(seconds) if seconds > 9 else "0" + str(seconds)
	p_button.text = "Detener 0" + str(minutes) + ":" + string_seconds

