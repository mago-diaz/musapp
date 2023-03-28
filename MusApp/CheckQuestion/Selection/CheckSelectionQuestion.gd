extends CenterContainer

var SelectionAnswered
var SelectionQuestion
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

	StudentAnswer = $VBoxContainer/Answer/HBoxContainer/StudentAnswer
	Result = $VBoxContainer/Answer/HBoxContainer2/Result


func setup(selection_answered):
	Score = 0
	SelectionAnswered = selection_answered
	SelectionQuestion = SelectionAnswered['question_id']
	NumberLabel.text = 'Pregunta #: ' + str(SelectionQuestion['number']) 
	MaxScoreLabel.text = 'Puntaje máximo de la pregunta: ' + str(SelectionQuestion['score'])
	QuestionLabel.set_text(str(SelectionQuestion['question']))
	SpinScore.set_max(SelectionQuestion['score'])
	_on_spin_score_value_changed(SelectionAnswered['score'])
	if SelectionAnswered['answer'] != null:
		StudentAnswer.text =  SelectionAnswered['answer']
		if SelectionQuestion['correct_answer'] == SelectionAnswered['answer']:
			_on_spin_score_value_changed(SelectionQuestion['score'])
			Result.text = 'Correcta'
		else:
			Result.text = 'Incorrecta, la respuesta correcta es: ' + SelectionQuestion['correct_answer']
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
	return {'question_id' : SelectionQuestion['id'], 'answer' : {'score' : NewScore}}
