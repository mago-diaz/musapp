extends Control

const base_url = "http://127.0.0.1:8000/"
var http_request_level
var LevelEditOption
var CreateGradeInstantiate
var GradeList
var CurrentlyLetter
var IsCreated
var Token
var Level
var NewLevel = {}

var DeleteLetter = []
var CreateLetter = []
var LevelName
var LevelType

var NameWarning
var CreateWarning

var EditLevelContainer

var SendLevelToServer
var SendLevelToServerLabel

var LevelSaved

func _ready():
	http_request_level = HTTPRequest.new()
	add_child(http_request_level)
	http_request_level.connect("request_completed", self._http_request_level_completed)
	
	LevelEditOption = $CenterContainer/VBoxContainer/NameBox/LevelOption
	GradeList = $CenterContainer/VBoxContainer/ColorRect/ScrollContainer/GradeList
	NameWarning = $CenterContainer/VBoxContainer/NameWarning
	CreateWarning = $CenterContainer/VBoxContainer/CreateWarning
	
	EditLevelContainer = $CenterContainer

	SendLevelToServer = $SendLevelToServer
	SendLevelToServerLabel = $SendLevelToServer/CenterContainer/Saving/Label

	LevelSaved = $LevelSaved


func setup(level, is_created, token, levels_created = []):
	IsCreated = is_created
	Token = token
	CurrentlyLetter = 'A'
	NewLevel = {'level' : {'number' : '', 'type' : ''}, 'grades' : [], 'deleted_grades' : []}
	Level = level
	if IsCreated:
		LevelName = ''
		LevelType = ''
		if levels_created != []:
			for element in LevelEditOption.get_item_count():
				if LevelEditOption.get_item_text(element) in levels_created:
					LevelEditOption.set_item_disabled(element, true)
		LevelEditOption.set_disabled(false)
		save_new_grade(true)
	else:
		var LevelName = Level['number'] + ' ' + Level['type']
		for element in LevelEditOption.get_item_count():
			if LevelName == LevelEditOption.get_item_text(element):
				LevelEditOption.select(element)
				_on_type_option_item_selected(element)
		LevelEditOption.set_disabled(true)
		var GradeNames = []
		for grade in Level['grades']:
			GradeNames += [grade['letter']]
		var alphabet_i = "A"
		while alphabet_i <= "Z":
			if alphabet_i in GradeNames:
				CurrentlyLetter = alphabet_i
				save_new_grade(false)
			alphabet_i = String.chr(alphabet_i.unicode_at(0) + 1)


func open():
	set_visible(true)
	EditLevelContainer.set_visible(true)
	SendLevelToServer.set_visible(false)
	LevelSaved.set_visible(false)


func save_new_grade(is_new):
	if CurrentlyLetter <= 'Z':
		CreateGradeInstantiate = preload("res://Home/SchoolManager/EditSceens/CreateGradeOption.tscn").instantiate()
		GradeList.add_child(CreateGradeInstantiate)
		CreateGradeInstantiate.setup(CurrentlyLetter, is_new)
		CreateLetter += [CreateGradeInstantiate]
		CurrentlyLetter = String.chr(CurrentlyLetter.unicode_at(0) + 1)
	else:
		CreateWarning.text = 'Máxima cantidad de letras disponibles'


func _on_exit_create_level_pressed():
	DeleteLetter = []
	CreateLetter = []
	CurrentlyLetter = 'A'
	NewLevel = {'level' : {'number' : '', 'type' : ''}, 'grades' : [], 'deleted_grades' : []}
	LevelEditOption.select(0)
	for grade in GradeList.get_children():
		GradeList.remove_child(grade)
		grade.queue_free()
	NameWarning.text = ''
	set_visible(false)


func _on_save_create_level_pressed():
	var HasErrors = false
	print(NewLevel['level']['number'])
	if NewLevel['level']['number'] == '' or NewLevel['level']['type'] == '':
		HasErrors = true
		NameWarning.text = 'Debes seleccionar el nombre del curso a crear'
	
	if not HasErrors:
		for letter_grade in CreateLetter:
			if letter_grade.get_is_new():
				if Level != {} and Level.has('id'):
					NewLevel['grades'] += [{'letter' : letter_grade.get_letter(), 'id_level' : Level['id']}]
				else:
					NewLevel['grades'] += [{'letter' : letter_grade.get_letter(), 'id_level' : null}]
		
		for letter_grade in DeleteLetter:
			if not letter_grade.get_is_new():
				NewLevel['deleted_grades'] += [{'letter' : letter_grade.get_letter(), 'id_level' : Level['id']}]
		
		var token_header = "Authorization: Token " + Token
		var headers = ["Content-Type: application/json", "Accept: application/json", token_header]
		var body = JSON.stringify(NewLevel)
		if IsCreated:
			var error = http_request_level.request(base_url + "api/levels-and-grades/", headers, false, HTTPClient.METHOD_POST, body)
			if error != OK:
				push_error("An error ocurred in the HTTP request.")
			SendLevelToServerLabel.text = 'Creando Cursos'
		else: 
			var error = http_request_level.request(base_url + "api/levels-and-grades/" + str(Level['id']) + "/" , headers, false, HTTPClient.METHOD_PATCH, body)
			if error != OK:
				push_error("An error ocurred in the HTTP request.")
			SendLevelToServerLabel.text = 'Editando Cursos'
		EditLevelContainer.set_visible(false)
		SendLevelToServer.set_visible(true)


func _http_request_level_completed(result, response_code, headers, body):
	if result == http_request_level.RESULT_SUCCESS:
		if response_code == 200:
			var json = JSON.new()
			json.parse(body.get_string_from_utf8())
			var response = json.get_data()
			print(response)
			SendLevelToServer.set_visible(false)
			LevelSaved.set_visible(true)


func _on_type_option_item_selected(index):
	var LevelName = LevelEditOption.get_item_text(index)
	if LevelName != LevelEditOption.get_item_text(0):
		NewLevel['level']['number'] = LevelName.get_slice(" ", 0)
		NewLevel['level']['type'] =  LevelName.get_slice(" ", 1)
		NameWarning.text = ''


func _on_create_letter_pressed():
	if not DeleteLetter.is_empty():
		var ReOpenOption = DeleteLetter.pop_back()
		ReOpenOption.create_again()
		CreateLetter += [ReOpenOption] 
	else:
		save_new_grade(true)


func _on_delete_letter_pressed():
	if len(CreateLetter) > 1:
		var DeleteOption = CreateLetter.pop_back()
		DeleteOption.delete()
		DeleteLetter += [DeleteOption]


func _on_go_to_pressed():
	DeleteLetter = []
	CreateLetter = []
	CurrentlyLetter = 'A'
	NewLevel = {'level' : {'number' : '', 'type' : ''}, 'grades' : [], 'deleted_grades' : []}
	LevelEditOption.select(0)
	for grade in GradeList.get_children():
		GradeList.remove_child(grade)
		grade.queue_free()
	NameWarning.text = ''
	set_visible(false)
	var parent = get_parent()
	if parent:
		parent.get_school_admin_profile()
