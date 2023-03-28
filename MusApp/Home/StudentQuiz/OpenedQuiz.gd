extends CenterContainer

const base_url = "http://127.0.0.1:8000/"
var QuizLabel
var ScoreLabel
var TimeLabel
var TeacherLabel
var EndDateLabel

var QuizId
var Token 

var http_quiz_request

signal answer_quiz(quiz)
signal continue_quiz(quiz)

func _ready():
	QuizLabel = $VBoxContainer/VBoxContainer/QuizBox/QuizLabel
	ScoreLabel = $VBoxContainer/VBoxContainer2/ScoreBox/ScoreLabel
	TimeLabel = $VBoxContainer/VBoxContainer3/TimeBox/TimeLabel 
	TeacherLabel = $VBoxContainer/VBoxContainer/TeacherBox/TeacherLabel
	EndDateLabel = $VBoxContainer/VBoxContainer2/EndDateBox/EndDateLabel
	
	http_quiz_request = HTTPRequest.new()
	add_child(http_quiz_request)
	http_quiz_request.connect("request_completed", self.http_quiz_request_completed)


func setup(Quiz, token):
	QuizId = Quiz['quiz']["id"]
	QuizLabel.text = Quiz['quiz']["name"]
	ScoreLabel.text = str(Quiz['quiz']["total_score"])
	TeacherLabel.text = Quiz['quiz']["teacher_id"]["first_name"] + " " + Quiz['quiz']["teacher_id"]["middle_name"] + " " + Quiz['quiz']["teacher_id"]["last_name"] + " " +Quiz['quiz']["teacher_id"]["mothers_maiden_name"]
	EndDateLabel.text = Quiz['quiz']["ended_date"]
	var Hour = str(int(Quiz['quiz']["ended_time"])/60)
	var Minute = str(int(Quiz['quiz']["ended_time"])%60) if int(Quiz['quiz']["ended_time"])%60 > 0 else "00"
	TimeLabel.text = Hour + ":" + Minute + " hrs"
	Token = token
	if Quiz['answer'] == null:
		$VBoxContainer/CenterContainer/AnswerQuiz.set_disabled(false)
	else:
		$VBoxContainer/CenterContainer/AnswerQuiz.set_disabled(true)
		$VBoxContainer/CenterContainer/AnswerQuiz.text = "Evaluación Respondida"


func _on_answer_quiz_pressed():
	var token_header = "Authorization: Token " + Token
	var headers = ["Content-Type: application/json", "Accept: application/json", token_header]
	var url = base_url + "api/student-quiz/" + str(QuizId) + "/"
	var error = http_quiz_request.request(url, headers, false, HTTPClient.METHOD_GET)


func http_quiz_request_completed(result, response_code, headers, body):
	if result == http_quiz_request.RESULT_SUCCESS:
		if response_code == 200:
			var json = JSON.new()
			json.parse(body.get_string_from_utf8())
			var response= json.get_data()
			var parent = find_parent("StudentHome")
			if parent:
				answer_quiz.connect(parent.answer_quiz)
				emit_signal("answer_quiz", response)


