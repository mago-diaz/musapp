extends Control


func _on_exit_button_pressed():
	get_tree().quit()


func _on_no_conection_button_pressed():
	set_visible(false)
