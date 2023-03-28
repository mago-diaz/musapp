extends CenterContainer

var Score = 0
var QuestionCreated = {}
var QuestionNumberLabel
var QuestionNumber

signal question_deleted(index)
signal update_score(score)

func _ready():
	QuestionNumberLabel = $VBoxContainer/Title/Label
	var parent = find_parent("CreateListOfQuestion")
	if parent:
		question_deleted.connect(parent.question_deleted)
		update_score.connect(parent.update_score)


func get_number():
	return QuestionNumber


func set_number(index):
	QuestionNumber = index
	QuestionNumberLabel.text = "Pregunta #: " + str(QuestionNumber)


func _on_delete_pressed():
	emit_signal("question_deleted", QuestionNumber)
	emit_signal("update_score", Score * -1)
	var parent = get_parent()
	if parent:
		parent.remove_child(self)
		queue_free()


func get_question():
	QuestionCreated["Number"] = QuestionNumber
	QuestionCreated["TypeOfQuestion"] = "MusicSheet"
	QuestionCreated["Question"] = $VBoxContainer/QuestionBox/TextEdit.get_text()
	QuestionCreated["Score"] = Score
	QuestionCreated["Rubric"] = ''
	return QuestionCreated


func _on_spin_box_value_changed(value):
	var PreviousScore = Score
	Score = value
	emit_signal("update_score", Score - PreviousScore)
