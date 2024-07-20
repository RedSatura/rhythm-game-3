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

##TODO implement whtever this is its late
var global_settings: Dictionary = {
	"theme": null,
	"theme_name": "light",
	#KEY BINDS
	"key_left_lane": null,
	"key_center_left_lane": null,
	"key_center_right_lane": null,
	"key_right_lane": null,
	"key_pause": null,
}

var game_data: Dictionary = {
	
}
