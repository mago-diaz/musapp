extends Control

#Note and Key Creation
var _notes = ["C","D","E","F","G","A","B"]
var _white_words = ["A","S","D","F","G","H","J","K","L","Ñ"]
var _black_words = ["W","E","R","T","Y","U","I","O","P"]
var _keys = []
var _init_note_idx = 0
var _init_pitch = 4
var isVisible = true
var _index_instrument = 5
var _note = preload("res://Classes/Notes.gd")
var _white_key = preload("res://Scenes/Piano/WhiteKey.tscn")
var _black_key = preload("res://Scenes/Piano/BlackKey.tscn")
var _empty = preload("res://Scenes/Piano/Empty.tscn")
var _white_keys 
var _black_keys
const NUM_WHITE_KEYS = 10
const NUM_BLACK_KEYS = 9
var _instruments = [{'instrument' : preload("res://Audios/Instrument/A4/Acordeon.wav"), 'note' : 'A4'},
					{'instrument': preload("res://Audios/Instrument/A4/Clarinete.wav"), 'note' : 'A4'},
					{'instrument': preload("res://Audios/Instrument/A2/ContraBajo.wav"), 'note' : 'A2'},
					{'instrument': preload("res://Audios/Instrument/A3/Fagot.wav"), 'note' : 'A3'},
					{'instrument': preload("res://Audios/Instrument/A5/Flauta.wav"), 'note' : 'A5'},
					{'instrument': preload("res://Audios/Instrument/A4/Piano.wav"), 'note' : 'A4'},
					{'instrument': preload("res://Audios/Instrument/A4/Saxofon.wav"), 'note' : 'A4'},
					{'instrument': preload("res://Audios/Instrument/A3/Trombon.wav"), 'note' : 'A3'},
					{'instrument': preload("res://Audios/Instrument/A4/Trompeta.wav"), 'note' : 'A4'},
					{'instrument': preload("res://Audios/Instrument/A5/Violin.wav"), 'note' : 'A5'},
					{'instrument': preload("res://Audios/Instrument/A3/ViolinCello.wav"), 'note' : 'A3'}]

#Record and play songs
var _is_recording = false
var _is_playing = false
var _dict
var _song = {"init_note" : 0, "init_pitch" : 4, "instrument" : _index_instrument, "notes" : []}

var _chronometer 
var _play_timer = null
var _initial_wait = null

var is_checking_piano = false

signal song_stopped()
signal song_playing()
signal record_stopped()
signal set_piano(note, pitch, instrument)

# Called when the node enters the scene tree for the first time.
func _ready():
	var init_note = _init_note_idx
	var init_pitch = _init_pitch
	_white_keys = $WhiteKeys
	_black_keys = $BlackKeys
	create_piano(init_note,init_pitch)
	_chronometer = preload("res://Classes/Chronometer.gd").new()
	add_child(_chronometer)
	_play_timer = $PlayTimer
	_initial_wait = $InitialTimer

func create_piano(init_note,init_pitch, index_instrument = 5, visible = isVisible):
	delete_piano()
	_init_note_idx = init_note
	_init_pitch = init_pitch
	_index_instrument = index_instrument
	var contador = 0
	_keys = []
	var idx_keys = 0
	while contador < NUM_WHITE_KEYS:
		if _init_note_idx >= len(_notes):
			_init_note_idx = 0
			_init_pitch+=1
		var new_key = _white_key.instantiate()
		new_key.name = _white_words[contador]
		var new_note = _note.new(_notes[_init_note_idx]+str(_init_pitch), _instruments[index_instrument]['instrument'], _instruments[index_instrument]['note'])
		add_child(new_note)
		_white_keys.add_child(new_key)
		new_key.setup(new_note, _white_words[contador], idx_keys, visible)
		_keys+=[new_key]
		contador+=1
		idx_keys+=1
		_init_note_idx+=1
	contador = 0
	_init_note_idx = init_note
	_init_pitch = init_pitch
	while contador < NUM_BLACK_KEYS:
		if _init_note_idx >= len(_notes):
			_init_note_idx = 0
			_init_pitch+=1
		if _notes[_init_note_idx] != "E" and _notes[_init_note_idx] != "B":
			var new_key = _black_key.instantiate()
			new_key.name = _black_words[contador]
			var new_note = _note.new(_notes[_init_note_idx]+str(_init_pitch)+str("#"), _instruments[index_instrument]['instrument'], _instruments[index_instrument]['note'])
			add_child(new_note)
			_black_keys.add_child(new_key)
			new_key.setup(new_note, _black_words[contador], idx_keys, visible)
			_keys+=[new_key]
			idx_keys+=1
		else:
			var new_empty = _empty.instantiate()
			_black_keys.add_child(new_empty)
		contador+=1
		_init_note_idx+=1
	_init_note_idx = init_note
	_init_pitch = init_pitch
	if is_checking_piano:
		for note in _keys:
			note.enable_input(false)


func delete_piano():
	restored_default_variables()
	if _white_keys.get_child_count() != 0:
		var nodes = _white_keys.get_children()
		for nodo in nodes:
			_white_keys.remove_child(nodo)
			nodo.queue_free()
	if _black_keys.get_child_count() != 0:
		var nodes = _black_keys.get_children()
		for nodo in nodes:
			_black_keys.remove_child(nodo)
			nodo.queue_free()


func restored_default_variables():
	_is_recording = false
	_is_playing = false
	_dict = {}


#Iniciar una grabación
func record_song():
	if not _is_playing:
		stop_all_notes()
		_song = {"init_note" : _init_note_idx, "init_pitch" : _init_pitch, "instrument" : _index_instrument, "notes" : []}
		_dict = {}
		_is_recording  = true
		_chronometer.start()

#Detener una grabación
func stop_record_song():
	if not _is_playing:
		stop_all_notes()
		_is_recording  = false
		_chronometer.stop()
		emit_signal("record_stopped")


#Una tecla del piano fue presionada
func key_pressed(index):
	if _is_recording:
		var new_note = [index, 0.01, _chronometer.get_time()]
		_song["notes"] += [new_note]
		_dict[index] = new_note

#Una tecla de piano dejo de ser presionada
func key_released(index, time):
	if _is_recording:
		if _dict.has(index):
			_dict[index][1] = time


func play_and_set_song():
	emit_signal("set_piano", _song["init_note"], _song["init_pitch"], _song["instrument"])
	play_song()


func enable_input(value):
	if not is_checking_piano:
		for note in _keys:
			note.enable_input(value)


func play_song():
	_initial_wait.stop()
	var max_time = 0
	for arr in _song["notes"]:
		if arr[1]+arr[2] > max_time:
			max_time = arr[1]+arr[2]  
	enable_input(false)
	emit_signal("song_playing")
	stop_song_after_x_time(max_time)
	if not _is_recording:
		_is_playing = true
		var last_time = 0
		var time = 0
		for arr in _song["notes"]:
			time = arr[2] - last_time if arr[2] > last_time else 0
			last_time = arr[2]
			if time > _chronometer.get_delta():
				_initial_wait.set_wait_time(time)
				_initial_wait.start()
				await _initial_wait.timeout
			if not _is_playing:
				break
			_keys[arr[0]].activate_x_time(arr[1])


func set_checking_piano(value):
	is_checking_piano = value
	for note in _keys:
		note.enable_input(not value)


func stop_song_after_x_time(max_time):
	if max_time>0:
		_play_timer.set_wait_time(max_time)
		_play_timer.start()
	else:
		_play_timer.set_wait_time(0.2)
		_play_timer.start()
	

func manually_stop_song():
	_play_timer.stop()
	_on_play_timer_timeout()


func stop_all_notes():
	for note in _keys:
		note.manually_stop()

func get_song():
	return _song


func set_song(new_song):
	_song = new_song
	emit_signal("set_piano", _song["init_note"], _song["init_pitch"], _song["instrument"])


func _physics_process(delta):
	if _is_recording:
		if _chronometer.get_time() > 300:
			stop_record_song()


func song_is_playing():
	return _is_playing


func _on_play_timer_timeout():
	if not _is_recording and _is_playing:
		stop_all_notes()
		emit_signal("song_stopped")
		enable_input(true)
		_is_playing = false
