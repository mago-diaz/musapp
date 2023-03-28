extends CenterContainer

var Answer
var OptionsButton
var FalseOption
var Option
var TrueOption
var FalseOptionList
var QuestionNumberLabel
var QuestionNumber = 0
var OptionNumber = 1
var ShowButtonPressed = false

var Score = 0
const MaxNumberOption = 5

var QuestionCreated = {}

signal question_deleted(index)
signal update_score(score)

func _ready():
	
	OptionsButton = $VBoxContainer/CenterContainer/ShowOptions
	Answer = $VBoxContainer/Answer
	
	FalseOptionList = $VBoxContainer/Answer/FalseOptionMenu/FalseOptions
	FalseOption = preload("res://CreateQuestion/Selection/SelectionOption.tscn")
	
	QuestionNumberLabel = $VBoxContainer/Title/Label
	
	$VBoxContainer/InfoBox/MaxNumOption.set_text("Numero máximo de opciones : " + str(MaxNumberOption))
	
	TrueOption = $VBoxContainer/Answer/TrueOptionsMenu/TrueOptions/SelectionOption
	TrueOption.is_true_option()
	TrueOption.set_option_index(OptionNumber)
	OptionNumber+=1
	UpdateOptionNumber()
	var parent = find_parent("CreateListOfQuestion")
	if parent:
		question_deleted.connect(parent.question_deleted)
		update_score.connect(parent.update_score)
	
	
func UpdateOptionNumber():
	$VBoxContainer/InfoBox/OptionNum.set_text("Cantidad de opciones : "+str(OptionNumber-1))

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

func false_option_deleted(index):
	if OptionNumber > MaxNumberOption:
		$VBoxContainer/Answer/FalseOptionMenu/Control/FalseOptionButton.set_disabled(false)
		$VBoxContainer/Answer/FalseOptionMenu/Control/FalseOptionButton.set_text("Agregar Opcion")
	OptionNumber-=1
	UpdateOptionNumber()
	var CurrentFalseOptions = FalseOptionList.get_children()
	while index < len(CurrentFalseOptions):
		CurrentFalseOptions[index].set_option_index(index+1)
		index+=1
	for option in FalseOptionList.get_children():
		var CurrentIndex = option.get_option_index() 
		if CurrentIndex > index:
			option.set_option_index(CurrentIndex-1)

func _on_false_option_button_pressed():
	if OptionNumber <= MaxNumberOption:
		var newFalseOption = FalseOption.instantiate() 
		FalseOptionList.add_child(newFalseOption)
		newFalseOption.set_option_index(OptionNumber)
		OptionNumber+=1
		UpdateOptionNumber()
		
	if OptionNumber > MaxNumberOption: 
		$VBoxContainer/Answer/FalseOptionMenu/Control/FalseOptionButton.set_disabled(true)
		$VBoxContainer/Answer/FalseOptionMenu/Control/FalseOptionButton.set_text("Número máximo de opciones permitidas")


func get_question():
	QuestionCreated["Number"] = QuestionNumber
	QuestionCreated["TypeOfQuestion"] = "Selection"
	QuestionCreated["Question"] = $VBoxContainer/QuestionBox/TextEdit.get_text()
	QuestionCreated["CorrectAnswer"] = TrueOption.get_text()
	QuestionCreated["Options"] = []
	for option in FalseOptionList.get_children():
		QuestionCreated["Options"] += [option.get_text()]
	QuestionCreated["Options"] += [QuestionCreated["CorrectAnswer"]]
	randomize()
	QuestionCreated["Options"].shuffle()
	QuestionCreated["Score"] = Score
	return QuestionCreated

func _on_spin_box_value_changed(value):
	var PreviousScore = Score
	Score = value
	emit_signal("update_score", Score - PreviousScore)


func _on_show_options_pressed():
	ShowButtonPressed = not ShowButtonPressed
	if ShowButtonPressed:
		OptionsButton.text = "Desplegar Opciones"
	else:
		OptionsButton.text = "Ocultar Opciones (las opciones no serán eliminadas, solo dejarán de ser visibles)"
	Answer.set_visible(not ShowButtonPressed)
	
