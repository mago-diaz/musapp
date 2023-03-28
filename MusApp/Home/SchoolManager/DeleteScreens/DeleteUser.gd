extends Control

const base_url = "http://127.0.0.1:8000/"
var http_request_user
var User = null
var UserLabel
var Token = null

var DeleteUser
var Deleting
var UserDeleted
var DeletedUserLabel

func _ready():
	DeletedUserLabel = $Deleted/CenterContainer/UserDeleted/Label
	UserLabel = $Deleted/CenterContainer/DeleteBox/Label
	DeleteUser = $Deleted/CenterContainer/DeleteBox
	Deleting = $Deleted/CenterContainer/Deleting
	UserDeleted = $Deleted/CenterContainer/UserDeleted
	
	http_request_user = HTTPRequest.new()
	add_child(http_request_user)
	http_request_user.connect('request_completed', self._http_request_user_completed)


func setup(user, token):
	User = user
	var userName = User['first_name'] + ' ' + User['middle_name'] + ' ' + User['last_name'] + ' ' + User['mothers_maiden_name']
	UserLabel.text = "Estas seguro que quieres eliminar a: " + userName
	Token = token


func open():
	set_visible(true)
	DeleteUser.set_visible(true)
	Deleting.set_visible(false)
	UserDeleted.set_visible(false)


func _on_delete_user_pressed():
	DeleteUser.set_visible(false)
	Deleting.set_visible(true)
	if User['type'] == 'TEACHER':
		var token_header = "Authorization: Token " + Token
		var headers = ["Content-Type: application/json", "Accept: application/json", token_header]
		var error = http_request_user.request(base_url + "api/teacher-profile/" + str(User['id']) + "/", headers, false, HTTPClient.METHOD_DELETE)
		if error != OK:
			push_error("An error ocurred in the HTTP request.")
	elif User['type'] == 'STUDENT':
		var token_header = "Authorization: Token " + Token
		var headers = ["Content-Type: application/json", "Accept: application/json", token_header]
		var error = http_request_user.request(base_url + "api/student-profile/" + str(User['id']) + "/", headers, false, HTTPClient.METHOD_DELETE)
		if error != OK:
			push_error("An error ocurred in the HTTP request.")


func _http_request_user_completed(result, response_code, headers, body):
	if result == http_request_user.RESULT_SUCCESS:
		if response_code == 200:
			var json = JSON.new()
			json.parse(body.get_string_from_utf8())
			var response = json.get_data()
			DeletedUserLabel.text = response['message']
			Deleting.set_visible(false)
			UserDeleted.set_visible(true)


func _on_exit_pressed():
	User = null
	UserLabel.text = ''
	DeletedUserLabel.text = ''
	Token = null
	set_visible(false)
	var parent = get_parent()
	if parent:
		parent.get_school_admin_profile()


func _on_back_pressed():
	User = null
	UserLabel.text = ''
	DeletedUserLabel.text = ''
	Token = null
	set_visible(false)
