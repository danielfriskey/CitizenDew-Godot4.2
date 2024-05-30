class_name PauseMenu extends CanvasLayer

const pause_menu:PackedScene = preload("res://menus/pause_menu.tscn")

@onready var resume: Button = $Panel/HBoxContainer/VBoxContainer/Resume
@onready var save_and_quit: Button = $Panel/HBoxContainer/VBoxContainer/SaveAndQuit

func _process(_delta):
	if Input.is_action_just_pressed("ui_cancel"):
		queue_free()

func _on_resume_pressed():
	queue_free()

func _on_save_and_quit_pressed():
	Global.save_game()
	get_tree().quit()

func _notification(what):
	if what == NOTIFICATION_ENTER_TREE:
		get_tree().paused = true
	elif what == NOTIFICATION_EXIT_TREE:
		get_tree().paused = false
