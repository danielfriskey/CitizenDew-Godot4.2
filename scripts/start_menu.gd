extends CanvasLayer

func _on_start_new_pressed():
	Global.delete_save_data()
	Global.load_save_data("create")
	get_tree().change_scene_to_file("res://scenes/game.tscn")

func _on_load_pressed():
	Global.load_save_data("load")
	get_tree().change_scene_to_file("res://scenes/game.tscn")

func _on_quit_pressed():
	get_tree().quit()
