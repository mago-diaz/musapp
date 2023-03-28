extends Control

const base_url = "http://127.0.0.1:8000/"
var Token
var http_profile_request
var http_logout_request

var LoginInstantiate

var SchoolAdmin = {}
var SchoolManagerLabel

var Teachers 
var EditTeacherInstantiate
var EditTeacherList
var EditTeacherScreen

 
var EditStudentInstantiate
var EditStudentList
var EditStudentScreen


var EditLevelInstantiate
var EditLevelList
var EditLevelScreen 

var LevelOptions = {}
var GradesInLevels = {}
var LevelNamesCreated = [] 

var LevelsOptionsButtonSubjects
var GradesOptionsButtonSubjects
var LevelsOptionsButtonStudents
var GradesOptionsButtonStudents


var EditSubjectInstantiate
var EditSubjectList
var EditSubjectScreen

var DeleteUser
var DeleteLevel
var DeleteSubject

var SearchStudent
var SearchSubject

var CurrentLevel = null
var CurrentGrade = null

var LevelNames = ["PRIMERO BASICO",
					"SEGUNDO BASICO",
					"TERCERO BASICO",
					"CUARTO BASICO",
					"QUINTO BASICO",
					"SEXTO BASICO",
					"SEPTIMO BASICO",
					"OCTAVO BASICO",
					"PRIMERO MEDIO",
					"SEGUNDO MEDIO",
					"TERCERO MEDIO",
					"CUARTO MEDIO"]

func _ready():
	LoginInstantiate = load("res://Login/Login.tscn").instantiate()
	
	EditTeacherList = $VBoxContainer/TabContainer/Profesores/Teachers/VBoxContainer/ColorRect/ScrollContainer/TeacherList
	EditTeacherScreen = $EditTeacherScreen
	
	
	EditStudentList = $VBoxContainer/TabContainer/Alumnos/Students/VBoxContainer/ColorRect/ScrollContainer/StudentList
	EditStudentScreen = $EditStudentScreen
	
	EditLevelList = $VBoxContainer/TabContainer/Cursos/Level/VBoxContainer/ColorRect/ScrollContainer/LevelList
	EditLevelScreen = $EditLevelScreen
	
	LevelsOptionsButtonSubjects = $VBoxContainer/TabContainer/Asignaturas/Subjects/VBoxContainer/LevelAndGrade/HBoxContainer/LevelOptionsSubjects
	GradesOptionsButtonSubjects = $VBoxContainer/TabContainer/Asignaturas/Subjects/VBoxContainer/LevelAndGrade/HBoxContainer/GradeOptionsSubjects
	LevelsOptionsButtonStudents = $VBoxContainer/TabContainer/Alumnos/Students/VBoxContainer/LevelAndGrade/HBoxContainer/LevelOptionsStudents
	GradesOptionsButtonStudents = $VBoxContainer/TabContainer/Alumnos/Students/VBoxContainer/LevelAndGrade/HBoxContainer/GradeOptionsStudents
	
	SearchStudent = $VBoxContainer/TabContainer/Alumnos/Students/VBoxContainer/CenterContainer/HBoxContainer/SearchStudents
	SearchSubject = $VBoxContainer/TabContainer/Asignaturas/Subjects/VBoxContainer/CenterContainer/HBoxContainer/SearchSubjects
	
	EditSubjectList = $VBoxContainer/TabContainer/Asignaturas/Subjects/VBoxContainer/ColorRect/ScrollContainer/SubjectList
	EditSubjectScreen = $EditSubjectScreen
	
	SchoolManagerLabel = $VBoxContainer/HBoxContainer/HBoxContainer/SchoolManagerLabel
	
	DeleteUser = $DeleteUser
	DeleteLevel = $DeleteLevel
	DeleteSubject = $DeleteSubject
	
	http_profile_request = HTTPRequest.new()
	add_child(http_profile_request)
	http_profile_request.connect("request_completed", self._http_request_profile_completed)
	get_school_admin_profile()


func setup(token):
	Token = token


func get_school_admin_profile():
	var token_header = "Authorization: Token " + Token
	var headers = ["Content-Type: application/json", "Accept: application/json", token_header]
	http_profile_request.set_timeout(10.0)
	var error = http_profile_request.request(base_url + "api/school-manager-profile/", headers, false, HTTPClient.METHOD_GET )


func _http_request_profile_completed(result, response_code, headers, body):
	if result == http_profile_request.RESULT_SUCCESS:
		var json = JSON.new()
		json.parse(body.get_string_from_utf8())
		var response= json.get_data()
		clear_all()
		setup_school_admin(response['school_admin'])
		update_teachers(response['teachers'])
		update_levels(response['levels'], response['grades'], response['subjects'], response['students'])
	else:
		$NoInternetConnection.set_visible(true)


func setup_school_admin(school_admin):
	SchoolAdmin['FullName'] = school_admin['first_name'] + ' ' + school_admin['middle_name'] + ' ' + school_admin['last_name'] + ' ' + school_admin['mothers_maiden_name']
	SchoolManagerLabel.text = 'Administrador: ' + SchoolAdmin['FullName']
	SchoolAdmin['Id'] = school_admin['id']


func update_teachers(teachers):
	Teachers = teachers
	for Teacher in Teachers:
		EditTeacherInstantiate = preload("res://Home/SchoolManager/EditTeacher.tscn").instantiate()
		EditTeacherList.add_child(EditTeacherInstantiate)
		EditTeacherInstantiate.setup(Teacher, EditTeacherScreen, DeleteUser, Token)


func update_levels(levels, grades, subjects, students):
	LevelOptions = {}
	GradesInLevels = {}
	LevelNamesCreated = []
	for level in levels:
		var level_name = level["number"] + " " + level["type"]
		LevelOptions[level_name] = {}
		GradesInLevels[level['id']] = {'level_name'  : level_name, 'grades' : []}
		
	for Grade in grades:
		var level_name = Grade['id_level']['number'] + " " + Grade['id_level']['type'] 
		LevelOptions[level_name][Grade['letter']] = {'id' : Grade['id'] ,'subjects' : [], 'students' : []}
		GradesInLevels[Grade['id_level']['id']]['grades'] += [Grade]
	
	for Level in levels:
		Level['grades'] = GradesInLevels[Level['id']]['grades'] 
		EditLevelInstantiate = preload("res://Home/SchoolManager/EditLevel.tscn").instantiate()
		EditLevelList.add_child(EditLevelInstantiate)
		EditLevelInstantiate.setup(Level, EditLevelScreen, DeleteLevel, Token)
		LevelNamesCreated += [Level['number'] + ' ' + Level['type']]
		
	update_students(students)
	update_subjects(subjects)
	create_level_options()


func clear_all():
	for element in EditTeacherList.get_children():
		EditTeacherList.remove_child(element)
		element.queue_free()
	
	for element in EditStudentList.get_children():
		EditStudentList.remove_child(element)
		element.queue_free()
	
	for element in EditLevelList.get_children():
		EditLevelList.remove_child(element)
		element.queue_free()
	
	for element in EditSubjectList.get_children():
		EditSubjectList.remove_child(element)
		element.queue_free()


func update_students(students):
	for Student in students:
		var level = Student['grade_id']['id_level']
		var level_name = level['number'] + " " + level['type']
		LevelOptions[level_name][Student['grade_id']['letter']]['students'] += [Student]


func update_subjects(subjects):
	for Subject in subjects:
		var level = Subject["grade_id"]["id_level"]
		var level_name = level["number"] + " " + level["type"]
		LevelOptions[level_name][Subject["grade_id"]["letter"]]['subjects'] += [Subject]


func clear_options(MyOptionButton):
	for i in range(MyOptionButton.get_item_count()-1, 0, -1 ):
		MyOptionButton.remove_item(i)


func create_level_options():
	clear_options(LevelsOptionsButtonSubjects)
	clear_options(GradesOptionsButtonSubjects)
	clear_options(LevelsOptionsButtonStudents)
	clear_options(GradesOptionsButtonStudents)
	for level in LevelNames:
		if LevelOptions.has(level):
			LevelsOptionsButtonSubjects.add_item(level)
			LevelsOptionsButtonStudents.add_item(level)
	if LevelsOptionsButtonSubjects.get_item_count() > 1 and LevelsOptionsButtonStudents.get_item_count() == LevelsOptionsButtonSubjects.get_item_count():
		_on_level_options_item_selected(1)


func create_grade_options():
	clear_options(GradesOptionsButtonSubjects)
	clear_options(GradesOptionsButtonStudents)
	if CurrentLevel and LevelOptions.has(CurrentLevel):
		var alphabet_i = "A"
		while alphabet_i <= "Z":
			if LevelOptions[CurrentLevel].has(alphabet_i):
				GradesOptionsButtonSubjects.add_item(alphabet_i)
				GradesOptionsButtonStudents.add_item(alphabet_i)
			alphabet_i = String.chr(alphabet_i.unicode_at(0) + 1)
	if GradesOptionsButtonSubjects.get_item_count() > 1 and GradesOptionsButtonSubjects.get_item_count() == GradesOptionsButtonStudents.get_item_count():
		_on_grade_options_item_selected(1)


func _on_level_options_item_selected(index):
	CurrentLevel = LevelsOptionsButtonSubjects.get_item_text(index)
	CurrentGrade = null
	create_grade_options()


func _on_grade_options_item_selected(index):
	CurrentGrade = GradesOptionsButtonSubjects.get_item_text(index)
	for element in EditSubjectList.get_children():
		EditSubjectList.remove_child(element)
		element.queue_free()
	
	for element in EditStudentList.get_children():
		EditStudentList.remove_child(element)
		element.queue_free()
	
	var GradeId = LevelOptions[CurrentLevel][CurrentGrade]['id']
	for Subject in LevelOptions[CurrentLevel][CurrentGrade]['subjects']:
		EditSubjectInstantiate = preload("res://Home/SchoolManager/EditSubject.tscn").instantiate()
		EditSubjectList.add_child(EditSubjectInstantiate)
		var GradeName = CurrentLevel + ' ' + CurrentGrade
		EditSubjectInstantiate.setup(Subject, Teachers, LevelOptions[CurrentLevel][CurrentGrade]['students'], GradeName, GradeId, EditSubjectScreen, DeleteSubject, Token)
	
	
	for Student in LevelOptions[CurrentLevel][CurrentGrade]['students']:
		EditStudentInstantiate = preload("res://Home/SchoolManager/EditStudent.tscn").instantiate()
		EditStudentList.add_child(EditStudentInstantiate)
		EditStudentInstantiate.setup(Student, GradesInLevels, EditStudentScreen, DeleteUser, Token)
	search_by_name(SearchStudent.text, EditStudentList)
	search_by_name(SearchSubject.text, EditSubjectList)


func _on_level_options_subjects_item_selected(index):
	LevelsOptionsButtonStudents.select(index)
	_on_level_options_item_selected(index)


func _on_grade_options_subjects_item_selected(index):
	GradesOptionsButtonStudents.select(index)
	_on_grade_options_item_selected(index)


func _on_level_options_students_item_selected(index):
	LevelsOptionsButtonSubjects.select(index)
	_on_level_options_item_selected(index)


func _on_grade_options_students_item_selected(index):
	GradesOptionsButtonSubjects.select(index)
	_on_grade_options_item_selected(index)


func _on_logout_pressed():
	http_logout_request = HTTPRequest.new()
	add_child(http_logout_request)
	http_logout_request.connect("request_completed", self._http_request_logout_completed)
	logout()


func logout():
	var token_header = "Authorization: Token " + Token
	var headers = ["Content-Type: application/json", "Accept: application/json", token_header]
	http_logout_request.set_timeout(10.0)
	var error = http_logout_request.request(base_url + "api/logout/", headers, false, HTTPClient.METHOD_GET)


func _http_request_logout_completed(result, response_code, headers, body):
	if result == http_logout_request.RESULT_SUCCESS:
		get_tree().get_root().add_child(LoginInstantiate) 
		get_tree().get_root().remove_child(self)
		queue_free()
	else:
		$NoInternetConnection.set_visible(true)



func _on_create_level_button_pressed():
	EditLevelScreen.setup({}, true, Token, LevelNamesCreated)
	EditLevelScreen.open()



func search_by_name(text, List):
	text = text.to_upper()
	for element in List.get_children():
		if text in element.get_name().to_upper() or text == '':
			element.set_visible(true)
		else:
			element.set_visible(false)


func _on_search_teachers_text_changed(new_text):
	search_by_name(new_text, EditTeacherList)
	


func _on_search_students_text_changed(new_text):
	search_by_name(new_text, EditStudentList)



func _on_search_levels_text_changed(new_text):
	search_by_name(new_text, EditLevelList)


func _on_search_subjects_text_changed(new_text):
	search_by_name(new_text, EditSubjectList)


func _on_create_subject_button_pressed(): 
	if CurrentLevel and CurrentGrade:
		var GradeId = LevelOptions[CurrentLevel][CurrentGrade]['id']
		var GradeName = CurrentLevel + ' ' + CurrentGrade
		EditSubjectScreen.setup({}, true, Teachers, LevelOptions[CurrentLevel][CurrentGrade]['students'], GradeName, GradeId, Token)
		EditSubjectScreen.open()
