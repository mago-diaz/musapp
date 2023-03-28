extends Control

const base_url = "http://127.0.0.1:8000/"
var Token
var AnsweredQuiz

var http_answered_quiz_request

var ToFList
var SelectionList
var WrittingList
var PianoList
var MusicSheetList

var Quiz
var QuizName
var StudentName
var MaxScoreLabel 
var ScoreLabel

var CurrentIndex
var ListOfAnswersList

var MyQuizGrade
var MyScore
var TotalScore
var SendQuiz
var QuizSaved
var NoInternetConnection

var Response
var QuizGradeLabel
# Called when the node enters the scene tree for the first time.
func _ready():
	ToFList = $VBoxContainer/QuestionScreen/Control/ToFScroll/List
	SelectionList = $VBoxContainer/QuestionScreen/Control/SelectionScroll/List
	WrittingList = $VBoxContainer/QuestionScreen/Control/WrittingScroll/List
	PianoList = $VBoxContainer/QuestionScreen/Control/PianoScroll/List
	MusicSheetList = $VBoxContainer/QuestionScreen/Control/MusicSheetScroll/List

	QuizName = $VBoxContainer/Control/QuizNameLabel
	StudentName = $VBoxContainer/Control2/StudentName
	MaxScoreLabel = $VBoxContainer/Control2/MaxScore

	MaxScoreLabel = $VBoxContainer/Control2/MaxScore
	ScoreLabel = $VBoxContainer/Control2/Score
	QuizGradeLabel = $VBoxContainer/Control2/QuizGrade
	ListOfAnswersList = [$VBoxContainer/QuestionScreen/Control/ToFScroll,
						$VBoxContainer/QuestionScreen/Control/SelectionScroll,
						$VBoxContainer/QuestionScreen/Control/WrittingScroll,
						$VBoxContainer/QuestionScreen/Control/PianoScroll,
						$VBoxContainer/QuestionScreen/Control/MusicSheetScroll]
	SendQuiz = $SendQuizToServer 
	QuizSaved = $QuizSaved
	NoInternetConnection = $NoInternetConnection
						
	http_answered_quiz_request = HTTPRequest.new()
	add_child(http_answered_quiz_request)
	http_answered_quiz_request.connect('request_completed', self._http_answered_quiz_request_completed)


func setup(answered_quiz, quiz, stundent_name, token):
	Quiz = quiz
	CurrentIndex = 0
	AnsweredQuiz = answered_quiz['answered_quiz']
	MyScore = 0
	MyQuizGrade = AnsweredQuiz['quiz_grade']
	QuizName.text = 'Revision de Preguntas - ' + str(Quiz['name'])
	StudentName.text = 'Alumno : '+ str(stundent_name)
	MaxScoreLabel.text= 'Puntaje Total: ' + str(Quiz['total_score'])
	ScoreLabel.text = 'Puntaje Obtenido: ' + str(MyScore)
	QuizGradeLabel.text = 'Nota del alumno: ' + str(MyQuizGrade) 
	Token = token
	if 'tof_answered' in answered_quiz:
		for tof_answered in answered_quiz['tof_answered']:
			var AnswerInstantiate = preload("res://CheckQuestion/ToF/CheckToFQuestion.tscn").instantiate()
			ToFList.add_child(AnswerInstantiate)
			AnswerInstantiate.setup(tof_answered)
		
		for selection_answered in answered_quiz['selection_answered']:
			var AnswerInstantiate = preload("res://CheckQuestion/Selection/CheckSelectionQuestion.tscn").instantiate()
			SelectionList.add_child(AnswerInstantiate)
			AnswerInstantiate.setup(selection_answered)
		
		for writting_answered in answered_quiz['writting_answered']:
			var AnswerInstantiate = preload("res://CheckQuestion/Writting/CheckWrittingQuestion.tscn").instantiate()
			WrittingList.add_child(AnswerInstantiate)
			AnswerInstantiate.setup(writting_answered)
		
		for piano_answered in answered_quiz['piano_answered']:
			var AnswerInstantiate = preload("res://CheckQuestion/Piano/CheckPianoQuestion.tscn").instantiate()
			PianoList.add_child(AnswerInstantiate)
			AnswerInstantiate.setup(piano_answered)
		
		for music_sheet_answered in answered_quiz['music_sheet_answered']:
			var AnswerInstantiate = preload("res://CheckQuestion/MusicSheet/CheckMusicSheetQuestion.tscn").instantiate()
			MusicSheetList.add_child(AnswerInstantiate)
			AnswerInstantiate.setup(music_sheet_answered)


func add_score(new_score):
	MyScore += new_score
	ScoreLabel.text = 'Puntaje Obtenido: ' + str(MyScore)
	var quiz_scale = Quiz['scale'].to_float()
	var total_score = Quiz['total_score']
	var min_quiz_grade = Quiz['min_quiz_grade'].to_float()
	var aprobal_quiz_grade = Quiz['aprobal_quiz_grade'].to_float()
	var max_quiz_grade = Quiz['max_quiz_grade'].to_float()
	if MyScore < (total_score * quiz_scale):
		MyQuizGrade = ((aprobal_quiz_grade - min_quiz_grade) * (MyScore*1.0)/(quiz_scale * total_score)) + min_quiz_grade
	else:
		MyQuizGrade = ((max_quiz_grade - aprobal_quiz_grade) * (MyScore - (quiz_scale * total_score))/((1.0-quiz_scale)* total_score)) + aprobal_quiz_grade
	QuizGradeLabel.text = 'Nota del alumno: ' + str(MyQuizGrade).substr(0,4) 


func delete_element_from_list(List):
	for element in List.get_children():
		List.remove_child(element)
		element.queue_free()


func _on_cancel_pressed():
	delete_element_from_list(ToFList)
	delete_element_from_list(SelectionList)
	delete_element_from_list(WrittingList)
	delete_element_from_list(PianoList)
	delete_element_from_list(MusicSheetList)
	CurrentIndex = 0 
	queue_free()


func _on_select_question_item_selected(index):
	ListOfAnswersList[CurrentIndex].set_visible(false)
	CurrentIndex = index - 1
	ListOfAnswersList[CurrentIndex].set_visible(true)


func _on_save_pressed():
	var NewAnswerQuiz = {'score_obtained' : MyScore, 'quiz_grade' : str(MyQuizGrade).substr(0,4), 'is_checked' : true}
	var tof_amswers = []
	for element in ToFList.get_children():
		ToFList.remove_child(element)
		tof_amswers += [element.edit_answer()]
	
	var selection_answers = []
	for element in SelectionList.get_children():
		SelectionList.remove_child(element)
		selection_answers += [element.edit_answer()]
	
	var writting_answers = []
	for element in WrittingList.get_children():
		WrittingList.remove_child(element)
		writting_answers += [element.edit_answer()]
	
	var piano_answers = []
	for element in PianoList.get_children():
		PianoList.remove_child(element)
		piano_answers += [element.edit_answer()]
	
	var music_sheet_answers = []
	for element in MusicSheetList.get_children():
		MusicSheetList.remove_child(element)
		music_sheet_answers += [element.edit_answer()]
	
	var NewAnswer = {'answered_quiz' : NewAnswerQuiz, 'tof_answers' : tof_amswers, 'selection_answers' : selection_answers,
				'writting_answers' : writting_answers, 'piano_answers' : piano_answers, 'music_sheet_answers' : music_sheet_answers}
	
	var token_header = "Authorization: Token " + Token
	var headers = ["Content-Type: application/json", "Accept: application/json", token_header]
	var body = JSON.stringify(NewAnswer)
	var error = http_answered_quiz_request.request(base_url + "api/check-answer-quiz-by-teacher/" + str(AnsweredQuiz['id']) + "/", headers, false, HTTPClient.METHOD_PATCH, body)
	if error != OK:
		push_error("An error ocurred in the HTTP request.")
	SendQuiz.set_visible(true)


func _http_answered_quiz_request_completed(result, response_code, headers, body):
	if result == http_answered_quiz_request.RESULT_SUCCESS:
		var json = JSON.new()
		json.parse(body.get_string_from_utf8())
		var response= json.get_data()
		Response = response
		SendQuiz.set_visible(false)
		QuizSaved.set_visible(true)
	else:
		NoInternetConnection.set_visible(true)



func _on_go_to_pressed():
	var parent = find_parent("ListOfStudentAnswers")
	if parent:
		parent.setup(Response['student'], Quiz, Token)
		queue_free()
