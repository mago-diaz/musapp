extends Control

const seconds = 60.0
const time_divident = 4.0

var mutex
var time_f = 4
var time_s = 4
var time_max = (time_divident/time_s)*time_f
var tempo = 60
var tempo_normalized = 1.0
var clef = 0
var signature = 0
var GSignatureIds = ["F", "C", "G", "D", "A", "E", "B"]

var accidentals = {"C" : 2, "D" : 2, "E" : 2, "F" : 2, "G" : 2, "A" : 2, "B" : 2}

var note = preload("res://Classes/Notes.gd")
var measure = preload("res://Scenes/MusicSheet/Measure.tscn")
var premeasure = preload("res://Scenes/MusicSheet/PreMeasure.tscn")

var viewPremeasure = null

var measures = []
var premeasures = []
var current_measure = null
var is_measure_finished = true

var current_song = []
var notes = []
var notes_letter = []

var vertical_scroll = 170
var current_cursor = 10

var figure_time = {"SB" : 4, "MN" : 2, "CR" : 1, "QV" : 0.5, "SQ" : 0.25}
var accidental_time = {"f" : -2, "b" : -1, "n" : 0, "#" : 1, "x" : 2}

var is_activate_keyboard = true
var is_playing_song = false

var new_time_f = null
var new_time_s = null
var new_tempo = null
var new_clef = null
var new_signature = null


signal note_timeout()


func _ready():
	create_pre_measure()
	changes_clef_notes("E", 6)
	var hscroll = $VBoxContainer/Sheet/ScrollContainer.get_v_scroll_bar()
	hscroll.changed.connect(self.change_size)

	viewPremeasure = $SettingContainer/VBoxContainer/CenterContainer2/PreMeasure

	mutex = Mutex.new()

	create_sheet()
	for i in accidentals.keys():
		accidentals[i] = 2
	

func create_sheet():
	new_clef = clef
	new_tempo = tempo
	new_time_f = time_f
	new_time_s = time_s
	new_signature = signature
	time_max = (time_divident/time_s)*time_f
	if len(measures) == 0:
		create_measure()
	current_measure.show_cursor()


func get_current_figure_time(key):
	return figure_time[key] * tempo_normalized


func create_pre_measure():
	var my_pre_measure = premeasure.instantiate()
	$VBoxContainer/Sheet/ScrollContainer/HFlowContainer.add_child(my_pre_measure)
	my_pre_measure.clef_setup(clef)
	my_pre_measure.tempo_setup(tempo)
	my_pre_measure.signature_setup(signature)
	my_pre_measure.time_setup(time_f, time_s)
	premeasures += [my_pre_measure]


func delete_pre_measure():
	var last_premeasure = premeasures.pop_back()
	$VBoxContainer/Sheet/ScrollContainer/HFlowContainer.remove_child(last_premeasure)
	last_premeasure.queue_free()


func create_measure():
	if len(measures) % 3 == 0 and len(measures)>0:
		create_pre_measure()
	var my_measure = measure.instantiate()
	$VBoxContainer/Sheet/ScrollContainer/HFlowContainer.add_child(my_measure)
	my_measure.setup(time_f, time_s, tempo_normalized, accidentals)
	measures+= [my_measure]
	current_measure = my_measure
	current_measure.set_cursor(current_cursor)
	if is_activate_keyboard:
		current_measure.show_cursor()

func delete_first_measure():
	if len(measures) == 1:
		measures.erase(current_measure)
		$VBoxContainer/Sheet/ScrollContainer/HFlowContainer.remove_child(current_measure)
		current_measure.queue_free()
		current_measure = null

func delete_measure():
	if len(measures) > 1:
		measures.erase(current_measure)
		$VBoxContainer/Sheet/ScrollContainer/HFlowContainer.remove_child(current_measure)
		current_measure.queue_free()
		current_measure = measures.back()
	if len(measures) % 3 == 0:
		delete_pre_measure()

func save_note(figure, accidental, silence = false, sound = true):
	if silence:
		if current_measure.insert_silence(figure_time[figure], figure):
			current_song += [{"figure" : figure, "is_silence" : silence}]
	else:
		if current_measure.insert_note(figure_time[figure], figure, accidental):
			if sound:
				notes[current_cursor][current_measure.get_last_accidental_time(notes_letter[current_cursor])].play_x_time(0.5)
			current_song += [{ "cursor" : current_cursor, "figure" : figure, "accidental" : accidental, "note_accidental" : current_measure.get_last_accidental_time(notes_letter[current_cursor]), "is_silence" : silence}]
	if current_measure.next_measure():
		create_measure()


func delete_note():
	if current_measure:
		var has_notes = current_measure.delete_note()
		if not has_notes and len(measures) > 1:
			delete_measure()
			current_measure.set_cursor(current_cursor)
			delete_note()
		elif has_notes:
			current_song.pop_back()


func stop_song():
	is_playing_song = false
	for note_group in notes:
		for inidividual_note in note_group:
			inidividual_note.force_stop()
	current_measure.stop_song()
	var button = $VBoxContainer/Manager/HBoxContainer/Play
	button.set_pressed(false)
	button.text = "Reproducir"
	
func play_song():
	if not is_playing_song:
		var current_scroll = 0
		$VBoxContainer/Sheet/ScrollContainer.set_v_scroll(current_scroll)
		var i = 0
		var wait_time
		var current_time = 0
		is_playing_song = true
		measures[i].play_song()
		for current_note in current_song:
			if not current_note["is_silence"]:
				notes[current_note["cursor"]][current_note["note_accidental"]].play_x_time(get_current_figure_time(current_note["figure"]))
			wait_time = get_current_figure_time(current_note["figure"])
			current_time += get_current_figure_time(current_note["figure"])
			if wait_time>0.0:
				await wait_x_time(wait_time)
			if not is_playing_song:
				measures[i].stop_song()
				break
			if abs(current_time - (time_max * tempo_normalized)) < 0.001:
				current_time = 0
				measures[i].stop_song()
				i+=1
				if i<len(measures):
					measures[i].play_song()
					if i % 3 == 0:
						current_scroll += vertical_scroll
						$VBoxContainer/Sheet/ScrollContainer.set_v_scroll(current_scroll)
		stop_song()

func wait_x_time(time):
	var i = 0
	var wait_time
	if time <= 0.5:
		wait_time = time
	elif time > 0.5 and time < 2.0:
		wait_time = time*1.0/4
	else:
		wait_time = time*1.0/4
	while i < time and is_playing_song:
		await get_tree().create_timer(wait_time).timeout
		i+=wait_time


func change_size():
	var hscroll = $VBoxContainer/Sheet/ScrollContainer.get_v_scroll_bar()
	var max_value = hscroll.get_max()
	$VBoxContainer/Sheet/ScrollContainer.set_v_scroll(max_value)


func _input(event):
	if is_activate_keyboard and not is_playing_song:
		if event.is_action_pressed("UP"):
			current_cursor = current_measure.move_up_cursor()
		elif event.is_action_pressed("DOWN"):
			current_cursor = current_measure.move_down_cursor()
		elif event.is_action_pressed("A#"):
			save_note("SB", "#")
		elif event.is_action_pressed("S#"):
			save_note("MN", "#")
		elif event.is_action_pressed("D#"):
			save_note("CR", "#")
		elif event.is_action_pressed("F#"):
			save_note("QV", "#")
		elif event.is_action_pressed("G#"):
			save_note("SQ", "#")
		elif event.is_action_pressed("Ab"):
			save_note("SB", "b")
		elif event.is_action_pressed("Sb"):
			save_note("MN", "b")
		elif event.is_action_pressed("Db"):
			save_note("CR", "b")
		elif event.is_action_pressed("Fb"):
			save_note("QV", "b")
		elif event.is_action_pressed("Gb"):
			save_note("SQ", "b")
		elif event.is_action_pressed("Ac"):
			save_note("SB", "c")
		elif event.is_action_pressed("Sc"):
			save_note("MN", "c")
		elif event.is_action_pressed("Dc"):
			save_note("CR", "c")
		elif event.is_action_pressed("Fc"):
			save_note("QV", "c")
		elif event.is_action_pressed("Gc"):
			save_note("SQ", "c")
		elif event.is_action_pressed("A"):
			save_note("SB", "n")
		elif event.is_action_pressed("S"):
			save_note("MN", "n")
		elif event.is_action_pressed("D"):
			save_note("CR", "n")
		elif event.is_action_pressed("F"):
			save_note("QV", "n")
		elif event.is_action_pressed("G"):
			save_note("SQ", "n")
		elif event.is_action_pressed("Q"):
			save_note("SB","n", true)
		elif event.is_action_pressed("W"):
			save_note("MN","n", true)
		elif event.is_action_pressed("E"):
			save_note("CR","n", true)
		elif event.is_action_pressed("R"):
			save_note("QV","n", true)
		elif event.is_action_pressed("T"):
			save_note("SQ","n", true)
		elif event.is_action_pressed("ENTER"):
			var button = $VBoxContainer/Manager/HBoxContainer/Play
			button.set_pressed(true)
			button.text = "Detener"
		elif event.is_action_pressed("DELETE"):
			delete_note()
	elif is_activate_keyboard:
		if event.is_action_pressed("ENTER"):
			var button = $VBoxContainer/Manager/HBoxContainer/Play
			button.set_pressed(false)
			button.text = "Reproducir"


func changes_clef_notes(letter, pitch):
	if len(notes)>0:
		for current_notes in notes:
			for current_note in current_notes:
				remove_child(current_note)
				current_note.queue_free()
		notes = []
		notes_letter = []
	for i in range(21):
		if letter == "B":
			pitch-=1
		var new_note_2flat = note.new(letter+str(pitch)+str("f"))
		var new_note_flat = note.new(letter+str(pitch)+str("b"))
		var new_note = note.new(letter+str(pitch)) 
		var new_note_sharp = note.new(letter+str(pitch)+str("#"))
		var new_note_2sharp = note.new(letter+str(pitch)+str("x"))
		notes+=[[new_note_2flat, new_note_flat, new_note, new_note_sharp, new_note_2sharp]]
		add_child(new_note_2flat)
		add_child(new_note_flat)
		add_child(new_note)
		add_child(new_note_sharp)
		add_child(new_note_2sharp)
		notes_letter += [new_note.get_letter()]
		if letter != "A":
			letter = String.chr(letter.unicode_at(0) - 1)
		else:
			letter = "G"


func changes_accidentals(index):
	var sharp = true
	if index > len(GSignatureIds):
		index = index % 7 
		sharp = false
	for i in accidentals.keys():
		accidentals[i] = 2
	for i in range(index):
		var correct_id
		var correct_accidental
		if sharp:
			correct_id = i
			correct_accidental = 3
		else:
			correct_id = len(GSignatureIds) -1 - i
			correct_accidental = 1
		accidentals[GSignatureIds[correct_id]] = correct_accidental

func _on_key_option_item_selected(index):
	new_clef = index
	viewPremeasure.clef_setup(new_clef)
	viewPremeasure.signature_setup(new_signature)

func _on_signature_option_item_selected(index):
	new_signature = index
	viewPremeasure.signature_setup(new_signature)

func _on_time_f_option_item_selected(index):
	new_time_f = index + 1
	viewPremeasure.time_setup(new_time_f, new_time_s)

func _on_time_s_option_item_selected(index):
	new_time_s = pow(2, index)
	viewPremeasure.time_setup(new_time_f, new_time_s)

func _on_tempo_spin_value_changed(value):
	new_tempo = value
	viewPremeasure.tempo_setup(new_tempo)


func _on_save_settings_pressed():
	while len(measures) > 1:
		delete_measure()
	delete_first_measure()
	while len(premeasures) > 1:
		delete_pre_measure() 
	is_measure_finished = true
	current_song = []
	
	clef = new_clef
	premeasures[0].clef_setup(clef)
	if clef == 0:
		changes_clef_notes("E", 6)
	else:
		changes_clef_notes("G", 4)

	signature = new_signature
	changes_accidentals(signature)
	premeasures[0].signature_setup(signature)
	
	tempo = new_tempo
	tempo_normalized = (seconds * 1.0 )/(tempo * 1.0)
	premeasures[0].tempo_setup(tempo)
	
	time_f = new_time_f
	time_s = new_time_s
	premeasures[0].time_setup(time_f, time_s)
	create_sheet()
	$SettingContainer.set_visible(false)
	is_activate_keyboard = true
	current_measure.show_cursor()


func _on_settings_pressed():
	stop_song()
	is_activate_keyboard = false
	current_measure.hide_cursor()
	$SettingContainer.set_visible(true)
	viewPremeasure.clef_setup(new_clef)
	viewPremeasure.time_setup(new_time_f, new_time_s)
	viewPremeasure.signature_setup(new_signature)


func _on_cancel_pressed():
	is_activate_keyboard = true
	current_measure.show_cursor()
	$SettingContainer.set_visible(false)


func _on_play_toggled(button_pressed):
	var button = $VBoxContainer/Manager/HBoxContainer/Play
	if button_pressed:
		button.text = "Detener"
		await get_tree().create_timer(0.5).timeout
		play_song()
	else:
		get_answer()
		button.text = "Reproducir"
		stop_song()


func get_answer():
	var song = {"clef" : clef, "signature" : signature, "tempo" : tempo, "time_f" : time_f, "time_s" : time_s, "current_song" : current_song}
	return song 


func load_answer(song):
	var KeyOption = $SettingContainer/VBoxContainer/KeyHbox/KeyOption
	var SignatureOption = $SettingContainer/VBoxContainer/SignatureHbox/SignatureOption
	var TimeFOption = $SettingContainer/VBoxContainer/MeasureHbox/TimeFOption
	var TimeSOption = $SettingContainer/VBoxContainer/MeasureHbox/TimeSOption
	var TempoSpin = $SettingContainer/VBoxContainer/TempoHbox/TempoSpin
	new_clef = song["clef"]
	KeyOption.select(clef)
	new_signature = song["signature"]
	SignatureOption.select(signature)
	new_time_f = song["time_f"]
	TimeFOption.select(time_f - 1)
	new_time_s = song["time_s"]
	TimeSOption.select(log(time_s)/log(2))
	new_tempo = song["tempo"]
	TempoSpin.get_line_edit().set_text(str(tempo))
	_on_save_settings_pressed()
	is_activate_keyboard = false
	for element in song["current_song"]:
		var accidental
		if not element["is_silence"]:
			current_cursor = current_measure.set_cursor(element['cursor'])
			accidental = element["accidental"]
		else:
			accidental = null
		save_note(element["figure"], accidental, element["is_silence"], false)
	$VBoxContainer/Manager/HBoxContainer/Settings.set_disabled(true)
	$VBoxContainer/Instructions.set_visible(false)


func disable_input(value):
	is_activate_keyboard = not value
