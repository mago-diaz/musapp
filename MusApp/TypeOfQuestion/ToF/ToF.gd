extends Control

var Answer = ''


func get_answer():
	return Answer


func _on_option_button_item_selected(index):
	Answer = str(index == 1)
