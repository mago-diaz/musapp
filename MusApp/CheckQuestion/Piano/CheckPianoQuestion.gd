extends CenterContainer

var PianoAnswered
var PianoQuestion
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

	StudentAnswer = $VBoxContainer/Answer/Answer/PianoManager


func setup(piano_answered):
	Score = 0
	PianoAnswered = piano_answered
	PianoQuestion = piano_answered['question_id']
	NumberLabel.text = 'Pregunta #: ' + str(PianoQuestion['number']) 
	MaxScoreLabel.text = 'Puntaje máximo de la pregunta: ' + str(PianoQuestion['score'])
	QuestionLabel.set_text(str(PianoQuestion['question']))
	SpinScore.set_max(PianoQuestion['score'])
	_on_spin_score_value_changed(PianoAnswered['score'])
	if PianoAnswered['answer'] != {}:
		StudentAnswer.load_answer(PianoAnswered['answer'])


func _on_spin_score_value_changed(value):
	var parent = find_parent('CheckQuestion')
	if parent:
		parent.add_score(value - Score)
	Score = value
	SpinScore.set_value(Score)


func edit_answer():
	var NewScore = SpinScore.get_value()
	return {'question_id' : PianoQuestion['id'], 'answer' : {'score' : NewScore}}
