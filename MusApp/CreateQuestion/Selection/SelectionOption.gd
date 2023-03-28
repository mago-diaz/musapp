extends Control

var DeleteButton
var OptionIndex = 0

signal Delete(index)

func _ready():
	DeleteButton = $HBoxContainer/Delete
	var parent = get_parent()
	if parent:
		Delete.connect(parent.false_option_deleted)
		
func get_option_index():
	return OptionIndex
	
func is_true_option():
	DeleteButton.set_visible(false)
	
func set_option_index(index):
	OptionIndex = index
	$HBoxContainer/Label.set_text("Opcion #: "+str(OptionIndex))

func get_text():
	return $HBoxContainer/LineEdit.get_text()


func _on_delete_pressed():
	var parent = get_parent()
	if parent:
		parent.remove_child(self)
		queue_free()
	emit_signal("Delete", OptionIndex)
	
