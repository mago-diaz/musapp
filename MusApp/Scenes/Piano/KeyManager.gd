extends Control

var _key
var _word
var _name
var _start_color
var _note
var _index
var _chronometer 
var notes = {"C" : "Do", "D" : "Re", "E" : "Mi", "F" : "Fa", "G" : "Sol", "A" : "La", "B" : "Si" }
var _enable_input = true
signal key_activated(index)
signal key_deactivated(index, time)


func _ready():
	_key = $Key
	_word = $Word
	_name = $Note
	_start_color = _key.color

	_chronometer = preload("res://Classes/Chronometer.gd").new()
	add_child(_chronometer)
	
	var parent = get_parent()
	if parent != null:
		var piano = parent.get_parent()
		if piano != null:
			self.key_activated.connect(piano.key_pressed)
			self.key_deactivated.connect(piano.key_released)

func setup(note, word, index, isVisible):
	_word.set_text(word)
	_note = note
	var _note_name = _note.get_name()
	_name.set_text(notes[_note_name[0]] + _note_name.substr(1))
	_name.set_visible(isVisible)
	_index = index

func activate():
	if _note:
		_note.play()
		_chronometer.start()
		emit_signal("key_activated",_index)
	_key.color = Color.POWDER_BLUE
	
func deactivate():
	if _note:
		_note.stop()
		emit_signal("key_deactivated",_index, _chronometer.stop())
	_key.color = _start_color

func activate_x_time(time):
	_key.color = Color.POWDER_BLUE
	await _note.play_x_time(time, 0.2)
	_key.color = _start_color
	
func manually_stop():
	_note.stop()
	_key.color = _start_color
	
func enable_input(value):
	_enable_input = value
	
func _input(event):
	if _word.text != "?" and _enable_input:
		if event.is_action_pressed(_word.get_text()) and _note:
			activate()
		if event.is_action_released(_word.get_text()) and _note:
			deactivate()

