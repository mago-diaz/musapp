extends CenterContainer

const base_url = "http://127.0.0.1:8000/"
var QuizLabel
var ScoreLabel
var TimeLabel
var TeacherLabel
var EndDateLabel

var QuizId
var Token 
var http_update_quiz_request

signal update_quizzes()


func _ready():
	QuizLabel = $VBoxContainer/VBoxContainer/QuizBox/QuizLabel
	ScoreLabel = $VBoxContainer/VBoxContainer2/ScoreBox/ScoreLabel
	TimeLabel = $VBoxContainer/VBoxContainer3/TimeBox/TimeLabel
	TeacherLabel = $VBoxContainer/VBoxContainer/TeacherBox/TeacherLabel
	EndDateLabel = $VBoxContainer/VBoxContainer2/EndDateBox/EndDateLabel
	
	http_update_quiz_request = HTTPRequest.new()
	add_child(http_update_quiz_request)
	http_update_quiz_request.connect("request_completed", self.http_update_quiz_request_completed)


func setup(Quiz, TeacherName, Token):
	QuizId = Quiz["id"]
	QuizLabel.text = Quiz["name"]
	ScoreLabel.text = str(Quiz["total_score"])
	TeacherLabel.text = TeacherName
	EndDateLabel.text = Quiz["ended_date"]
	var Hour = str(int(Quiz["ended_time"])/60)
	var Minute = str(int(Quiz["ended_time"])%60) if int(Quiz["ended_time"])%60 > 0 else "00"
	TimeLabel.text = Hour + ":" + Minute + " hrs"
	Token = Token


func _on_ended_quiz_pressed():
	var token_header = "Authorization: Token " + Token
	var headers = ["Content-Type: application/json", "Accept: application/json", token_header]
	var body = JSON.stringify({"is_active" : false, "is_ended" : true})
	var url = base_url + "api/teacher-quiz/" + str(QuizId) + "/"
	var error = http_update_quiz_request.request(url, headers, false, HTTPClient.METHOD_PATCH, body)


func http_update_quiz_request_completed(result, response_code, headers, body):
	if result == http_update_quiz_request.RESULT_SUCCESS:
		if response_code == 200:
			var json = JSON.new()
			json.parse(body.get_string_from_utf8())
			var response= json.get_data()
			print(response)
			var parent = find_parent("TeacherHome")
			if parent:
				update_quizzes.connect(parent.update_quizzes)
				emit_signal("update_quizzes")


