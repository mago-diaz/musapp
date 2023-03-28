extends Control

const base_url = "http://127.0.0.1:8000/"
var http_profile_request
var http_logout_request
var http_quizzes_request

var LoginInstantiate

var Token 
var TeacherLabel
var CurrentSubjectId
var email

var MakeEvaluation
var CreateListOfQuestionInstantiate

var NewQuizName = null
var NewQuizDay = null
var NewQuizMonth = null
var NewQuizYear = null
var NewMinQuizGrade = null
var NewAprobalQuizGrade = null
var NewMaxQuizGrade = null
var Scale = null

var NewQuizHours = null
var NewQuizMinutes = null

var CreatedQuizList
var OpenedQuizList
var AnsweredQuizList

var CreatedQuiz
var OpenedQuiz
var AnsweredQuiz

var StrangeMonths = [2, 4, 6, 9, 11]

var Months = {1 : "Enero",
			2 : "Febrero",
			3 : "Marzo",
			4 : "Abril",
			5 : "Mayo",
			6 : "Junio",
			7 : "Julio",
			8 : "Agosto",
			9 : "Septiembre",
			10 : "Octubre",
			11 : "Noviembre",
			12 : "Diciembre"}
			
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

var LevelOptions = {}

var LevelsOptionsButton
var GradesOptionsButton
var SubjectsOptionsButton

var CurrentLevel = null
var CurrentGrade = null
var CurrentSubject =  {}
var Teacher = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	LoginInstantiate = load("res://Login/Login.tscn").instantiate()
	TeacherLabel = $VBoxContainer/Header/HBoxContainer/TeacherLabel
	
	LevelsOptionsButton = $VBoxContainer/CenterContainer/SubjectContainer/LevelOptions
	GradesOptionsButton = $VBoxContainer/CenterContainer/SubjectContainer/GradeOptions
	SubjectsOptionsButton = $VBoxContainer/CenterContainer/SubjectContainer/SubjectOptions
	
	MakeEvaluation = $"VBoxContainer/TabContainer/Crear Evaluaciones/MakeQuizzes/MakeEvaluationPopup"
	http_profile_request = HTTPRequest.new()
	add_child(http_profile_request)
	http_profile_request.connect("request_completed", self._http_request_profile_completed)
	get_teacher_profile()
	
	
	CreatedQuizList = $"VBoxContainer/TabContainer/Crear Evaluaciones/MakeQuizzes/VBoxContainer/ColorRect/ScrollContainer/CreateQuizList"
	OpenedQuizList = $"VBoxContainer/TabContainer/Evaluaciones Abiertas/Quizzes/VBoxContainer/ColorRect/ScrollContainer/OpenedQuizList"
	AnsweredQuizList = $"VBoxContainer/TabContainer/Revisar Evaluaciones/AnsweredQuizzes/VBoxContainer/ColorRect/ScrollContainer/AnsweredQuizList"
	
	CreatedQuiz = preload("res://Home/TeacherQuiz/CreatedQuiz.tscn")
	OpenedQuiz = preload("res://Home/TeacherQuiz/OpenedQuiz.tscn")
	AnsweredQuiz = preload("res://Home/TeacherQuiz/AnsweredQuiz.tscn")
	
	
	http_quizzes_request =  HTTPRequest.new()
	add_child(http_quizzes_request)
	http_quizzes_request.connect("request_completed", self._http_request_quizzes_completed)


func setup(token):
	Token = token


func update_quizzes():
	var token_header = "Authorization: Token " + Token
	var headers = ["Content-Type: application/json", "Accept: application/json", token_header]
	var url = base_url + "api/teacher-quiz-by-subject/" + str(CurrentSubject["Id"]) + "/"
	var error = http_quizzes_request.request(url, headers, false, HTTPClient.METHOD_GET)


func _http_request_quizzes_completed(result, response_code, headers, body):
	if result == http_profile_request.RESULT_SUCCESS:
		var json = JSON.new()
		json.parse(body.get_string_from_utf8())
		var response= json.get_data()
		var strCurrentSubject = str(CurrentSubject["Id"])
		update_inactive_quizzes(response[strCurrentSubject]["inactive_quizzes"])
		update_active_quizzes(response[strCurrentSubject]["active_quizzes"])
		update_ended_quizzes(response[strCurrentSubject]["ended_quizzes"])


func update_inactive_quizzes(InactiveQuizzes):
	for element in CreatedQuizList.get_children():
		CreatedQuizList.remove_child(element)
		element.queue_free()
	
	for Quiz in InactiveQuizzes:
		var CreatedQuizInstantiate = CreatedQuiz.instantiate()
		CreatedQuizList.add_child(CreatedQuizInstantiate)
		CreatedQuizInstantiate.setup(Quiz, Teacher["FullName"], Token)


func update_active_quizzes(ActiveQuizzes):
	for element in OpenedQuizList.get_children():
		OpenedQuizList.remove_child(element)
		element.queue_free()

	for Quiz in ActiveQuizzes:
		var OpenedQuizInstantiate = OpenedQuiz.instantiate()
		OpenedQuizList.add_child(OpenedQuizInstantiate)
		OpenedQuizInstantiate.setup(Quiz, Teacher["FullName"], Token)


func update_ended_quizzes(EndedQuizzes):
	for element in AnsweredQuizList.get_children():
		AnsweredQuizList.remove_child(element)
		element.queue_free()
	
	for Quiz in EndedQuizzes:
		var AnsweredQuizInstantiate = AnsweredQuiz.instantiate()
		AnsweredQuizList.add_child(AnsweredQuizInstantiate)
		AnsweredQuizInstantiate.setup(Quiz, Teacher["FullName"], Token)


func get_teacher_profile():
	var token_header = "Authorization: Token " + Token
	var headers = ["Content-Type: application/json", "Accept: application/json", token_header]
	var error = http_profile_request.request(base_url + "api/teacher-profile/", headers, false, HTTPClient.METHOD_GET)


func _http_request_profile_completed(result, response_code, headers, body):
	if result == http_profile_request.RESULT_SUCCESS:
		var json = JSON.new()
		json.parse(body.get_string_from_utf8())
		var response= json.get_data()
		setup_teacher(response["teacher"])
		setup_subjects(response["subjects"])

func setup_teacher(teacher):
	Teacher["FullName"] = teacher["first_name"] + " " + teacher["middle_name"]  + " " + teacher["last_name"] + " " + teacher["mothers_maiden_name"]
	TeacherLabel.text = "Profesor: " + Teacher["FullName"] 
	Teacher["Id"] = teacher["id"]


func setup_subjects(subjects):
	LevelOptions = {}
	for subject in subjects:
		var level = subject["grade_id"]["id_level"]
		var level_name = level["number"] + " " + level["type"]
		if LevelOptions.has(level_name):
			if LevelOptions[level_name].has(subject["grade_id"]["letter"]):
				LevelOptions[level_name][subject["grade_id"]["letter"]][subject["name"]] = subject["id"]
			else:
				LevelOptions[level_name][subject["grade_id"]["letter"]] = {subject["name"] : subject["id"]}
		else:
			LevelOptions[level_name] = { subject["grade_id"]["letter"] : {subject["name"] : subject["id"]}}
	create_level_options()
	

func clear_options(MyOptionButton):
	for i in range(MyOptionButton.get_item_count()-1, 0, -1 ):
		MyOptionButton.remove_item(i)


func create_level_options():
	clear_options(LevelsOptionsButton)
	clear_options(GradesOptionsButton)
	clear_options(SubjectsOptionsButton)
	for level in LevelNames:
		if LevelOptions.has(level):
			LevelsOptionsButton.add_item(level)
	if LevelsOptionsButton.get_item_count() > 1:
		_on_level_options_item_selected(1)


func create_grade_options():
	clear_options(GradesOptionsButton)
	clear_options(SubjectsOptionsButton)
	if CurrentLevel and LevelOptions.has(CurrentLevel):
		var alphabet_i = "A"
		while alphabet_i <= "Z":
			if LevelOptions[CurrentLevel].has(alphabet_i):
				GradesOptionsButton.add_item(alphabet_i)
			alphabet_i = String.chr(alphabet_i.unicode_at(0) + 1)
	if GradesOptionsButton.get_item_count() > 1:
		_on_grade_options_item_selected(1)


func create_subject_options():
	clear_options(SubjectsOptionsButton)
	if (CurrentLevel and LevelOptions.has(CurrentLevel)) and (CurrentGrade and LevelOptions[CurrentLevel].has(CurrentGrade)):
		for subject in LevelOptions[CurrentLevel][CurrentGrade].keys():
			SubjectsOptionsButton.add_item(subject)
	if SubjectsOptionsButton.get_item_count() > 1:
		_on_subject_options_item_selected(1)


func _on_level_options_item_selected(index):
	CurrentLevel = LevelsOptionsButton.get_item_text(index)
	CurrentGrade = null
	CurrentSubject = {}
	create_grade_options()
	


func _on_grade_options_item_selected(index):
	CurrentGrade = GradesOptionsButton.get_item_text(index)
	CurrentSubject = {}
	create_subject_options()


func _on_subject_options_item_selected(index):
	CurrentSubject["Name"] = SubjectsOptionsButton.get_item_text(index)
	CurrentSubject["Id"] = LevelOptions[CurrentLevel][CurrentGrade][CurrentSubject["Name"]]
	$"VBoxContainer/TabContainer/Crear Evaluaciones/MakeQuizzes/VBoxContainer/CenterContainer/MakeEvaluation".set_disabled(false)
	var InfoNewQuiz = $"VBoxContainer/TabContainer/Crear Evaluaciones/MakeQuizzes/MakeEvaluationPopup/CenterContainer/VBoxContainer/HBoxContainer3/SubjectName"
	InfoNewQuiz.text = CurrentSubject["Name"] + " - " + CurrentLevel + " " + CurrentGrade
	
	var CreateQuizzesListOfQuizzesLabel = $"VBoxContainer/TabContainer/Crear Evaluaciones/MakeQuizzes/VBoxContainer/HBoxContainer/ListOfQuizzesLabel"
	CreateQuizzesListOfQuizzesLabel.text = "Lista de evaluaciones creadas en la asignatura de: " + CurrentSubject["Name"]
	
	var OpenedQuizzesListOfQuizzesLabel = $"VBoxContainer/TabContainer/Evaluaciones Abiertas/Quizzes/VBoxContainer/HBoxContainer/ListOfQuizzesLabel"
	OpenedQuizzesListOfQuizzesLabel.text = "Lista de evaluaciones abiertas en la asignatura de: " + CurrentSubject["Name"]
	
	var AnsweredQuizzesListOfQuizzesLabel = $"VBoxContainer/TabContainer/Revisar Evaluaciones/AnsweredQuizzes/VBoxContainer/HBoxContainer/ListOfQuizzesLabel"
	AnsweredQuizzesListOfQuizzesLabel.text = "Lista de evaluaciones finalizadas en la asignatura de: " + CurrentSubject["Name"]
	
	update_quizzes()


func _on_button_pressed():
	http_logout_request = HTTPRequest.new()
	add_child(http_logout_request)
	http_logout_request.connect("request_completed", self._http_request_logout_completed)
	logout()


func logout():
	var token_header = "Authorization: Token " + Token
	var headers = ["Content-Type: application/json", "Accept: application/json", token_header]
	var error = http_logout_request.request(base_url + "api/logout/", headers, false, HTTPClient.METHOD_GET)


func _http_request_logout_completed(result, response_code, headers, body):
	if result == http_logout_request.RESULT_SUCCESS:
		get_tree().get_root().add_child(LoginInstantiate) 
		get_tree().get_root().remove_child(self)
		queue_free()


func _on_make_evaluation_pressed():
	NewQuizName = null
	var QuizNameText = $"VBoxContainer/TabContainer/Crear Evaluaciones/MakeQuizzes/MakeEvaluationPopup/CenterContainer/VBoxContainer/HBoxContainer/QuizName"
	QuizNameText.text = ""
	
	NewMinQuizGrade = null
	var SpinMinQuizGrade = $"VBoxContainer/TabContainer/Crear Evaluaciones/MakeQuizzes/MakeEvaluationPopup/CenterContainer/VBoxContainer/HBoxContainer5/MinQuizGrade"
	NewMinQuizGrade = SpinMinQuizGrade.get_value()
	
	NewAprobalQuizGrade = null
	var SpinAprobalQuizGrade = $"VBoxContainer/TabContainer/Crear Evaluaciones/MakeQuizzes/MakeEvaluationPopup/CenterContainer/VBoxContainer/HBoxContainer7/AprobalQuizGrade"
	NewAprobalQuizGrade = SpinAprobalQuizGrade.get_value()
	
	NewMaxQuizGrade = null
	var SpinMaxQuizGrade = $"VBoxContainer/TabContainer/Crear Evaluaciones/MakeQuizzes/MakeEvaluationPopup/CenterContainer/VBoxContainer/HBoxContainer6/MaxQuizGrade"
	NewMaxQuizGrade = SpinMaxQuizGrade.get_value()

	Scale = null
	var SpinScale = $"VBoxContainer/TabContainer/Crear Evaluaciones/MakeQuizzes/MakeEvaluationPopup/CenterContainer/VBoxContainer/HBoxContainer9/Scale"
	Scale = SpinScale.get_value()
	
	NewQuizDay = null
	var DayButton = $"VBoxContainer/TabContainer/Crear Evaluaciones/MakeQuizzes/MakeEvaluationPopup/CenterContainer/VBoxContainer/HBoxContainer4/DayButton"
	DayButton.select(0)
	
	NewQuizMonth = null
	var MonthButton = $"VBoxContainer/TabContainer/Crear Evaluaciones/MakeQuizzes/MakeEvaluationPopup/CenterContainer/VBoxContainer/HBoxContainer4/MonthButton"
	MonthButton.select(0)
	
	NewQuizYear = null
	var YearButton = $"VBoxContainer/TabContainer/Crear Evaluaciones/MakeQuizzes/MakeEvaluationPopup/CenterContainer/VBoxContainer/HBoxContainer4/YearButton"
	YearButton.select(0)
	
	NewQuizHours = null
	var HourButton = $"VBoxContainer/TabContainer/Crear Evaluaciones/MakeQuizzes/MakeEvaluationPopup/CenterContainer/VBoxContainer/HBoxContainer2/HoursButton"
	HourButton.select(0)
	
	NewQuizMinutes = null
	var MinuteButton = $"VBoxContainer/TabContainer/Crear Evaluaciones/MakeQuizzes/MakeEvaluationPopup/CenterContainer/VBoxContainer/HBoxContainer2/MinuteButton"
	MinuteButton.select(0)
	
	MakeEvaluation.set_visible(true)


func _on_cancel_make_evalulation_pressed():
	restart_make_evaluation()
	MakeEvaluation.set_visible(false)


func _on_goto_pressed():
	var has_errors = false
	if NewQuizName == "" or NewQuizName == null:
		has_errors = true
		var QuizWarning = $"VBoxContainer/TabContainer/Crear Evaluaciones/MakeQuizzes/MakeEvaluationPopup/CenterContainer/VBoxContainer/NameQuizWarning"
		QuizWarning.text = "* Debes ingresar un nombre para la evaluacion"
	if NewQuizDay == null or NewQuizMonth == null or NewQuizYear == null:
		has_errors = true
		var DateWarning = $"VBoxContainer/TabContainer/Crear Evaluaciones/MakeQuizzes/MakeEvaluationPopup/CenterContainer/VBoxContainer/DateWarning"
		DateWarning.text = "* Debes especificar un fecha válida de entrega"
	if NewQuizHours == null or NewQuizMinutes == null:
		var TimeWarning = $"VBoxContainer/TabContainer/Crear Evaluaciones/MakeQuizzes/MakeEvaluationPopup/CenterContainer/VBoxContainer/TimeWarning"
		TimeWarning.text = "* Debes especificar un tiempo para responder la evaluación"
	if not has_errors:
		var FullDate = str(NewQuizDay) + " de " + str(NewQuizMonth) + " del " + str(NewQuizYear)
		var EndTime = (NewQuizHours * 60) + NewQuizMinutes
		CreateListOfQuestionInstantiate = preload("res://CreateQuestion/Standard/CreateListOfQuestion.tscn").instantiate()
		CreateListOfQuestionInstantiate.setup(NewQuizName, Teacher, NewMinQuizGrade, NewAprobalQuizGrade, NewMaxQuizGrade, Scale, CurrentSubject, FullDate, EndTime, Token)
		restart_make_evaluation()
		add_child(CreateListOfQuestionInstantiate) 


func restart_make_evaluation():
	MakeEvaluation.set_visible(false)
	var QuizNameLabel = $"VBoxContainer/TabContainer/Crear Evaluaciones/MakeQuizzes/MakeEvaluationPopup/CenterContainer/VBoxContainer/HBoxContainer/QuizName"
	QuizNameLabel.text = ""
	var DayOptions = $"VBoxContainer/TabContainer/Crear Evaluaciones/MakeQuizzes/MakeEvaluationPopup/CenterContainer/VBoxContainer/HBoxContainer4/DayButton"
	var MonthOptions = $"VBoxContainer/TabContainer/Crear Evaluaciones/MakeQuizzes/MakeEvaluationPopup/CenterContainer/VBoxContainer/HBoxContainer4/MonthButton"
	var YearOptions = $"VBoxContainer/TabContainer/Crear Evaluaciones/MakeQuizzes/MakeEvaluationPopup/CenterContainer/VBoxContainer/HBoxContainer4/YearButton"
	DayOptions.select(0)
	MonthOptions.select(0)
	YearOptions.select(0)
	NewMinQuizGrade = null
	NewMaxQuizGrade = null
	NewAprobalQuizGrade = null
	Scale = null


func _on_day_button_item_selected(index):
	var MonthOptions = $"VBoxContainer/TabContainer/Crear Evaluaciones/MakeQuizzes/MakeEvaluationPopup/CenterContainer/VBoxContainer/HBoxContainer4/MonthButton"
	NewQuizDay = index
	if NewQuizDay == 31:
		for i in StrangeMonths:
			MonthOptions.set_item_disabled(i, true)
	elif NewQuizDay > 29:
		for i in range(13):
			MonthOptions.set_item_disabled(i, false)
		MonthOptions.set_item_disabled(2, true)
	else:
		for i in range(13):
			MonthOptions.set_item_disabled(i, false)
	if NewQuizMonth !=  null and NewQuizYear != null:
		var DateWarning = $"VBoxContainer/TabContainer/Crear Evaluaciones/MakeQuizzes/MakeEvaluationPopup/CenterContainer/VBoxContainer/DateWarning"
		DateWarning.text = ""


func _on_month_button_item_selected(index):
	NewQuizMonth = Months[index]
	if NewQuizDay !=  null and NewQuizYear != null:
		var DateWarning = $"VBoxContainer/TabContainer/Crear Evaluaciones/MakeQuizzes/MakeEvaluationPopup/CenterContainer/VBoxContainer/DateWarning"
		DateWarning.text = ""


func _on_year_button_item_selected(index):
	NewQuizYear = 2021 + index      
	if NewQuizDay !=  null and NewQuizMonth != null:
		var DateWarning = $"VBoxContainer/TabContainer/Crear Evaluaciones/MakeQuizzes/MakeEvaluationPopup/CenterContainer/VBoxContainer/DateWarning"
		DateWarning.text = ""


func _on_quiz_name_text_changed(new_text):
	NewQuizName = new_text
	var QuizWarning = $"VBoxContainer/TabContainer/Crear Evaluaciones/MakeQuizzes/MakeEvaluationPopup/CenterContainer/VBoxContainer/NameQuizWarning"
	QuizWarning.text = ""


func _on_hours_button_item_selected(index):
	NewQuizHours = index - 1


func _on_minute_button_item_selected(index):
	NewQuizMinutes = (index - 1) * 15


func _on_min_quiz_grade_value_changed(value):
	NewMinQuizGrade = value


func _on_max_quiz_grade_value_changed(value):
	NewMaxQuizGrade = value


func _on_scale_value_changed(value):
	Scale = value


func _on_aprobal_quiz_grade_value_changed(value):
	NewAprobalQuizGrade = value
