extends VBoxContainer

signal Delete(index)

func false_option_deleted(index):
	emit_signal("Delete", index)


