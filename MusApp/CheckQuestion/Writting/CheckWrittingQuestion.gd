extends CenterContainer

var WrittingAnswered
var WrittingQuestion
var NumberLabel
var MaxScoreLabel
var SpinScore
var QuestionLabel

var StudentAnswer
var Score

func _ready():
	NumberLabel = $VBoxContainer/Title/Label
	MaxScoreLabel = $VBoxContainer/Title/Control/HBoxContainer/MaxScoreLabel
	SpinScore = $VBoxContainer/Title/Control/HBoxContainer/SpinScore
	QuestionLabel = $VBoxContainer/QuestionBox/QuestionLabel

	StudentAnswer = $VBoxContainer/Answer/StudentAnswer


func setup(writting_answered):
	Score = 0
	WrittingAnswered = writting_answered
	WrittingQuestion = WrittingAnswered['question_id']
	NumberLabel.text = 'Pregunta #: ' + str(WrittingQuestion['number']) 
	MaxScoreLabel.text = 'Puntaje máximo de la pregunta: ' + str(WrittingQuestion['score'])
	QuestionLabel.set_text(str(WrittingQuestion['question']))
	SpinScore.set_max(WrittingQuestion['score'])
	_on_spin_score_value_changed(WrittingAnswered['score'])
	if WrittingAnswered['answer'] != null:
		StudentAnswer.set_text(WrittingAnswered['answer'])
	else:
		StudentAnswer.set_text('No Respondió')


func _on_spin_score_value_changed(value):
	var parent = find_parent('CheckQuestion')
	if parent:
		parent.add_score(value - Score)
	Score = value
	SpinScore.set_value(Score)


func edit_answer():
	var NewScore = SpinScore.get_value()
	return {'question_id' : WrittingQuestion['id'], 'answer' : {'score' : NewScore}}

