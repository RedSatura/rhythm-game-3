extends Node

func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("back_to_title"):
		get_tree().change_scene_to_file("res://scenes/title/title_screen.tscn")
