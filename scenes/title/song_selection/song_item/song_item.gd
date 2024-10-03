extends Control

@export_file var song_path: String = ""
@export var song_name: String = ""
@export var song_artist: String = ""
@export var song_difficulty: int = 5

@onready var name_label: Node = $SongName
@onready var artist_label: Node = $ArtistName
@onready var difficulty_label: Node = $Difficulty

func _ready() -> void:
	name_label.text = song_name
	artist_label.text = song_artist
	difficulty_label.text = "Difficulty: " + str(song_difficulty)

func _on_panel_gui_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("click"):
		pass
