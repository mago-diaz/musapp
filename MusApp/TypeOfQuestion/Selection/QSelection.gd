extends Control

var Text = ''
var Parent
signal correct_answer(text)


func setup(text, parent):
	Parent = parent
	Text = text
	$CheckBox.text = Text
	if Parent:
		correct_answer.connect(Parent.set_answer)


func get_text():
	return Text

func button_up():
	$CheckBox.set_pressed_no_signal(false)

func _on_check_box_toggled(button_pressed):
	if Parent:
		if button_pressed:
			emit_signal("correct_answer", Text)
		else:
			emit_signal("correct_answer", '')
