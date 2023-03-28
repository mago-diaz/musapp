class_name Notes
extends Node

#const _notes = {"C" : -9, "D" : -7, "E" : -5, "F" : -4, "G" : -2, "A" : 0, "B" : 2}
const _notes = {"C" : 0, "D" : 2, "E" : 4, "F" : 5, "G" : 7, "A" : 9, "B" : 11}
const _accidentals = {"-" : 0, "#" : 1, "b" : -1, "x" : 2, "f" : -2}
var _audio
var _timer
var _name
var _letter 

func _init(note, instrument = preload("res://Audios/Instrument/A4/Piano.wav"), initial_note = 'A4'):
	#Calculate pitch_scale with the name of the note
	assert(note is String)
	assert(initial_note is String)
	_name = note
	_letter = note[0]
	var accidental = note[2] if note.length() > 2 else "-"  
	var exponent = ((_notes[note[0]] + note[1].to_int() * 12 + _accidentals[accidental]) - ( _notes[initial_note[0]] + initial_note[1].to_int() * 12 )) / 12.0 
	_audio = AudioStreamPlayer.new()
	_audio.stream = instrument
	_audio.pitch_scale = pow(2, exponent)
	_audio.set_volume_db(12.0)
	add_child(_audio)
	#Create and set the reverb of the sound
	_timer = Timer.new()
	_timer.set_wait_time(0.2)
	_timer.timeout.connect(self.on_timer_timeout)
	add_child(_timer)


#Reproducir el audio 
func play():
	_timer.stop()
	_audio.play()

#Detener el audio con delay, utilizando un timer
func stop():
	_timer.start()

#Detencion del timer de delay
func on_timer_timeout():
	_timer.stop()
	_audio.stop()

#Detener el audio de manera forzoza
func force_stop():
	_audio.stop()

#Reproducir un audio, por una cantidad de tiempo time, con un delay final de delta
func play_x_time(time, delta = 0):
	_audio.play()
	await get_tree().create_timer(time).timeout
	if delta and _audio.is_playing():
		wait_delta(delta)
	else:
		_audio.stop()

#genera el delay del delta
func wait_delta(delta):
	await get_tree().create_timer(delta).timeout
	_audio.stop()

#entrega el nombre de la nota
func get_name():
	return _name

#entrega el nombre anglosajon de la letra
func get_letter():
	return _letter
