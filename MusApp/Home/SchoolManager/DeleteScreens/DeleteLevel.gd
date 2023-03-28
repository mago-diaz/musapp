extends Control

const base_url = "http://127.0.0.1:8000/"
var http_request_level
var Level
var LevelLabel
var GradesLabel
var Token

var DeleteLevel
var Deleting
var LevelDeleted
var DeleteLevelLabel

func _ready():
	LevelLabel = $Deleted/CenterContainer/DeleteBox/Level
	GradesLabel = $Deleted/CenterContainer/DeleteBox/Grades
	DeleteLevel = $Deleted/CenterContainer/DeleteBox
	Deleting = $Deleted/CenterContainer/Deleting
	LevelDeleted = $Deleted/CenterContainer/LevelDeleted
	DeleteLevelLabel = $Deleted/CenterContainer/LevelDeleted/Label
	
	http_request_level = HTTPRequest.new()
	add_child(http_request_level)
	http_request_level.connect('request_completed', self._http_request_level_completed)


func setup(level, grades_name, token):
	Level = level
	LevelLabel.text = 'Estas seguro de eliminar el curso : ' + Level['number'] + ' ' + Level['type']
	GradesLabel.text = 'Y las letras: ' + grades_name
	Token = token

func open():
	set_visible(true)
	DeleteLevel.set_visible(true)
	Deleting.set_visible(false)
	LevelDeleted.set_visible(false)


func _on_back_pressed():
	Level = null
	LevelLabel.text = ''
	GradesLabel.text = ''
	Token = null
	set_visible(false)


func _on_delete_level_pressed():
	DeleteLevel.set_visible(false)
	Deleting.set_visible(true)
	var token_header = "Authorization: Token " + Token
	var headers = ["Content-Type: application/json", "Accept: application/json", token_header]
	var error = http_request_level.request(base_url + "api/levels-and-grades/" + str(Level['id']) + "/", headers, false, HTTPClient.METHOD_DELETE)
	if error != OK:
		push_error("An error ocurred in the HTTP request.")
	


func _http_request_level_completed(result, response_code, headers, body):
	if result == http_request_level.RESULT_SUCCESS:
		if response_code == 200:
			var json = JSON.new()
			json.parse(body.get_string_from_utf8())
			var response = json.get_data()
			DeleteLevelLabel.text = response['message']
			Deleting.set_visible(false)
			LevelDeleted.set_visible(true)


func _on_exit_pressed():
	Level = null
	LevelLabel.text = ''
	GradesLabel.text = ''
	Token = null
	set_visible(false)
	var parent = get_parent()
	if parent:
		parent.get_school_admin_profile()
