extends CenterContainer

const base_url = "http://127.0.0.1:8000/"
var QuizLabel
var ScoreLabel
var TimeLabel
var TeacherLabel
var EndDateLabel

var ListOfStudentAnswerInstantiate
var OpenQuiz

var Quiz

var TeacherName
var Token 

var http_students_request
signal update_quizzes()


func _ready():
	QuizLabel = $VBoxContainer/VBoxContainer/QuizBox/QuizLabel
	ScoreLabel = $VBoxContainer/VBoxContainer2/ScoreBox/ScoreLabel
	TimeLabel = $VBoxContainer/VBoxContainer3/TimeBox/TimeLabel
	TeacherLabel = $VBoxContainer/VBoxContainer/TeacherBox/TeacherLabel
	EndDateLabel = $VBoxContainer/VBoxContainer2/EndDateBox/EndDateLabel
	http_students_request = HTTPRequest.new()
	add_child(http_students_request)
	http_students_request.connect('request_completed', self._http_students_request_completed)

func setup(quiz, teacher_name, token):
	TeacherName = teacher_name
	Quiz = quiz
	QuizLabel.text = Quiz["name"]
	ScoreLabel.text = str(Quiz["total_score"])
	TeacherLabel.text = TeacherName
	EndDateLabel.text = Quiz["ended_date"]
	var Hour = str(int(Quiz["ended_time"])/60)
	var Minute = str(int(Quiz["ended_time"])%60) if int(Quiz["ended_time"])%60 > 0 else "00"
	TimeLabel.text = Hour + ":" + Minute + " hrs"
	Token = token


func _on_see_answers_pressed():
	var token_header = "Authorization: Token " + Token
	var headers = ["Content-Type: application/json", "Accept: application/json", token_header]
	var error = http_students_request.request(base_url + "api/student-and-asnwers-by-quiz/" + str(Quiz['id']) + "/", headers, false, HTTPClient.METHOD_GET)

func _http_students_request_completed(result, response_code, headers, body):
	if result == http_students_request.RESULT_SUCCESS:
		var json = JSON.new()
		json.parse(body.get_string_from_utf8())
		var response= json.get_data()
		var parent = find_parent("TeacherHome")
		if parent:
			ListOfStudentAnswerInstantiate = preload("res://Home/TeacherQuiz/ListOfStudentAnswers/ListOfStudentAnswers.tscn").instantiate()
			parent.add_child(ListOfStudentAnswerInstantiate)
			ListOfStudentAnswerInstantiate.setup(response['student'], Quiz, Token)
		
