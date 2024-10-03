extends Control

@export_file var song_path: String = ""
@export var song_title: String = ""
@export var song_artist: String = ""
@export var song_difficulty: int = 5

@onready var title_label: Node = $SongTitle
@onready var artist_label: Node = $ArtistName
@onready var difficulty_label: Node = $Difficulty

func _ready() -> void:
	title_label.text = song_title
	artist_label.text = song_artist
	difficulty_label.text = "Difficulty: " + str(song_difficulty)

func _on_panel_gui_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("click"):
		get_tree().change_scene_to_file("res://scenes/stage/stage.tscn")
