extends Control

const base_url = "http://127.0.0.1:8000/"
var http_request_student

var StudentEmailEdit
var StudentEmailWarning

var StudentFirstName = ''
var StudentFirstNameEdit
var StudentFirstNameWarning

var StudentMiddleName = ''
var StudentMiddleNameEdit
var StudentMiddleNameWarning

var StudentLastName = ''
var StudentLastNameEdit
var StudentLastNameWarning

var StudentMothersMaidenName = ''
var StudentMothersMaidenNameEdit
var StudentMothersMaidenNameWarning

var StudentLevelOptions
var StudentLevel

var StudentGradeOption
var StudentGrade
var StudentGradeWarning

var StudentPassword = ''
var StudentPasswordEdit
var StudentPasswordWarning

var StudentConfirmPassword = ''
var StudentConfirmPasswordEdit
var StudentConfirmPasswordWarning

var StudentCenterContainer
var SendStudent
var StudentSaved
var Student = {}
var StudentId
var Token
var EditStudent
var GradesInLevels = {}
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

var Levels = {}
var Grades = {}


func _ready():
	StudentEmailEdit = $CenterContainer/VBoxContainer/EmailBox/EmailEdit
	StudentEmailWarning = $CenterContainer/VBoxContainer/EmailWarning
	
	StudentFirstNameEdit = $CenterContainer/VBoxContainer/FirstNameBox/FirstNameEdit
	StudentFirstNameWarning = $CenterContainer/VBoxContainer/FirstNameWarning
	
	StudentMiddleNameEdit = $CenterContainer/VBoxContainer/MiddleNameBox/MiddleNameEdit
	StudentMiddleNameWarning = $CenterContainer/VBoxContainer/MiddleNameWarning
	
	StudentLastNameEdit = $CenterContainer/VBoxContainer/LastNameBox/LastNameEdit
	StudentLastNameWarning = $CenterContainer/VBoxContainer/LastNameWarning
	
	StudentMothersMaidenNameEdit = $CenterContainer/VBoxContainer/MothersMaidenNameBox/MothersMaidenNameEdit
	StudentMothersMaidenNameWarning = $CenterContainer/VBoxContainer/MothersMaidenNameWarning
	
	StudentPasswordEdit = $CenterContainer/VBoxContainer/NewPassword/NewPasswordEdit
	StudentPasswordWarning = $CenterContainer/VBoxContainer/NewPasswordWarning
	
	StudentConfirmPasswordEdit = $CenterContainer/VBoxContainer/ConfirmPassword/ConfirmPasswordEdit
	StudentConfirmPasswordWarning = $CenterContainer/VBoxContainer/ConfirmPasswordWarning
	
	
	StudentCenterContainer = $CenterContainer
	StudentLevelOptions = $CenterContainer/VBoxContainer/GradeBox/LevelOption
	StudentGradeOption = $CenterContainer/VBoxContainer/GradeBox/GradeOption
	StudentGradeWarning = $CenterContainer/VBoxContainer/GradeOptionWarning
	
	http_request_student = HTTPRequest.new()
	add_child(http_request_student)
	http_request_student.connect('request_completed', self.http_request_student_request_completed)
	
	SendStudent = $SendStudentToServer
	StudentSaved = $StudentSaved


func setup(student, levels, token):
	Student = student
	StudentId = Student['id']
	StudentEmailEdit.text = Student['email']
	
	StudentFirstName = Student['first_name']
	StudentFirstNameEdit.text = StudentFirstName
	
	StudentMiddleName = Student['middle_name']
	StudentMiddleNameEdit.text =  StudentMiddleName
	
	StudentLastName = Student['last_name']
	StudentLastNameEdit.text = StudentLastName
	
	StudentMothersMaidenName = Student['mothers_maiden_name']
	StudentMothersMaidenNameEdit.text = StudentMothersMaidenName
	
	StudentPassword = ''
	StudentConfirmPassword = ''
	
	var StudentLevelDict = Student['grade_id']['id_level']
	StudentLevel = StudentLevelDict['number'] + ' ' + StudentLevelDict['type']
	
	Token = token
	
	StudentGrade = Student['grade_id']['letter']
	GradesInLevels = levels
	for level_id in GradesInLevels.keys():
		Levels[GradesInLevels[level_id]['level_name']] = {'id' : level_id, 'grades' : {}}
		for grade in GradesInLevels[level_id]['grades']:
			Levels[GradesInLevels[level_id]['level_name']]['grades'][grade['letter']] = grade['id']
	create_level_options()


func open():
	set_visible(true)
	StudentCenterContainer.set_visible(true)
	SendStudent.set_visible(false)
	StudentSaved.set_visible(false)


func clear_options(MyOptionButton):
	for i in range(MyOptionButton.get_item_count()-1, 0, -1 ):
		MyOptionButton.remove_item(i)


func create_level_options():
	clear_options(StudentLevelOptions)
	var count = 0
	for level in LevelNames:
		if level in Levels.keys():
			StudentLevelOptions.add_item(level)
			count += 1
			if level == StudentLevel:
				StudentLevelOptions.select(count)
	create_grade_options()


func create_grade_options():
	clear_options(StudentGradeOption)
	var alphabet_i = "A"
	var count = 0 
	while alphabet_i <= "Z":
		if alphabet_i in Levels[StudentLevel]['grades'].keys():
			StudentGradeOption.add_item(alphabet_i)
			count += 1
			if alphabet_i == StudentGrade:
				StudentGradeOption.select(count)
		alphabet_i = String.chr(alphabet_i.unicode_at(0) + 1)



func _on_level_option_item_selected(index):
	StudentLevel = StudentLevelOptions.get_item_text(index)
	StudentGrade = null
	create_grade_options()

func _on_grade_option_item_selected(index):
	StudentGrade = StudentGradeOption.get_item_text(index)


func _on_exit_edit_student_pressed():
	StudentId = null
	StudentEmailEdit.text = ''
	StudentFirstNameEdit.text = ''
	StudentMiddleNameEdit.text = ''
	StudentLastNameEdit.text = ''
	StudentMothersMaidenNameEdit.text = ''
	StudentPasswordEdit.text = ''
	StudentConfirmPasswordEdit.text = ''
	clear_options(StudentLevelOptions)
	clear_options(StudentGradeOption)
	set_visible(false)


func _on_save_edit_student_pressed():
	var has_errors = false
	var NewStudent = {}
	if StudentFirstName == '':
		has_errors = true
		StudentFirstNameWarning.text = 'Debes ingresar el primer nombre'
	else:
		NewStudent['first_name'] = StudentFirstName
	
	if StudentMiddleName != '':
		NewStudent['middle_name'] = StudentMiddleName
	
	if StudentLastName == '':
		has_errors = true
		StudentLastNameWarning.text = 'Debes ingresar el primer apellido'
	else:
		NewStudent['last_name'] = StudentLastName
	
	if StudentMothersMaidenName != '':
		NewStudent['mothers_maiden_name'] = StudentMothersMaidenName
	
	if StudentLevel in Levels.keys() and StudentGrade in Levels[StudentLevel]['grades'].keys():
		NewStudent['grade_id'] =  Levels[StudentLevel]['grades'][StudentGrade]
	else:
		has_errors = true
	
	if StudentPassword != '':
		if confirm(StudentPassword):
			if StudentPassword == StudentConfirmPassword:
				NewStudent['password'] = StudentPassword
			else:
				StudentConfirmPasswordWarning.text = 'Las contraseñas no coinciden'
				has_errors = true
		else:
			StudentPasswordWarning.text = 'La contraseña debe tener al menos 8 caracteres, y debe contener solo números y letras'
			has_errors = true
	
	if not has_errors:
		StudentCenterContainer.set_visible(false)
		SendStudent.set_visible(true)
		var token_header = "Authorization: Token " + Token
		var headers = ["Content-Type: application/json", "Accept: application/json", token_header]
		var body = JSON.stringify(NewStudent)
		var error = http_request_student.request(base_url + "api/student-profile/" + str(StudentId) + "/", headers, false, HTTPClient.METHOD_PATCH, body)
		if error != OK:
			push_error("An error ocurred in the HTTP request.")


func confirm(password):
	if password.length() < 8:
		return false
	for element in password:
		if not (((element >='a' and element <= 'z') or (element >= 'A' and element <='Z')) or (element >= '0' and element <= '9')):
			return false
	return true

func http_request_student_request_completed(result, response_code, headers, body):
	if result == http_request_student.RESULT_SUCCESS:
		if response_code == 200:
			var json = JSON.new()
			json.parse(body.get_string_from_utf8())
			var response = json.get_data()
			print(response)
			SendStudent.set_visible(false)
			StudentSaved.set_visible(true)


func _on_go_to_pressed():
	StudentSaved.set_visible(false)
	set_visible(false)
	var parent = get_parent()
	if parent:
		parent.get_school_admin_profile()


func _on_first_name_edit_text_changed(new_text):
	StudentFirstName = new_text
	StudentFirstNameWarning.text = ''



func _on_middle_name_edit_text_changed(new_text):
	StudentMiddleName = new_text
	StudentMiddleNameWarning.text = ''


func _on_last_name_edit_text_changed(new_text):
	StudentLastName = new_text
	StudentLastNameWarning.text = ''


func _on_mothers_maiden_name_edit_text_changed(new_text):
	StudentMothersMaidenName = new_text
	StudentMothersMaidenNameWarning.text = ''


func _on_new_password_edit_text_changed(new_text):
	StudentPassword = new_text
	StudentPasswordWarning.text = ''


func _on_confirm_password_edit_text_changed(new_text):
	StudentConfirmPassword = new_text
	StudentConfirmPasswordWarning.text = ''
