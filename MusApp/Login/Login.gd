extends Control


const base_url = "http://127.0.0.1:8000/"
var email 
var password
var http_request
var http_grades_request
var http_create_user_request
var Token

var Exit
var CreateUser
var TeacherHomeInstantiate
var StudentHomeInstantiate
var SchoolManagerInstantiate

var LevelsAndGrades

var CreateUserEmail = ''
var CreateUserEmailEdit
var CreateUserEmailWarning

var CreateUserFirstName = ''
var CreateUserFirstNameEdit
var CreateUserFirstNameWarning

var CreateUserMiddleName = ''
var CreateUserMiddleNameEdit
var CreateUserMiddleNameWarning

var CreateUserLastName = ''
var CreateUserLastNameEdit
var CreateUserLastNameWarning

var CreateUserMothersMaidenName = ''
var CreateUserMothersMaidenNameEdit
var CreateUserMothersMaidenNameWarning

var CreateUserType = ''
var CreateUserTypeOption
var CreateUserTypeWarning

var CreateUserLevel
var CreateUserLevelOption

var CreateUserGrade 
var CreateUserGradeOption
var CreateUserGradeWarning

var CreateUserPassword = ''
var CreateUserPasswordEdit
var CreateUserPasswordWarning

var CreateUserConfirmPassword = ''
var CreateUserConfirmPasswordEdit
var CreateUserConfirmPasswordWarning

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

var UserCenterContainer
var SendUser
var UserSaved

var LoadingScreen

# Called when the node enters the scene tree for the first time.
func _ready():
	email = $HBoxContainer/Control/CenterContainer/VBoxContainer/emailText
	password = $HBoxContainer/Control/CenterContainer/VBoxContainer/passwordText
	Exit = $Exit
	CreateUser = $CreateUser
	http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.connect("request_completed", self._http_request_completed)
	
	http_grades_request = HTTPRequest.new()
	add_child(http_grades_request)
	http_grades_request.connect('request_completed', self._http_grades_request_completed)
	var headers = ["Content-Type: application/json", "Accept: application/json"]
	http_grades_request.set_timeout(10.0)
	var error = http_grades_request.request(base_url + "api/levels-and-grades/", headers, false, HTTPClient.METHOD_GET)
	
	CreateUserEmailEdit = $CreateUser/CenterContainer/VBoxContainer/EmailBox/EmailEdit
	CreateUserEmailWarning = $CreateUser/CenterContainer/VBoxContainer/EmailWarning

	CreateUserFirstNameEdit = $CreateUser/CenterContainer/VBoxContainer/FirstNameBox/FirstNameEdit
	CreateUserFirstNameWarning = $CreateUser/CenterContainer/VBoxContainer/FirstNameWarning
	
	CreateUserMiddleNameEdit = $CreateUser/CenterContainer/VBoxContainer/MiddleNameBox/MiddleNameEdit
	CreateUserMiddleNameWarning = $CreateUser/CenterContainer/VBoxContainer/MiddleNameWarning

	CreateUserLastNameEdit = $CreateUser/CenterContainer/VBoxContainer/LastNameBox/LastNameEdit
	CreateUserLastNameWarning = $CreateUser/CenterContainer/VBoxContainer/LastNameWarning

	CreateUserMothersMaidenNameEdit = $CreateUser/CenterContainer/VBoxContainer/MothersMaidenNameBox/MothersMaidenNameEdit
	CreateUserMothersMaidenNameWarning = $CreateUser/CenterContainer/VBoxContainer/MothersMaidenNameWarning

	CreateUserTypeOption =$CreateUser/CenterContainer/VBoxContainer/TypeBox/TypeOption
	CreateUserTypeWarning = $CreateUser/CenterContainer/VBoxContainer/TypeBoxOptionWarning
	
	CreateUserLevelOption = $CreateUser/CenterContainer/VBoxContainer/GradeBox/LevelOption
	
	CreateUserGradeOption = $CreateUser/CenterContainer/VBoxContainer/GradeBox/GradeOption
	CreateUserGradeWarning = $CreateUser/CenterContainer/VBoxContainer/GradeOptionWarning
	
	CreateUserPasswordEdit = $CreateUser/CenterContainer/VBoxContainer/NewPassword/NewPasswordEdit
	CreateUserPasswordWarning = $CreateUser/CenterContainer/VBoxContainer/NewPasswordWarning
	
	CreateUserConfirmPasswordEdit = $CreateUser/CenterContainer/VBoxContainer/ConfirmPassword/ConfirmPasswordEdit
	CreateUserConfirmPasswordWarning = $CreateUser/CenterContainer/VBoxContainer/ConfirmPasswordWarning
	
	SendUser = $SendUserToServer
	UserSaved = $UserSaved
	UserCenterContainer = $CreateUser/CenterContainer
	
	LoadingScreen = $Loading
	
	http_create_user_request = HTTPRequest.new()
	add_child(http_create_user_request)
	http_create_user_request.connect('request_completed', self._http_create_user_request_completed)
	
	_on_piano_visibility_changed()
	_on_music_sheet_visibility_changed()


func _on_login_pressed():
	var email_text = email.get_text()
	var password_text = password.get_text()
	var headers = ["Content-Type: application/json", "Accept: application/json"]
	var body = JSON.stringify({"email" : email_text, "password" : password_text})
	http_request.set_timeout(10.0)
	var error = http_request.request(base_url + "api/login/", headers, false, HTTPClient.METHOD_POST, body)
	LoadingScreen.set_visible(true)


func _http_request_completed(result, response_code, headers, body):
	LoadingScreen.set_visible(false)
	if result == http_request.RESULT_SUCCESS:
		if response_code == 200:
			var json = JSON.new()
			json.parse(body.get_string_from_utf8())
			var response= json.get_data()
			print(response)
			if response["type"] == "STUDENT":
				print("is a student")
				StudentHomeInstantiate = preload("res://Home/StudentHome.tscn").instantiate()
				StudentHomeInstantiate.setup(response["token"])
				get_tree().get_root().add_child(StudentHomeInstantiate) 
			elif response["type"] == "TEACHER":
				print("is a teacher")
				TeacherHomeInstantiate = preload("res://Home/TeacherHome.tscn").instantiate()
				TeacherHomeInstantiate.setup(response["token"])
				get_tree().get_root().add_child(TeacherHomeInstantiate) 
			elif response["type"] == "SCHOOL_ADMIN":
				print("is a school admin")
				SchoolManagerInstantiate = preload("res://Home/SchoolManagerHome.tscn").instantiate()
				SchoolManagerInstantiate.setup(response["token"])
				get_tree().get_root().add_child(SchoolManagerInstantiate)
			get_tree().get_root().remove_child(self)
		elif response_code == 400:
			$HBoxContainer/Control/CenterContainer/VBoxContainer/wrongEmail.set_visible(true)
		elif response_code == 401:
			var json = JSON.new()
			json.parse(body.get_string_from_utf8())
			var response= json.get_data()
			print(response)
			print(response_code)
			$HBoxContainer/Control/CenterContainer/VBoxContainer/wrongPassword.set_visible(true)
	else: 
		Token = null
		$NotInternetConnection.set_visible(true)


func _http_grades_request_completed(result, response_code, headers, body):
	if result == http_grades_request.RESULT_SUCCESS:
		if response_code == 200:
			var json = JSON.new()
			json.parse(body.get_string_from_utf8())
			var response= json.get_data()
			set_level_and_grade_(response['levels'], response['grades'])
	else:
		$NotInternetConnection.set_visible(true)


func _http_create_user_request_completed(result, response_code, headers, body):
	SendUser.set_visible(false)
	if result == http_grades_request.RESULT_SUCCESS:
		if response_code == 200:
			var json = JSON.new()
			json.parse(body.get_string_from_utf8())
			var response= json.get_data()
			print(response)
			UserSaved.set_visible(true)
	else:
		CreateUser.set_visible(false)
		$NotInternetConnection.set_visible(true)


func set_level_and_grade_(levels, grades):
	LevelsAndGrades = {}
	for level in levels:
		var level_name = level['number'] + ' ' + level['type']
		LevelsAndGrades[level_name] = {'id' : level['id'], 'grades' : {}}
	
	for grade in grades:
		var level_name_of_grade = grade['id_level']['number'] + ' ' + grade['id_level']['type']
		LevelsAndGrades[level_name_of_grade]['grades'][grade['letter']] = grade['id']
	create_level_options()


func clear_options(MyOptionButton):
	for i in range(MyOptionButton.get_item_count()-1, 0, -1 ):
		MyOptionButton.remove_item(i)


func create_level_options():
	clear_options(CreateUserLevelOption)
	for level in LevelNames:
		if level in LevelsAndGrades.keys():
			CreateUserLevelOption.add_item(level)
	if CreateUserLevelOption.get_item_count() > 1:
		CreateUserLevelOption.select(1)
		_on_level_option_item_selected(1)


func create_grade_options():
	clear_options(CreateUserGradeOption)
	if CreateUserLevel != '' and CreateUserLevel != 'Seleccione Curso':
		var alphabet_i = "A"
		var count = 0 
		while alphabet_i <= "Z":
			if alphabet_i in LevelsAndGrades[CreateUserLevel]['grades'].keys():
				CreateUserGradeOption.add_item(alphabet_i)
				count += 1
			alphabet_i = String.chr(alphabet_i.unicode_at(0) + 1)
		if CreateUserGradeOption.get_item_count() > 1:
			CreateUserGradeOption.select(1)
			_on_grade_option_item_selected(1)


func _on_email_text_text_changed(new_text):
	$HBoxContainer/Control/CenterContainer/VBoxContainer/wrongEmail.set_visible(false)
	$HBoxContainer/Control/CenterContainer/VBoxContainer/wrongPassword.set_visible(false)


func _on_password_text_text_changed(new_text):
	$HBoxContainer/Control/CenterContainer/VBoxContainer/wrongPassword.set_visible(false)


func _on_exit_pressed():
	get_tree().quit()


func _on_back_pressed():
	Exit.set_visible(false)


func _on_pre_exit_pressed():
	Exit.set_visible(true)


func _on_create_user_pressed():
	CreateUser.set_visible(true)
	UserCenterContainer.set_visible(true)
	SendUser.set_visible(false)
	UserSaved.set_visible(false)


func _on_exit_create_user_pressed():
	CreateUser.set_visible(false)
	UserCenterContainer.set_visible(true)
	SendUser.set_visible(false)
	UserSaved.set_visible(false)
	CreateUserEmail = ''
	CreateUserEmailEdit.text = ''
	CreateUserEmailWarning.text = ''
	
	CreateUserFirstName = ''
	CreateUserFirstNameEdit.text = ''
	CreateUserFirstNameWarning.text = ''
	
	CreateUserMiddleName = ''
	CreateUserMiddleNameEdit.text = ''
	CreateUserMiddleNameWarning.text = ''
	
	CreateUserLastName = ''
	CreateUserLastNameEdit.text = ''
	CreateUserLastNameWarning.text = ''
	
	CreateUserMothersMaidenName = ''
	CreateUserMothersMaidenNameEdit.text = ''
	CreateUserMothersMaidenNameWarning.text = ''

	CreateUserPassword = ''
	CreateUserPasswordEdit.text = ''
	CreateUserPasswordWarning.text = ''
	
	CreateUserConfirmPassword = ''
	CreateUserConfirmPasswordEdit.text = ''
	CreateUserConfirmPasswordWarning.text = ''
	
	CreateUserType = ''
	CreateUserTypeOption.select(0)
	_on_type_option_item_selected(0)
	CreateUserLevel = ''
	CreateUserLevelOption.select(0)
	_on_level_option_item_selected(0)
	CreateUserLevelOption.set_disabled(true)
	CreateUserGrade = ''
	CreateUserGradeOption.select(0)
	_on_grade_option_item_selected(0)
	CreateUserGradeOption.set_disabled(true)


func _on_save_create_user_pressed():
	var User = {}
	var HasErrors = false
	if CreateUserEmail == '':
		HasErrors = true
		CreateUserEmailWarning.text = '* Debes rellenar el campo Email *'
	elif confirm_email(CreateUserEmail):
		CreateUserEmailWarning.text = '* El email debe contener @ . y tener al menos 8 caracteres *'
	else:
		User['email'] = CreateUserEmail
		
	if CreateUserFirstName == '':
		HasErrors = true
		CreateUserFirstNameWarning.text = '* Debes rellenar el campo Primer Nombre *'
	else:
		User['first_name'] = CreateUserFirstName
	
	if CreateUserMiddleName != '':
		User['middle_name'] = CreateUserMiddleName
	
	if CreateUserLastName == '':
		HasErrors = true
		CreateUserLastNameWarning.text = '* Debes rellenar el campo Primer Apellido *'
	else:
		User['last_name'] = CreateUserLastName
	
	if CreateUserMothersMaidenName != '':
		User['mothers_maiden_name'] = CreateUserMothersMaidenName
	
	if CreateUserType == '':
		HasErrors = true
		CreateUserTypeWarning.text = '* Debes seleccionar una opción en Ocupación *'
	else:
		if CreateUserType == 'STUDENT':
			User['type'] = CreateUserType
			if CreateUserGrade == null:
				HasErrors = true
				CreateUserGradeWarning.text = '* Debes seleccionar una opción en Curso *'
			else:
				User['grade_id'] = LevelsAndGrades[CreateUserLevel]['grades'][CreateUserGrade]
		elif CreateUserType == 'TEACHER':
			User['type'] = CreateUserType
	
	if CreateUserPassword != '':
		if confirm_password(CreateUserPassword):
			if CreateUserPassword == CreateUserConfirmPassword:
				User['password'] = CreateUserPassword
			else:
				CreateUserConfirmPasswordWarning.text = 'Las contraseñas no coinciden'
				HasErrors = true
		else:
			CreateUserPasswordWarning.text = 'La contraseña debe tener al menos 8 caracteres, y debe contener solo números, letras y el símbolo "_"'
			HasErrors = true
	
	if not HasErrors:
		var headers = ["Content-Type: application/json", "Accept: application/json"]
		var body = JSON.stringify(User)
		http_create_user_request.set_timeout(10.0)
		var error = http_create_user_request.request(base_url + "api/create-user/", headers, false, HTTPClient.METHOD_POST, body)
		UserCenterContainer.set_visible(false)
		SendUser.set_visible(true)


func confirm_password(password):
	if password.length() < 8:
		return false
	for element in password:
		if not (((element >='a' and element <= 'z') or (element >= 'A' and element <='Z')) or (element >= '0' and element <= '9') or element == '_' ):
			return false
	return true


func confirm_email(email):
	if email.length() < 8:
		return false
	var has_at = false
	var has_dot = false
	for element in email:
		if element == '@':
			has_at = true
		if element == '.' and has_at == true:
			has_dot = true
		if not (((element >='a' and element <= 'z') or (element >= 'A' and element <='Z')) or (element >= '0' and element <= '9') or element == '_' ):
			return false
	return has_at and has_dot


func _on_email_edit_text_changed(new_text):
	CreateUserEmail = new_text
	CreateUserEmailWarning.text = ''


func _on_first_name_edit_text_changed(new_text):
	CreateUserFirstName = new_text
	CreateUserFirstNameWarning.text = ''


func _on_middle_name_edit_text_changed(new_text):
	CreateUserMiddleName = new_text
	CreateUserMiddleNameWarning.text = ''


func _on_last_name_edit_text_changed(new_text):
	CreateUserLastName = new_text
	CreateUserLastNameWarning.text = ''


func _on_mothers_maiden_name_edit_text_changed(new_text):
	CreateUserMothersMaidenName = new_text
	CreateUserMiddleNameWarning.text = ''


func _on_type_option_item_selected(index):
	if index == 1:
		CreateUserType = "STUDENT"
		CreateUserGradeOption.set_disabled(false)
		CreateUserLevelOption.set_disabled(false)
	elif index == 2:
		CreateUserType = "TEACHER"
		CreateUserGradeOption.set_disabled(true)
		CreateUserLevelOption.set_disabled(true)
	else:
		CreateUserType = ''
	CreateUserTypeWarning.text = ''


func _on_level_option_item_selected(index):
	CreateUserLevel = CreateUserLevelOption.get_item_text(index)
	CreateUserGrade = null
	create_grade_options()


func _on_grade_option_item_selected(index):
	CreateUserGrade = CreateUserGradeOption.get_item_text(index)


func _on_new_password_edit_text_changed(new_text):
	CreateUserPassword = new_text
	CreateUserPasswordWarning.text = ''

func _on_confirm_password_edit_text_changed(new_text):
	CreateUserConfirmPassword = new_text
	CreateUserConfirmPasswordWarning.text = ''


func _on_go_to_pressed():
	UserSaved.set_visible(false)
	CreateUser.set_visible(false)
	UserCenterContainer.set_visible(true)
	SendUser.set_visible(false)
	UserSaved.set_visible(false)
	CreateUserEmail = ''
	CreateUserEmailEdit.text = ''
	CreateUserEmailWarning.text = ''
	
	CreateUserFirstName = ''
	CreateUserFirstNameEdit.text = ''
	CreateUserFirstNameWarning.text = ''
	
	CreateUserMiddleName = ''
	CreateUserMiddleNameEdit.text = ''
	CreateUserMiddleNameWarning.text = ''
	
	CreateUserLastName = ''
	CreateUserLastNameEdit.text = ''
	CreateUserLastNameWarning.text = ''
	
	CreateUserMothersMaidenName = ''
	CreateUserMothersMaidenNameEdit.text = ''
	CreateUserMothersMaidenNameWarning.text = ''

	CreateUserPassword = ''
	CreateUserPasswordEdit.text = ''
	CreateUserPasswordWarning.text = ''
	
	CreateUserConfirmPassword = ''
	CreateUserConfirmPasswordEdit.text = ''
	CreateUserConfirmPasswordWarning.text = ''
	
	CreateUserType = ''
	CreateUserTypeOption.select(0)
	_on_type_option_item_selected(0)
	CreateUserLevel = ''
	CreateUserLevelOption.select(0)
	_on_level_option_item_selected(0)
	CreateUserLevelOption.set_disabled(true)
	CreateUserGrade = ''
	CreateUserGradeOption.select(0)
	_on_grade_option_item_selected(0)
	CreateUserGradeOption.set_disabled(true)


func _on_no_conection_button_pressed():
	$NotInternetConnection.set_visible(false)
	

func _on_piano_button_pressed():
	$Piano.set_visible(true)


func _on_music_sheet_pressed():
	$MusicSheet.set_visible(true)


func _on_close_piano_pressed():
	$Piano.set_visible(false)
	$Piano/CenterContainer/PianoBox/PianoManager.manually_stop_song()
	$Piano/CenterContainer/PianoBox/PianoManager.stop_all_notes()


func _on_close_music_sheet_pressed():
	$MusicSheet/CenterContainer/MusicBox/MusicSheet.stop_song()
	$MusicSheet.set_visible(false)



func _on_piano_visibility_changed():
	$HBoxContainer/Control/CenterContainer/VBoxContainer.set_visible(not $Piano.visible)
	$Piano/CenterContainer/PianoBox/PianoManager.disable_input(not $Piano.visible)


func _on_music_sheet_visibility_changed():
	$HBoxContainer/Control/CenterContainer/VBoxContainer.set_visible(not $MusicSheet.visible)
	$MusicSheet/CenterContainer/MusicBox/MusicSheet.disable_input(not $MusicSheet.visible)
