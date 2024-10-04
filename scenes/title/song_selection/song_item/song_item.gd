extends Button

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

func _on_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/stage/stage.tscn")
