extends Control


var StudentList
var StudentOptionInstantiate

var QuizNameLabel
var TotalScore
var TotalQuestion
var EndedDate
var MinQuizGrade
var MaxQuizGrade
var Scale
var Token
var Quiz


func _ready():
	StudentList = $VBoxContainer/AnsweredContainer/Control/AnsweredListContainer/List
	QuizNameLabel = $VBoxContainer/CenterContainer2/Control2/QuizName
	TotalScore = $VBoxContainer/CenterContainer2/Control2/TotalScore
	TotalQuestion = $VBoxContainer/CenterContainer2/Control2/TotalQuestion
	EndedDate = $VBoxContainer/QuestionManager/HBoxContainer/EndedDate
	MinQuizGrade = $VBoxContainer/QuestionManager/HBoxContainer/MinQuizGrade
	MaxQuizGrade = $VBoxContainer/QuestionManager/HBoxContainer/MaxQuizGrade
	Scale = $VBoxContainer/QuestionManager/HBoxContainer/Scale
	


func setup(students_and_answers, quiz, token):
	for element in StudentList.get_children():
		StudentList.remove_child(element)
		element.queue_free()
	Quiz = quiz
	print(Quiz)
	Token = token
	QuizNameLabel.text = 'Evaluación: ' + Quiz['name']
	TotalScore.text = 'Puntaje Total: ' + str(Quiz['total_score'])
	TotalQuestion.text = 'Total de Preguntas: ' + str(Quiz['number_of_questions'])
	EndedDate.text = 'Fecha de Entrega: ' + str(Quiz['ended_date'])
	MinQuizGrade.text = 'Nota Mínima: ' + Quiz['min_quiz_grade']
	MaxQuizGrade.text = 'Nota Máxima: ' + Quiz['max_quiz_grade']
	Scale.text = 'Escala de evaluación: ' + str(Quiz['scale'].to_float() * 100) + '%'
	var SumOfScore = 0
	var NumberOfAnswer = 0
	
	for student_and_answer in students_and_answers:
		StudentOptionInstantiate = preload("res://Home/TeacherQuiz/CheckAnsweredQuiz.tscn").instantiate()
		StudentList.add_child(StudentOptionInstantiate)
		StudentOptionInstantiate.setup(student_and_answer, Quiz, Token)


func _on_save_pressed():
	queue_free()
