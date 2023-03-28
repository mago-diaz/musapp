extends Control

var Answer = ''

func get_answer():
	return Answer


func _on_text_edit_text_changed():
	Answer = $VBoxContainer/TextEdit.text
