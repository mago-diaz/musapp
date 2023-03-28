extends CenterContainer


var ToFAnswered
var ToFQuestion
var NumberLabel
var MaxScoreLabel
var SpinScore
var QuestionLabel

var StudentAnswer
var Result

var Score

# Called when the node enters the scene tree for the first time.
func _ready():
	NumberLabel = $VBoxContainer/Title/Label
	MaxScoreLabel = $VBoxContainer/Title/Control/HBoxContainer/MaxScoreLabel
	SpinScore = $VBoxContainer/Title/Control/HBoxContainer/SpinScore
	QuestionLabel = $VBoxContainer/QuestionBox/QuestionLabel

	StudentAnswer = $VBoxContainer/Answer/StudentAnswer
	Result = $VBoxContainer/Answer/Result


func setup(tof_answered):
	Score = 0
	ToFAnswered = tof_answered
	ToFQuestion = ToFAnswered['question_id']
	NumberLabel.text = 'Pregunta #: ' + str(ToFQuestion['number']) 
	MaxScoreLabel.text = 'Puntaje máximo de la pregunta: ' + str(ToFQuestion['score'])
	QuestionLabel.set_text(str(ToFQuestion['question']))
	SpinScore.set_max(ToFQuestion['score'])
	_on_spin_score_value_changed(ToFAnswered['score'])
	if ToFAnswered['answer'] != null:
		if ToFAnswered['answer'] == 'true':
			StudentAnswer.text = 'Verdadero'
		elif ToFAnswered['answer'] == 'false':
			StudentAnswer.text = 'Falso'
		
		if str(ToFQuestion['correct_answer']) ==  ToFAnswered['answer']:
			_on_spin_score_value_changed(ToFQuestion['score'])
			Result.text = 'Correcta'
		else:
			var correct_answer = ''
			if ToFQuestion['correct_answer']:
				correct_answer = 'Verdadero'
			else:
				correct_answer = 'Falso'
			Result.text = 'Incorrecta, la respuesta correcta es: ' + correct_answer
	else:
		StudentAnswer.text = 'No Respondió'


func _on_spin_score_value_changed(value):
	var parent = find_parent('CheckQuestion')
	if parent:
		parent.add_score(value - Score)
	Score = value
	SpinScore.set_value(Score)


func edit_answer():
	var NewScore = SpinScore.get_value()
	return {'question_id' : ToFQuestion['id'], 'answer' : {'score' : NewScore}}
