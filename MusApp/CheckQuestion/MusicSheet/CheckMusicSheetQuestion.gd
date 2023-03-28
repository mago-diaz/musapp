extends CenterContainer

var MusicSheetAnswered
var MusicSheetQuestion
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

	StudentAnswer = $VBoxContainer/Answer/Answer/MusicSheet



func setup(music_sheet_answered):
	Score = 0
	MusicSheetAnswered = music_sheet_answered
	MusicSheetQuestion = music_sheet_answered['question_id']
	NumberLabel.text = 'Pregunta #: ' + str(MusicSheetQuestion['number']) 
	MaxScoreLabel.text = 'Puntaje máximo de la pregunta: ' + str(MusicSheetQuestion['score'])
	QuestionLabel.set_text(str(MusicSheetQuestion['question']))
	SpinScore.set_max(MusicSheetQuestion['score'])
	_on_spin_score_value_changed(MusicSheetAnswered['score'])
	if MusicSheetAnswered['answer'] != {}:
		StudentAnswer.load_answer(MusicSheetAnswered['answer'])


func _on_spin_score_value_changed(value):
	var parent = find_parent('CheckQuestion')
	if parent:
		parent.add_score(value - Score)
	Score = value
	SpinScore.set_value(Score)


func edit_answer():
	var NewScore = SpinScore.get_value()
	return {'question_id' : MusicSheetQuestion['id'], 'answer' : {'score' : NewScore}}
