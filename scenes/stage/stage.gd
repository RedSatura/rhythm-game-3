extends Node2D

@onready var song_manager = $SongManager

func _ready():
	song_manager.start_song()
