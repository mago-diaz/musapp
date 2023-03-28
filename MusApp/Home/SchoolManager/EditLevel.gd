extends CenterContainer

var LevelName
var Level
var GradesName

var LevelLabel
var GradesLabel

var EditScreen
var DeleteScreen
var Token

func _ready():
	LevelLabel = $VBoxContainer/VBoxContainer/LevelBox/LevelLabel
	GradesLabel = $VBoxContainer/VBoxContainer/LevelBox/GradesLabel


func setup(level, edit_screen, delete_screen, token):
	Level = level
	LevelName = Level['number'] + ' ' + Level['type']
	GradesName = ''
	for grade in Level['grades']:
		if grade == Level['grades'][-1]:
			GradesName += grade['letter']
		else:
			GradesName += grade['letter'] + ' - '
	LevelLabel.text = LevelName
	GradesLabel.text = GradesName
	EditScreen = edit_screen
	DeleteScreen = delete_screen
	Token = token


func get_name():
	return LevelName


func _on_edit_level_pressed():
	EditScreen.setup(Level, false, Token)
	EditScreen.open()


func _on_delete_level_pressed():
	DeleteScreen.setup(Level, GradesName, Token)
	DeleteScreen.open()
