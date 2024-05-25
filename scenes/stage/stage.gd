extends Node2D

@onready var song_manager = $SongManager

var song_path = ""

func _ready():
	pass

func _on_button_pressed():
	get_tree().change_scene_to_file("res://scenes/title/title_screen.tscn")

func _on_song_start_timer_timeout():
	song_manager.start_song()

func _on_pause_button_pressed():
	if get_tree().paused:
		get_tree().paused = false
	else:
		get_tree().paused = true
