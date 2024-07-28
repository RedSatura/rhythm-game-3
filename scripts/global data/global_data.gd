extends Node

var song_path: String = ""

var song_info: Dictionary = { #defaults
	#metadata
	"title": "",
	"artist": "",
	"mapcreator": "",
	"difficulty": 0,
	#paths for files
	"audio_src": "",
	#song-related information
	"bpm": 100,
	"beat_mode": 1,
	"beats_in_measure": 4,
	"starting_beat_in_measure": 1,
}

var global_settings: Dictionary = {
	"theme": load("res://styles/default_theme.tres"),
	"theme_name": "light",
	#Key binds
	"key_lane_left": 68,
	"key_lane_center_left": 70,
	"key_lane_center_right": 74,
	"key_lane_right": 75,
	"key_pause": 80,
	#Audio settings
	"master_volume": 100, 
}
