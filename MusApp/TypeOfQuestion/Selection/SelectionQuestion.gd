extends Control

var OptionSelection  = preload("res://TypeOfQuestion/Selection/QSelection.tscn")
var Answer = ''

func setup(Question):
	for element in Question['options']:
		var OptionSelectionInstantiate = OptionSelection.instantiate()
		OptionSelectionInstantiate.setup(element, self)
		$CenterContainer/Container/CenterContainer/VBoxContainer.add_child(OptionSelectionInstantiate)

func set_answer(Text):
	Answer = Text
	if Answer != "":
		for element in $CenterContainer/Container/CenterContainer/VBoxContainer.get_children():
			if element.get_text() != Answer:
				element.button_up()
	print(Answer)

func get_answer():
	return Answer
