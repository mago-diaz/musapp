extends Control

const base_url = "http://127.0.0.1:8000/"
var NumberOfQuestions = 0 
var iQuestions = 1
var Quiz = {}
var StudentId = {}
var Questions = {}

var Answer = {}
var AnswerQuiz = {}
var AnsweredQuizId = null
var ToFAnswer = []
var SelectionAnswer = []
var WrittingAnswer = []
var PianoAnswer = []
var MusicSheetAnswer = []

var Token
var http_student_quiz_request
var http_student_answered_quiz

var NameQuestionLabel 
var QuestionLabel

var TimeLabel 
var Seconds = 0
var QuizUpdateTimer
var QuizEndTimer

signal update_quizzes()


func _ready():
	create_answered_quiz()
	QuizUpdateTimer = Timer.new()
	QuizUpdateTimer.set_wait_time(1)
	QuizUpdateTimer.timeout.connect(self.update_quiz_time)
	add_child(QuizUpdateTimer)
	QuizUpdateTimer.start()
	NameQuestionLabel = $VBoxContainer/NameQuestionContainer/NameQuestionLabel
	QuestionLabel = $VBoxContainer/Question/HBoxContainer/ScrollContainer/QuestionLabel
	TimeLabel = $VBoxContainer/HBoxContainer/HBoxContainer/TimeLabel
	QuizEndTimer = Timer.new()
	QuizEndTimer.timeout.connect(self._automatic_finish_quiz)
	add_child(QuizEndTimer)
	QuizEndTimer.set_wait_time(AnswerQuiz["time_left"] * 60)
	QuizEndTimer.start()
	get_time_from_time_left(AnswerQuiz["time_left"])
	setup_question()


func setup(CompleteQuiz, student, token):
	Token = token
	Quiz = CompleteQuiz
	StudentId = student["Id"]
	if 'tof_questions' in Quiz.keys() and len(Quiz['tof_questions']) > 0:
		for question in Quiz['tof_questions']:
			var answerInstantiate = preload("res://TypeOfQuestion/ToF/ToF.tscn").instantiate()
			Questions[str(question["number"])] = {'question' : question, 'type':  'tof_questions','answerInstantiate' : answerInstantiate, 'answer' : ''}
			NumberOfQuestions+=1
		
	if 'selection_questions' in Quiz.keys() and len(Quiz['selection_questions']) > 0:
		for question in Quiz['selection_questions']:
			var answerInstantiate = preload("res://TypeOfQuestion/Selection/Selection.tscn").instantiate()
			answerInstantiate.setup(question)
			Questions[str(question["number"])] = {'question' : question, 'type': 'selection_questions', 'answerInstantiate' : answerInstantiate, 'answer' : ''}
			NumberOfQuestions+=1
		
	if 'writting_questions' in Quiz.keys() and len(Quiz['writting_questions']) > 0:
		for question in Quiz['writting_questions']:
			var answerInstantiate = preload("res://TypeOfQuestion/Writing/Writting.tscn").instantiate()
			Questions[str(question["number"])] = {'question' : question, 'type': 'writting_questions', 'answerInstantiate' : answerInstantiate, 'answer' : ''}
			NumberOfQuestions+=1
			
	if 'piano_questions' in Quiz.keys() and len(Quiz['piano_questions']) > 0:
		for question in Quiz['piano_questions']:
			var answerInstantiate = preload("res://TypeOfQuestion/Piano/Piano.tscn").instantiate()
			answerInstantiate.setup(question)
			Questions[str(question["number"])] = {'question' : question, 'type': 'piano_questions', 'answerInstantiate' : answerInstantiate, 'answer' : {}}
			NumberOfQuestions+=1
	
	if 'music_sheet_questions' in Quiz.keys() and len(Quiz['music_sheet_questions']) > 0:
		for question in Quiz['music_sheet_questions']:
			var answerInstantiate = preload("res://TypeOfQuestion/MusicSheet/MusicSheet.tscn").instantiate()
			Questions[str(question["number"])] = {'question' : question, 'type': 'music_sheet_questions', 'answerInstantiate' : answerInstantiate, 'answer' : {}}
			NumberOfQuestions+=1
	AnswerQuiz = {}
	AnswerQuiz["quiz_id"] = Quiz["quiz"]["id"]
	AnswerQuiz["is_checked"] = false
	AnswerQuiz["create_by_teacher"] = false
	AnswerQuiz["student_id"] = StudentId
	AnswerQuiz["subject"] =  Quiz["quiz"]["subject"]
	AnswerQuiz["score_obtained"] = 0
	AnswerQuiz["comments"] = ""
	AnswerQuiz["quiz_grade"] = 1.0
	AnswerQuiz["time_left"] = Quiz["quiz"]["ended_time"]


func setup_question():
	var num = str(Questions[str(iQuestions)]['question']["number"])
	var question_text = Questions[str(iQuestions)]['question']['question']
	var type
	if Questions[str(iQuestions)]['type'] == 'tof_questions':
		type = "Verdadero y Falso"
	elif Questions[str(iQuestions)]['type'] == 'selection_questions':
		type = "Selección Múltiple"
	elif Questions[str(iQuestions)]['type'] == 'writting_questions':
		type = "Desarrollo"
	elif Questions[str(iQuestions)]['type'] == 'piano_questions':
		type = "Piano Virtual"
	elif Questions[str(iQuestions)]['type'] == 'music_sheet_questions':
		type = "Escritura de Partituras"
	NameQuestionLabel.text = "Pregunta Num " + num +" - Pregunta de " + type
	QuestionLabel.text = question_text
	$VBoxContainer/Answer.add_child(Questions[str(iQuestions)]['answerInstantiate'])


func _on_next_pressed():
	Questions[str(iQuestions)]['answer'] = Questions[str(iQuestions)]['answerInstantiate'].get_answer()
	if Questions[str(iQuestions)]['type'] == 'piano_questions' or Questions[str(iQuestions)]['type'] == 'music_sheet_questions':
		Questions[str(iQuestions)]['answerInstantiate'].stop_song()
	if Questions[str(iQuestions)]['type'] == 'piano_questions':
		Questions[str(iQuestions)]['answerInstantiate'].stop_all_notes()
	$VBoxContainer/Answer.remove_child(Questions[str(iQuestions)]['answerInstantiate'])
	iQuestions+=1
	while iQuestions <= NumberOfQuestions and not str(iQuestions) in Questions.keys():
		iQuestions+=1
	setup_question()
	if iQuestions == NumberOfQuestions :
		$VBoxContainer/Footer/HBoxContainer/Next.set_disabled(true)
		$VBoxContainer/Footer/HBoxContainer/Next.set_visible(false)
		
		$VBoxContainer/Footer/HBoxContainer/FinishQuiz.set_disabled(false)
		$VBoxContainer/Footer/HBoxContainer/FinishQuiz.set_visible(true)


func _on_previous_pressed():
	if Questions[str(iQuestions)]['type'] == 'piano_questions' or Questions[str(iQuestions)]['type'] == 'music_sheet_questions':
		Questions[str(iQuestions)]['answerInstantiate'].stop_song()
	if Questions[str(iQuestions)]['type'] == 'piano_questions':
		Questions[str(iQuestions)]['answerInstantiate'].stop_all_notes()
	$VBoxContainer/Answer.remove_child(Questions[str(iQuestions)]['answerInstantiate'])
	if iQuestions > 1:
		iQuestions-=1
	if iQuestions == NumberOfQuestions - 1:
		$VBoxContainer/Footer/HBoxContainer/Next.set_disabled(false)
		$VBoxContainer/Footer/HBoxContainer/Next.set_visible(true)
		
		$VBoxContainer/Footer/HBoxContainer/FinishQuiz.set_disabled(true)
		$VBoxContainer/Footer/HBoxContainer/FinishQuiz.set_visible(false)
		
	while iQuestions >= 1 and not str(iQuestions) in Questions.keys():
		iQuestions-=1
	setup_question()


func post_student_questions():
	QuizUpdateTimer.stop()
	QuizEndTimer.stop()
	http_student_quiz_request = HTTPRequest.new()
	add_child(http_student_quiz_request)
	http_student_quiz_request.connect("request_completed", self.http_student_quiz_request_completed)
	var token_header = "Authorization: Token " + Token
	var headers = ["Content-Type: application/json", "Accept: application/json", token_header]
	var body = JSON.stringify(Answer)
	print(Answer)
	var error = http_student_quiz_request.request(base_url + "api/student-answered-question/" + str(AnsweredQuizId) + "/", headers, false, HTTPClient.METHOD_POST, body)
	if error != OK:
		push_error("An error occurred in the HTTP request.")


func create_answered_quiz():
	http_student_answered_quiz = HTTPRequest.new()
	add_child(http_student_answered_quiz)
	http_student_answered_quiz.connect("request_completed", self.http_answered_quiz_request_completed)
	var token_header = "Authorization: Token " + Token
	var headers = ["Content-Type: application/json", "Accept: application/json", token_header]
	var body = JSON.stringify(AnswerQuiz)
	var error = http_student_answered_quiz.request(base_url + "api/student-quiz/", headers, false, HTTPClient.METHOD_POST, body)
	if error != OK:
		push_error("An error ocurred in the HTTP request.")


func get_time_from_time_left(time_left):
	var Hour = str(int(time_left)/60) if int(time_left)/60 > 9 else "0" + str(int(time_left)/60)
	var Minute = str(int(time_left)%60) if int(time_left)%60 > 9 else "0" + str(int(time_left)%60)
	var Second = str(Seconds) if Seconds > 9 else "0" + str(Seconds)
	if Hour == "00":
		if Minute < "30":
			TimeLabel.set("theme_override_colors/font_color", Color(0.95, 0, 0.16))
		else:
			TimeLabel.set("theme_override_colors/font_color", Color(0.99, 0.94, 0))
	TimeLabel.text = Hour + ":" + Minute + ":" + Second + "hrs"


func update_quiz_time():
	if Seconds == 0:
		Seconds = 59
		AnswerQuiz["time_left"] -= 1
		var token_header = "Authorization: Token " + Token
		var headers = ["Content-Type: application/json", "Accept: application/json", token_header]
		var body = JSON.stringify(AnswerQuiz)
		var error = http_student_answered_quiz.request(base_url + "api/student-quiz/" + str(AnsweredQuizId) + "/", headers, false, HTTPClient.METHOD_PATCH, body)
		if error != OK:
			push_error("An error ocurred in the HTTP request.")
	else:
		Seconds -= 1
	get_time_from_time_left(AnswerQuiz["time_left"])


func http_student_quiz_request_completed(result, response_code, headers, body):
	if result == http_student_quiz_request.RESULT_SUCCESS:
		if response_code == 200:
			var json = JSON.new()
			json.parse(body.get_string_from_utf8())
			var response= json.get_data()
			print(response)
			$SendQuizToServer.set_visible(false)
			$AutomaticSendQuizToServer.set_visible(false)
			$QuizSaved.set_visible(true)


func http_answered_quiz_request_completed(result, response_code, headers, body):
	if result == http_student_answered_quiz.RESULT_SUCCESS:
		if response_code == 200:
			var json = JSON.new()
			json.parse(body.get_string_from_utf8())
			var response = json.get_data()
			AnsweredQuizId = response["answered_quiz_id"]
			print("the time was update.")


func _on_finish_quiz_pressed():
	Questions[str(iQuestions)]['answer'] = Questions[str(iQuestions)]['answerInstantiate'].get_answer()
	if Questions[str(iQuestions)]['type'] == 'piano_questions' or Questions[str(iQuestions)]['type'] == 'music_sheet_questions':
		await Questions[str(iQuestions)]['answerInstantiate'].stop_song()
	$FinishQuizControl.set_visible(true)


func _automatic_finish_quiz():
	Questions[str(iQuestions)]['answer'] = Questions[str(iQuestions)]['answerInstantiate'].get_answer()
	if Questions[str(iQuestions)]['type'] == 'piano_questions' or Questions[str(iQuestions)]['type'] == 'music_sheet_questions':
		await Questions[str(iQuestions)]['answerInstantiate'].stop_song()
	$AutomaticSendQuizToServer.set_visible(true)
	save_answered_quesions()


func _on_back_pressed():
	$FinishQuizControl.set_visible(false)


func _on_save_evaluation_pressed():
	$FinishQuizControl.set_visible(false)
	$SendQuizToServer.set_visible(true)
	save_answered_quesions()


func save_answered_quesions():
	var NewAnswer
	var QuestionsId = 1 
	while QuestionsId <= NumberOfQuestions:
		NewAnswer = {}
		NewAnswer['question_id'] = Questions[str(QuestionsId)]['question']['id']
		NewAnswer['answer'] = Questions[str(QuestionsId)]['answer']
		if Questions[str(QuestionsId)]['type'] == 'tof_questions':
			ToFAnswer += [NewAnswer]
		elif Questions[str(QuestionsId)]['type'] == 'selection_questions':
			SelectionAnswer += [NewAnswer]
		elif Questions[str(QuestionsId)]['type'] == 'writting_questions':
			WrittingAnswer += [NewAnswer]
		elif Questions[str(QuestionsId)]['type'] == 'piano_questions':
			PianoAnswer += [NewAnswer]
		elif Questions[str(QuestionsId)]['type'] == 'music_sheet_questions':
			MusicSheetAnswer += [NewAnswer]
		QuestionsId += 1
	
	Answer = {}
	Answer['tof_answers'] = ToFAnswer
	Answer['selection_answers'] = SelectionAnswer
	Answer['writting_answers'] = WrittingAnswer
	Answer['piano_answers'] = PianoAnswer
	Answer['music_sheet_answers'] = MusicSheetAnswer
	post_student_questions()


func _on_go_to_pressed():
	var parent = find_parent("StudentHome")
	if parent:
		update_quizzes.connect(parent.update_quizzes)
		emit_signal("update_quizzes")
	queue_free()

