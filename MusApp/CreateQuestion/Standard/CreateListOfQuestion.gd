extends Control

const base_url = "http://127.0.0.1:8000/"
var ScreenQuestions
var CurrentScreenQuestionId = 0

var AnswersToQuestions

var InfoToQuestions
var LabelInfoToQuestion

var CurrentNumberOfQuestion = 0
var TotalScore = 0
var LabelScore
var LabelTotalQuestion

var Test

var QuizName
var Teacher = {}
var MinQuizGrade
var AprobalQuizGrade
var MaxQuizGrade
var Scale
var Date
var time
var Token

var http_teacher_quiz_request

var CompleteQuiz
var CurrentSubject = {}


signal update_quizzes()

func _ready():
	ScreenQuestions = [$VBoxContainer/QuestionScreen/Control/ToFScroll,
						$VBoxContainer/QuestionScreen/Control/SelectionScroll,
						$VBoxContainer/QuestionScreen/Control/WrittingScroll,
						$VBoxContainer/QuestionScreen/Control/PianoScroll,
						$VBoxContainer/QuestionScreen/Control/MusicSheetScroll]
	AnswersToQuestions = [preload("res://CreateQuestion/ToF/CQToF.tscn"),
							preload("res://CreateQuestion/Selection/CQSelection.tscn"),
							preload("res://CreateQuestion/Writting/CQWritting.tscn"),
							preload("res://CreateQuestion/Piano/CQPiano.tscn"),
							preload("res://CreateQuestion/MusicSheet/CQMusicSheet.tscn")]
							
	InfoToQuestions = ["Estas preguntas serán corregidas automáticamente, solo tienes que elegir en 'Selecciona opcion correcta' si la pregunta es verdadera o falsa",
						"Estas preguntas serán corregidas automáticamente, el alumno verá las opciones desordenadas",
						"El alumno escribirá un pequeño texto para responder este tipo de pregunta",
						"El alumno dispondrá de un piano virtual para poder responder estas preguntas, podrás revisar su respuesta viendo el piano y reproduciendo lo que el alumno tocó",
						"El alumno tendrá que escribir una partitura para poder responder estas preguntas, podrás revisar su respuesta leyendo y reproduciendo lo que el alumno escribió"]
	
	LabelInfoToQuestion = $VBoxContainer/InfoScreen/Label
	LabelTotalQuestion = $VBoxContainer/Control2/TotalQuestion
	LabelTotalQuestion.text = "Total de Preguntas: " + CurrentNumberOfQuestion
	
	for ScreenQuestion in ScreenQuestions:
		var hscroll = ScreenQuestion.get_v_scroll_bar()
		hscroll.changed.connect(self.change_size)

	
func setup(NewQuizName, Teacher, MinQuizGrade, AprobalQuizGrade, MaxQuizGrade, Scale, Subject, NewDate, NewTime, token):
	QuizName = NewQuizName
	Teacher = Teacher
	MinQuizGrade = MinQuizGrade
	AprobalQuizGrade = AprobalQuizGrade
	MaxQuizGrade = MaxQuizGrade
	Scale = Scale
	CurrentSubject = Subject
	Date = NewDate
	time = NewTime
	var QuizLabel = $VBoxContainer/Control/QuizNameLabel
	var TeacherLabel = $VBoxContainer/Control2/TeacherName
	var DateLabel = $VBoxContainer/Control2/DateLabel
	QuizLabel.text = "Creacion de Preguntas - " + QuizName
	TeacherLabel.text = "Profesor: " + Teacher["FullName"]
	DateLabel.text = "Fecha: " + Date
	
	var MinQuizGradeLabel = $VBoxContainer/Control3/MinQuizGrade
	var AprobalQuizGradeLabel = $VBoxContainer/Control3/AprobalQuizGrade
	var MaxQuizGradeLabel = $VBoxContainer/Control3/MaxQuizGrade
	var ScaleLabel = $VBoxContainer/Control3/Scale
	MinQuizGradeLabel.text = 'Nota Mínima:' + str(MinQuizGrade * 1.0)
	AprobalQuizGradeLabel.text = 'Nota de Aprobación: ' + str(AprobalQuizGrade * 1.0)
	MaxQuizGradeLabel.text = 'Nota Máxima: ' + str(MaxQuizGrade * 1.0)
	ScaleLabel.text = 'Escala de Evaluación: ' + str(Scale * 100) + '%'
	
	Token = token
	

func _on_add_question_pressed():
	CurrentNumberOfQuestion+=1
	var currentList = ScreenQuestions[CurrentScreenQuestionId].get_node("List")
	var newQuestion = AnswersToQuestions[CurrentScreenQuestionId].instantiate()
	currentList.add_child(newQuestion)
	newQuestion.set_number(CurrentNumberOfQuestion)
	LabelTotalQuestion.text = "Total de Preguntas: " + str(CurrentNumberOfQuestion)
	

func question_deleted(index):
	for ScreenQuestion in ScreenQuestions:
		for child in ScreenQuestion.get_node("List").get_children():
			if child.get_number() > index:
				child.set_number(child.get_number()-1)
	CurrentNumberOfQuestion-=1
	LabelTotalQuestion.text = "Total de Preguntas: " + str(CurrentNumberOfQuestion)


func _on_select_question_item_selected(index):
	ScreenQuestions[CurrentScreenQuestionId].set_visible(false)
	CurrentScreenQuestionId = index - 1
	ScreenQuestions[CurrentScreenQuestionId].set_visible(true)
	LabelInfoToQuestion.set_text(InfoToQuestions[CurrentScreenQuestionId])


func _on_save_pressed():
	var Test = []
	var hasErrors = false
	var ErrorsComments = ""
	for ScreenQuestion in ScreenQuestions:
		for child in ScreenQuestion.get_node("List").get_children():
			var NewQuestion = child.get_question()
			if NewQuestion["Question"] == "":
				hasErrors = true
				ErrorsComments += "Error en la Pregunta " + str(NewQuestion["Number"]) + ": El texto no puede estar vacío \n" 
			if len(NewQuestion["Question"]) > 500:
				hasErrors = true
				ErrorsComments += "Error en la Pregunta " + str(NewQuestion["Number"]) + ": El texto no puede superar las 500 palabras\n" 
			if NewQuestion["TypeOfQuestion"] == "TOF" and NewQuestion["CorrectAnswer"] == null:
				hasErrors = true
				ErrorsComments += "Error en la Pregunta " + str(NewQuestion["Number"]) + ": Debes seleccionar la respuesta correcta \n" 
			elif NewQuestion["TypeOfQuestion"] == "Selection":
				if NewQuestion["CorrectAnswer"] == "":
					hasErrors = true
					ErrorsComments += "Error en la Pregunta " + str(NewQuestion["Number"]) + ": Debes escribir la respuesta correcta \n" 
				if len(NewQuestion["Options"]) <= 1:
					hasErrors = true
					ErrorsComments += "Error en la Pregunta " + str(NewQuestion["Number"]) + ": Debes crear respuestas incorrectas \n" 
				else:
					for option in NewQuestion["Options"]:
						if option == "":
							hasErrors = true
							ErrorsComments += "Error en la Pregunta " + str(NewQuestion["Number"]) + ": No puedes tener alternativa con texto vacío \n" 
			if NewQuestion["Score"] == 0:
				hasErrors = true
				ErrorsComments += "Error en la Pregunta " + str(NewQuestion["Number"]) + ": Debes asignarle un Puntaje mayor a 0 \n" 
			Test += [NewQuestion]
	if Test == []:
		hasErrors = true
		ErrorsComments += "Error: Debes tener al menos una pregunta"
	if hasErrors:
		$Errors.set_visible(true)
		var ErrorLabel = $Errors/CenterContainer/VBoxContainer/Control/ScrollContainer/ErrorList
		ErrorLabel.text = ErrorsComments
	else:
		var QuizDictionary = {}
		QuizDictionary["name"] = QuizName
		QuizDictionary["teacher_id"] = Teacher["Id"]
		QuizDictionary["subject"] = CurrentSubject["Id"]
		QuizDictionary["is_active"] = false
		QuizDictionary["is_ended"] = false
		QuizDictionary['min_quiz_grade'] = MinQuizGrade
		QuizDictionary['aprobal_quiz_grade'] = AprobalQuizGrade
		QuizDictionary['max_quiz_grade'] = MaxQuizGrade
		QuizDictionary['scale'] = Scale
		QuizDictionary["total_score"] = TotalScore
		QuizDictionary["ended_date"] = Date
		QuizDictionary["ended_time"] = time
		QuizDictionary["number_of_questions"] = len(Test)
		CompleteQuiz = {}
		CompleteQuiz["quiz"] = QuizDictionary
		CompleteQuiz["questions"] = Test
		post_teacher_quiz()
		$SendQuizToServer.set_visible(true)

func update_score(score): 
	TotalScore+=score
	LabelScore = $VBoxContainer/Control2/TotalScore
	LabelScore.text = "Puntaje Total: " + str(TotalScore)


func _on_cancel_pressed():
	queue_free()


func _on_error_accept_pressed():
	$Errors.set_visible(false)
	var ErrorLabel = $Errors/CenterContainer/VBoxContainer/Control/ScrollContainer/ErrorList
	ErrorLabel.text = ""


func post_teacher_quiz():
	http_teacher_quiz_request = HTTPRequest.new()
	add_child(http_teacher_quiz_request)
	http_teacher_quiz_request.connect("request_completed", self._http_request_completed)
	var token_header = "Authorization: Token " + Token
	var headers = ["Content-Type: application/json", "Accept: application/json", token_header]
	var body = JSON.stringify(CompleteQuiz)
	var error = http_teacher_quiz_request.request(base_url + "api/teacher-quiz/", headers, false, HTTPClient.METHOD_POST, body)
	if error != OK:
		push_error("An error occurred in the HTTP request.")


func _http_request_completed(result, response_code, headers, body):
	if result == http_teacher_quiz_request.RESULT_SUCCESS:
		if response_code == 200:
			var json = JSON.new()
			json.parse(body.get_string_from_utf8())
			var response= json.get_data()
			print(response)
			$SendQuizToServer.set_visible(false)
			$QuizSaved.set_visible(true)


func _on_go_to_pressed():
	var parent = find_parent("TeacherHome")
	if parent:
		update_quizzes.connect(parent.update_quizzes)
		emit_signal("update_quizzes")
	queue_free()


func change_size():
	var hscroll = ScreenQuestions[CurrentScreenQuestionId].get_v_scroll_bar()
	var max_value = hscroll.get_max()
	ScreenQuestions[CurrentScreenQuestionId].set_v_scroll(max_value)
