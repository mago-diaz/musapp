extends Control

const base_url = "http://127.0.0.1:8000/"
var http_profile_request
var http_logout_request
var http_quizzes_request

var LoginInstantiate
var AnswerQuiz

var OpenedQuizList
var AnsweredQuizList

var Student = {}
var StudentLabel

var OpenedQuiz
var AnsweredQuiz

var SubjectOptionButton

var ListOfQuestionInstantiate

var Token

var Subjects = {}

var CurrentSubject =  {}

func _ready():
	LoginInstantiate = load("res://Login/Login.tscn").instantiate()
	AnswerQuiz = load("res://TypeOfQuestion/Standard/StandardQuestion.tscn")
	SubjectOptionButton = $VBoxContainer/CenterContainer/HBoxContainer/SubjectOptions
	StudentLabel = $VBoxContainer/HBoxContainer/HBoxContainer/StudentLabel
	
	http_profile_request = HTTPRequest.new()
	add_child(http_profile_request)
	http_profile_request.connect("request_completed", self._http_request_profile_completed)
	get_student_profile()
	
	OpenedQuizList = $"VBoxContainer/TabContainer/Mis Evaluaciones/Quizzes/VBoxContainer/ColorRect/ScrollContainer/OpenedQuizList"
	AnsweredQuizList = $"VBoxContainer/TabContainer/Mis Notas/AnsweredQuizzes/VBoxContainer/ColorRect/ScrollContainer/AnsweredQuizList"
	
	OpenedQuiz = preload("res://Home/StudentQuiz/OpenedQuiz.tscn")
	AnsweredQuiz = preload("res://Home/StudentQuiz/AnsweredQuiz.tscn")
	
	
	http_quizzes_request =  HTTPRequest.new()
	add_child(http_quizzes_request)
	http_quizzes_request.connect("request_completed", self._http_request_quizzes_completed)


func update_quizzes():
	var token_header = "Authorization: Token " + Token
	var headers = ["Content-Type: application/json", "Accept: application/json", token_header]
	var url = base_url + "api/student-quiz-by-subject/" + str(CurrentSubject["Id"]) + "/"
	var error = http_quizzes_request.request(url, headers, false, HTTPClient.METHOD_GET)


func _http_request_quizzes_completed(result, response_code, headers, body):
	if result == http_profile_request.RESULT_SUCCESS:
		var json = JSON.new()
		json.parse(body.get_string_from_utf8())
		var response= json.get_data()
		var strCurrentSubject = str(CurrentSubject["Id"])
		print(response)
		update_active_quizzes(response[strCurrentSubject]["active_quizzes"])
		update_ended_quizzes(response[strCurrentSubject]["ended_quizzes"])


func update_active_quizzes(ActiveQuizzes):
	for element in OpenedQuizList.get_children():
		OpenedQuizList.remove_child(element)
		element.queue_free()
	
	for Quiz in ActiveQuizzes:
		var OpenedQuizInstantiate = OpenedQuiz.instantiate()
		OpenedQuizList.add_child(OpenedQuizInstantiate)
		OpenedQuizInstantiate.setup(Quiz, Token)


func update_ended_quizzes(EndedQuizzes):
	for element in AnsweredQuizList.get_children():
		AnsweredQuizList.remove_child(element)
		element.queue_free()
	
	for Quiz in EndedQuizzes:
		var AnsweredQuizInstantiate = AnsweredQuiz.instantiate()
		AnsweredQuizList.add_child(AnsweredQuizInstantiate)
		AnsweredQuizInstantiate.setup(Quiz)


func setup(token):
	Token = token


func get_student_profile():
	var token_header = "Authorization: Token " + Token
	var headers = ["Content-Type: application/json", "Accept: application/json", token_header]
	var error = http_profile_request.request(base_url + "api/student-profile/", headers, false, HTTPClient.METHOD_GET)


func _http_request_profile_completed(result, response_code, headers, body):
	if result == http_profile_request.RESULT_SUCCESS:
		var json = JSON.new()
		json.parse(body.get_string_from_utf8())
		var response= json.get_data()
		setup_student(response["student"])
		
		setup_subjects(response["subjects"])


func setup_student(student):
	Student["FullName"] = student["first_name"] + " " + student["middle_name"]  + " " + student["last_name"] + " " + student["mothers_maiden_name"]
	StudentLabel.text = "Alumno: " + Student["FullName"] 
	Student["Id"] = student["id"]


func clear_options(MyOptionButton):
	for i in range(1, MyOptionButton.get_item_count()):
		MyOptionButton.remove_item(i)


func setup_subjects(subjects):
	clear_options(SubjectOptionButton)
	Subjects = {}
	for subject in subjects:
		Subjects[subject["name"]] = subject["id"]
		SubjectOptionButton.add_item(subject["name"])
	if SubjectOptionButton.get_item_count() > 1:
		_on_subject_options_item_selected(1)


func _on_subject_options_item_selected(index):
	CurrentSubject["Name"] = SubjectOptionButton.get_item_text(index)
	CurrentSubject["Id"] = Subjects[CurrentSubject["Name"]]
	update_quizzes()


func _on_logout_pressed():
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


func answer_quiz(response):
	var NewAnswerQuiz = AnswerQuiz.instantiate()
	NewAnswerQuiz.setup(response, Student, Token)
	add_child(NewAnswerQuiz)
