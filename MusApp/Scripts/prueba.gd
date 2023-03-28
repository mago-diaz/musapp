extends Node2D


var c4
var d4
var e4
var f4
var g4
var a4 
var b4
var c5
# Called when the node enters the scene tree for the first time.
func _ready():
	var note = preload("res://Classes/Notes.gd")
	c4 = note.new("C4")
	d4 = note.new("D4")
	e4 = note.new("E4")
	f4 = note.new("F4")
	g4 = note.new("G4")
	a4 = note.new("A4")
	b4 = note.new("B4")
	c5 = note.new("C5")
	add_child(c4)
	add_child(d4)
	add_child(e4)
	add_child(f4)
	add_child(g4)
	add_child(a4)
	add_child(b4)
	add_child(c5)
	var p = 99
	var i = int(p * 1000)
	var mask = 0
	mask += i
	var a = 1
	var b = 6
	
	mask += (a << 17)
	mask += (b << 20)
	print(mask)
	print(mask & 131071)
	print((mask & (7 << 17)) >> 17)
	print((mask & (7 << 20)) >> 20)		
	var pulse = 1.0
	await c4.play_figure("QV", pulse)
	await d4.play_figure("QV", pulse)
	await e4.play_figure("CR", pulse)
	await g4.play_figure("CR", pulse)
	await e4.play_figure("CR", pulse)
	await d4.play_figure("CR", pulse)
	await c4.play_figure("MN", pulse)
	await c4.play_figure("CR", pulse)
	await e4.play_figure("QV", pulse)
	await g4.play_figure("QV", pulse)
	await a4.play_figure("CR", pulse)
	await c5.play_figure("CR", pulse)
	await b4.play_figure("CR", pulse)
	await g4.play_figure("CR", pulse)
	await e4.play_figure("CRd", pulse)
	await f4.play_figure("SQ", pulse)
	await e4.play_figure("SQ", pulse)
	await d4.play_figure("CR", pulse)

func _input(event):
	if event.is_action_pressed("C"):
		c4.play()
	if event.is_action_released("C"):
		c4.stop()
	if event.is_action_pressed("D"):
		d4.play()
	if event.is_action_released("D"):
		d4.stop()
	if event.is_action_pressed("E"):
		e4.play()
	if event.is_action_released("E"):
		e4.stop()
	if event.is_action_pressed("F"):
		f4.play()
	if event.is_action_released("F"):
		f4.stop()
	if event.is_action_pressed("G"):
		g4.play()
	if event.is_action_released("G"):
		g4.stop()
	if event.is_action_pressed("A"):
		a4.play()
	if event.is_action_released("A"):
		a4.stop()
	if event.is_action_pressed("B"):
		b4.play()
	if event.is_action_released("B"):
		b4.stop()
	if event.is_action_pressed("C5"):
		c5.play()
	if event.is_action_released("C5"):
		c5.stop()
