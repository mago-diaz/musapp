extends Node


const size_x = 400
const size_y = 170
const margin = 0
const time_divident = 4.0
const silence_row = 10

var figure_space
var current_distance
var measure_time

var time_s = 4
var time_f = 4
var time_max : float
var tempo_n

var cursor = preload("res://Scenes/MusicSheet/MSPointer.tscn")
var vline = preload("res://Scenes/MusicSheet/MeasureLine.tscn")

var my_cursor
var my_cursor_row = 10
var rows
var sheet_accidentals
var is_playing = false
var save_notes = []
var accidentals = []
const accidental_time = {"f" : -2, "b" : -1, "n" : 0, "c" : 0, "#" : 1, "x" : 2}

func _ready():
	my_cursor = cursor.instantiate()
	$HBoxContainer/VBoxContainer.set_custom_minimum_size(Vector2(size_x, size_y))
	time_max = (time_divident/time_s)*time_f
	figure_space = (size_x - (margin * 2))/time_max
	current_distance = margin
	rows = $HBoxContainer/VBoxContainer.get_children()
	accidentals.resize(len(rows))
	accidentals.fill(["n"])
	rows[my_cursor_row].add_child(my_cursor)
	my_cursor.set_position(Vector2(current_distance,-10))
	measure_time = 0


func setup(time_first = 4, time_second = 4, current_tempo = 1.0, accidentals = {"C" : 2, "D" : 2, "E" : 2, "F" : 2, "G" : 2, "A" : 2, "B" : 2}):
	time_max = (time_divident/time_second)*time_first
	figure_space = ( size_x - margin )/ time_max
	tempo_n = current_tempo
	current_distance = margin
	rows = $HBoxContainer/VBoxContainer.get_children()
	sheet_accidentals = accidentals


func insert_note(time_note, pre_note, accidental):
	if time_note + measure_time <= time_max:
		measure_time += time_note
		var stem = "T" if my_cursor_row < 10 else "B"
		var path = String("res://Scenes/MusicSheet/Figures/" + pre_note + "Note_" + stem + ".tscn")
		var figure = load(path).instantiate()
		var change_accidental = false
		if accidental != accidentals[my_cursor_row].back() and accidental != "n":
			accidentals[my_cursor_row] += [accidental]
			change_accidental = true
			figure.setup(accidental)
		var add_current_space = (figure_space * time_note)
		rows[my_cursor_row].add_child(figure)
		save_notes+= [{"cursor" : my_cursor_row, "figure" : figure, "figure_time" : time_note, "distance" : current_distance, "change_accidentals" : change_accidental}]
		figure.set_position(Vector2(current_distance + 10, 0))
		current_distance += add_current_space 
		my_cursor.set_position(Vector2(current_distance, -10))
		if next_measure():
			if my_cursor:
				remove_cursor()
		return true
	else:
		return false

func get_last_accidental_time(note):
	var last_note = save_notes.back()
	var accidental = 2
	if accidentals[last_note["cursor"]].back() != "c":
		accidental = sheet_accidentals[note]
	return accidental_time[accidentals[last_note["cursor"]].back()] + accidental


func next_measure():
	return measure_time == time_max

func insert_silence(time_silence, pre_silence):
	if time_silence + measure_time <= time_max:
		measure_time += time_silence
		var path = String("res://Scenes/MusicSheet/Figures/" + pre_silence + "Silence.tscn")
		var figure = load(path).instantiate()
		var add_current_space = (figure_space * time_silence)
		rows[silence_row].add_child(figure)
		save_notes+= [{"cursor" : silence_row, "figure" : figure, "figure_time" : time_silence, "distance" : current_distance, "change_accidentals" : false}]
		figure.set_position(Vector2(current_distance + 10, 0))
		current_distance += add_current_space 
		my_cursor.set_position(Vector2(current_distance, -10))
		if next_measure():
			if my_cursor:
				remove_cursor()
		return true
	else:
		return false

func delete_note():
	if len(save_notes) > 0:
		var last_note = save_notes.pop_back()
		measure_time -= last_note["figure_time"]
		rows[last_note["cursor"]].remove_child(last_note["figure"])
		current_distance = last_note["distance"]
		if last_note["change_accidentals"]:
			accidentals[last_note["cursor"]].pop_back()
		my_cursor.set_position(Vector2(current_distance, -10))
		return true
	else:
		return false


func add_accidental(row, accidental):
	if row < len(accidentals):
		accidentals[row] = accidental


func show_cursor():
	my_cursor.show_cursor()


func hide_cursor():
	my_cursor.hide_cursor()


func set_cursor(new_cursor):
	if rows[my_cursor_row].is_ancestor_of(my_cursor):
		rows[my_cursor_row].remove_child(my_cursor)
	my_cursor_row = new_cursor
	rows[my_cursor_row].add_child(my_cursor)
	return my_cursor_row


func move_up_cursor():
	if my_cursor_row>0:
		rows[my_cursor_row].remove_child(my_cursor)
		my_cursor_row-=1
		rows[my_cursor_row].add_child(my_cursor)
	return my_cursor_row


func move_down_cursor():
	if my_cursor_row<len(rows)-1: 
		rows[my_cursor_row].remove_child(my_cursor)
		my_cursor_row+=1
		rows[my_cursor_row].add_child(my_cursor)
	return my_cursor_row


func get_cursor_row():
	return my_cursor_row


func remove_cursor():
	rows[my_cursor_row].remove_child(my_cursor)
	


func play_song():
	$PlayLine.set_visible(true)
	$PlayLine.set_position(Vector2(0,0))
	is_playing = true


func stop_song():
	$PlayLine.set_visible(false)
	$PlayLine.set_position(Vector2(0,0))
	is_playing = false


func _physics_process(delta):
	if is_playing:
		var position = $PlayLine.get_position()
		if position[0] < size_x:
			#position[0]+= ((size_x - margin - 10)/ (time_max * 1.0 / delta)) * (1.0/tempo_n)
			position[0]+= ((size_x*1.0)/(tempo_n*time_max*1.0/delta))
			$PlayLine.set_position(position)
		else:
			stop_song()
