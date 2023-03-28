extends Control

const base_url = "http://127.0.0.1:8000/"
var http_request_teacher

var TeacherEmailEdit
var TeacherEmailWarning

var TeacherFirstName = ''
var TeacherFirstNameEdit
var TeacherFirstNameWarning

var TeacherMiddleName = ''
var TeacherMiddleNameEdit
var TeacherMiddleNameWarning

var TeacherLastName = ''
var TeacherLastNameEdit
var TeacherLastNameWarning

var TeacherMothersMaidenName = ''
var TeacherMothersMaidenNameEdit
var TeacherMothersMaidenNameWarning

var TeacherPassword
var TeacherPasswordEdit
var TeacherPasswordWarning

var TeacherConfirmPassword
var TeacherConfirmPasswordEdit
var TeacherConfirmPasswordWarning

var TeacherCenterContainer
var SendTeacher
var TeacherSaved

var Teacher = {}
var TeacherId
var Token
var EditTeacher

func _ready():
	TeacherEmailEdit = $CenterContainer/VBoxContainer/EmailBox/EmailEdit
	TeacherEmailWarning = $CenterContainer/VBoxContainer/EmailWarning

	TeacherFirstNameEdit = $CenterContainer/VBoxContainer/FirstNameBox/FirstNameEdit
	TeacherFirstNameWarning = $CenterContainer/VBoxContainer/FirstNameWarning

	TeacherMiddleNameEdit = $CenterContainer/VBoxContainer/MiddleNameBox/MiddleNameEdit
	TeacherMiddleNameWarning = $CenterContainer/VBoxContainer/MiddleNameWarning

	TeacherLastNameEdit = $CenterContainer/VBoxContainer/LastNameBox/LastNameEdit
	TeacherLastNameWarning = $CenterContainer/VBoxContainer/LastNameWarning

	TeacherMothersMaidenNameEdit = $CenterContainer/VBoxContainer/MothersMaidenNameBox/MothersMaidenNameEdit
	TeacherMothersMaidenNameWarning = $CenterContainer/VBoxContainer/MothersMaidenNameWarning
	
	TeacherPasswordEdit = $CenterContainer/VBoxContainer/NewPassword/NewPasswordEdit
	TeacherPasswordWarning = $CenterContainer/VBoxContainer/NewPasswordWarning
	
	TeacherConfirmPasswordEdit = $CenterContainer/VBoxContainer/ConfirmPassword/ConfirmPasswordEdit
	TeacherConfirmPasswordWarning = $CenterContainer/VBoxContainer/ConfirmPasswordWarning
	
	TeacherCenterContainer = $CenterContainer
	SendTeacher = $SendTeacherToServer
	TeacherSaved = $TeacherSaved
	http_request_teacher = HTTPRequest.new()
	add_child(http_request_teacher)
	http_request_teacher.connect('request_completed', self.http_request_teacher_request_completed)


func setup(teacher, token):
	Teacher = teacher
	TeacherId = Teacher['id']
	TeacherEmailEdit.text = Teacher['email']
	
	TeacherFirstName = Teacher['first_name']
	TeacherFirstNameEdit.text = TeacherFirstName
	
	TeacherMiddleName = Teacher['middle_name']
	TeacherMiddleNameEdit.text = TeacherMiddleName
	
	TeacherLastName = Teacher['last_name']
	TeacherLastNameEdit.text = TeacherLastName
	
	TeacherMothersMaidenName = Teacher['mothers_maiden_name']
	TeacherMothersMaidenNameEdit.text = TeacherMothersMaidenName
	
	TeacherPassword = ''
	TeacherConfirmPassword = ''
	
	Token = token

func open():
	set_visible(true)
	TeacherCenterContainer.set_visible(true)
	SendTeacher.set_visible(false)
	TeacherSaved.set_visible(false)

func _on_exit_edit_teacher_pressed():
	TeacherId = null
	TeacherEmailEdit.text = ''
	TeacherFirstNameEdit.text = ''
	TeacherMiddleNameEdit.text = ''
	TeacherLastNameEdit.text = ''
	TeacherMothersMaidenNameEdit.text = ''
	TeacherPasswordEdit.text = ''
	TeacherConfirmPasswordEdit.text = ''
	set_visible(false)


func _on_save_edit_teacher_pressed():
	var has_errors = false
	var NewTeacher = {}
	if TeacherFirstName == '':
		has_errors = true
		TeacherFirstNameWarning.text = 'Debes ingresar el primer nombre'
	else:
		NewTeacher['first_name'] = TeacherFirstName
	
	if TeacherMiddleName != '':
		NewTeacher['middle_name'] = TeacherMiddleName
	
	if TeacherLastName == '':
		has_errors = true
		TeacherLastNameWarning.text = 'Debes ingresar el primer apellido'
	else:
		NewTeacher['last_name'] = TeacherLastName
	
	if TeacherMothersMaidenName != '':
		NewTeacher['mothers_maiden_name'] = TeacherMothersMaidenName
	
	if TeacherPassword != '':
		if confirm(TeacherPassword):
			if TeacherPassword == TeacherConfirmPassword:
				NewTeacher['password'] = TeacherPassword
			else:
				TeacherConfirmPasswordWarning.text = 'Las contraseñas no coinciden'
				has_errors = true
		else:
			TeacherPasswordWarning.text = 'La contraseña debe tener al menos 8 caracteres, y debe contener solo números y letras'
			has_errors = true
	
	if not has_errors:
		TeacherCenterContainer.set_visible(false)
		SendTeacher.set_visible(true)
		var token_header = "Authorization: Token " + Token
		var headers = ["Content-Type: application/json", "Accept: application/json", token_header]
		var body = JSON.stringify(NewTeacher)
		var error = http_request_teacher.request(base_url + "api/teacher-profile/" + str(TeacherId) + "/", headers, false, HTTPClient.METHOD_PATCH, body)
		if error != OK:
			push_error("An error ocurred in the HTTP request.")


func confirm(password):
	if password.length() < 8:
		return false
	for element in password:
		if not (((element >='a' and element <= 'z') or (element >= 'A' and element <='Z')) or (element >= '0' and element <= '9')):
			return false
	return true


func _on_first_name_edit_text_changed(new_text):
	TeacherFirstNameWarning.text = ''
	TeacherFirstName = new_text


func _on_middle_name_edit_text_changed(new_text):
	TeacherMiddleNameWarning = ''
	TeacherMiddleName = new_text


func _on_last_name_edit_text_changed(new_text):
	TeacherLastNameWarning = ''
	TeacherLastName = new_text


func _on_mothers_maiden_name_edit_text_changed(new_text):
	TeacherMothersMaidenNameWarning = ''
	TeacherMothersMaidenName = new_text


func _on_new_password_edit_text_changed(new_text):
	TeacherPassword = new_text
	TeacherPasswordWarning.text = ''


func _on_confirm_password_edit_text_changed(new_text):
	TeacherConfirmPassword = new_text
	TeacherConfirmPasswordWarning.text = ''


func http_request_teacher_request_completed(result, response_code, headers, body):
	if result == http_request_teacher.RESULT_SUCCESS:
		if response_code == 200:
			var json = JSON.new()
			json.parse(body.get_string_from_utf8())
			var response = json.get_data()
			SendTeacher.set_visible(false)
			TeacherSaved.set_visible(true)


func _on_go_to_pressed():
	TeacherSaved.set_visible(false)
	set_visible(false)
	var parent = get_parent()
	if parent:
		parent.get_school_admin_profile()

