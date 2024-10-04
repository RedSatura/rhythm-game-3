extends Button

@export_file var song_path: String = ""
@export var song_title: String = ""
@export var song_artist: String = ""
@export var song_difficulty: int = 5

@onready var title_label: Node = $SongTitle
@onready var artist_label: Node = $ArtistName
@onready var difficulty_label: Node = $Difficulty

func _ready() -> void:
	SignalHandler.connect("song_validated", Callable(self, "song_validated"))
	title_label.text = song_title
	artist_label.text = song_artist
	difficulty_label.text = "Difficulty: " + str(song_difficulty)

func _on_pressed() -> void:
	SignalHandler.emit_signal("send_song_to_validator", song_path)
	

func song_validated() -> void:
	SignalHandler.emit_signal("set_transition_status", false, "res://scenes/stage/stage.tscn")
