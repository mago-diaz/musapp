extends CenterContainer

const base_url = "http://127.0.0.1:8000/"
var http_answered_quiz_request
var http_create_answered_quiz_request
var StudentLabel
var LevelAndGradeLabel
var ScoreLabel
var TimeSpend
var QuizGradeLabel

var CheckQuestionInstantiate

var EditStudent
var GiveMinScore

var Student
var AnswerQuiz
var Quiz
var Token

func _ready():
	StudentLabel = $HBoxContainer/CenterContainer2/VBoxContainer/StudentBox/StudentLabel
	LevelAndGradeLabel = $HBoxContainer/CenterContainer2/VBoxContainer/StudentBox/LevelAndGrade
	ScoreLabel = $HBoxContainer/CenterContainer2/VBoxContainer/TestBox/ScoreLabel
	TimeSpend = $HBoxContainer/CenterContainer2/VBoxContainer/TestBox/TimeSpendLabel
	QuizGradeLabel = $HBoxContainer/CenterContainer2/VBoxContainer/StudentBox/QuizGradeLabel
	EditStudent = $HBoxContainer/CenterContainer/HBoxContainer/EditStudent
	GiveMinScore = $HBoxContainer/CenterContainer/HBoxContainer/GiveMinScore
	http_answered_quiz_request = HTTPRequest.new()
	add_child(http_answered_quiz_request)
	http_answered_quiz_request.connect('request_completed', self._http_answered_quiz_request_completed)
	
	http_create_answered_quiz_request = HTTPRequest.new()
	add_child(http_create_answered_quiz_request)
	http_create_answered_quiz_request.connect('request_completed', self._http_create_answered_quiz_request_completed)


func fullname(User):
	return User['first_name'] + ' ' + User['middle_name'] + ' ' + User['last_name'] + ' ' + User['mothers_maiden_name']


func setup(student_and_answer, quiz, token):
	Student = student_and_answer['student']
	Quiz = quiz
	Token = token
	AnswerQuiz = student_and_answer['answered_quiz']
	StudentLabel.text = fullname(Student)
	LevelAndGradeLabel.text = Student['grade_id']['id_level']['number'] + ' ' +  Student['grade_id']['id_level']['type'] + ' ' +   Student['grade_id']['letter']
	if not AnswerQuiz.has('id'):
		ScoreLabel.text = 'Sin Puntaje'
		TimeSpend.text = 'El alumno no abrió la evaluación'
		QuizGradeLabel.text = 'Sin Nota'
		GiveMinScore.set_visible(true)
		GiveMinScore.set_disabled(false)
		EditStudent.set_visible(false)
	elif AnswerQuiz["create_by_teacher"]:
		ScoreLabel.text = 'Sin Puntaje'
		TimeSpend.text = 'El alumno no abrió la evaluación'
		QuizGradeLabel.text = str(AnswerQuiz['quiz_grade'])
		GiveMinScore.set_visible(true)
		GiveMinScore.set_disabled(true)
		EditStudent.set_visible(false)
	else:
		ScoreLabel.text = str(AnswerQuiz['score_obtained'])
		TimeSpend.text = str(quiz['ended_time'] - AnswerQuiz['time_left']) + 'min'
		QuizGradeLabel.text = 'Sin nota'
		GiveMinScore.set_visible(false)
		EditStudent.set_visible(true)
		if AnswerQuiz['is_checked'] and not AnswerQuiz["create_by_teacher"]:
			EditStudent.text = 'Editar Revisión'
			if AnswerQuiz['quiz_grade'].to_float() >= Quiz['aprobal_quiz_grade'].to_float():
				QuizGradeLabel.set('theme_override_colors/font_color', Color.GREEN)
			else:
				QuizGradeLabel.set('theme_override_colors/font_color', Color.DARK_RED)
			QuizGradeLabel.text = str(AnswerQuiz['quiz_grade'])


func _on_edit_student_pressed():
	var token_header = "Authorization: Token " + Token
	var headers = ["Content-Type: application/json", "Accept: application/json", token_header]
	var error = http_answered_quiz_request.request(base_url + "api/check-answer-quiz-by-teacher/" + str(AnswerQuiz['id']) + "/", headers, false, HTTPClient.METHOD_GET)
	if error != OK:
		push_error("An error ocurred in the HTTP request.")


func _http_answered_quiz_request_completed(result, response_code, headers, body):
	if result == http_answered_quiz_request.RESULT_SUCCESS:
		var json = JSON.new()
		json.parse(body.get_string_from_utf8())
		var response= json.get_data()
		var parent = find_parent("ListOfStudentAnswers")
		if parent:
			CheckQuestionInstantiate = preload("res://CheckQuestion/Standard/CheckQuestion.tscn").instantiate()
			parent.add_child(CheckQuestionInstantiate)
			CheckQuestionInstantiate.setup(response, Quiz, fullname(Student), Token)


func _on_give_min_score_pressed():
	var AnswerQuiz = {}
	AnswerQuiz["quiz_id"] = Quiz["id"]
	AnswerQuiz["student_id"] = Student['id']
	AnswerQuiz["subject"] =  Quiz["subject"]
	AnswerQuiz["score_obtained"] = 0
	AnswerQuiz["comments"] = ""
	AnswerQuiz["quiz_grade"] = Quiz['min_quiz_grade']
	AnswerQuiz["time_left"] = Quiz["ended_time"]
	AnswerQuiz["is_checked"] = true
	AnswerQuiz["create_by_teacher"] = true
	var token_header = "Authorization: Token " + Token
	var headers = ["Content-Type: application/json", "Accept: application/json", token_header]
	var body = JSON.stringify(AnswerQuiz)
	var error = http_create_answered_quiz_request.request(base_url + "api/check-answer-quiz-by-teacher/", headers, false, HTTPClient.METHOD_POST, body)
	if error != OK:
		push_error("An error ocurred in the HTTP request.")


func _http_create_answered_quiz_request_completed(result, response_code, headers, body):
	if result == http_answered_quiz_request.RESULT_SUCCESS:
		var json = JSON.new()
		json.parse(body.get_string_from_utf8())
		var response= json.get_data()
		var parent = find_parent("ListOfStudentAnswers")
		if parent:
			parent.setup(response['student'], Quiz, Token)


