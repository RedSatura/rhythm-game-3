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
	"image_src": "",
	"video_src": "",
	#file-specific properties
	"video_offset": 0.0,
	#song-related information
	"bpm": 100,
	"beat_mode": 1,
	"beats_in_measure": 4,
	"starting_beat_in_measure": 1,
}

var global_settings: Dictionary = {
	#Display
	"theme": load("res://styles/default_theme.tres"),
	"theme_name": "light",
	"fullscreen": true,
	#Key binds
	"key_lane_left_1": 68,
	"key_lane_center_left_1": 70,
	"key_lane_center_right_1": 74,
	"key_lane_right_1": 75,
	"key_switch_effect_1": 0,
	"key_select_effect_1": 0,
	"key_lane_left_2": 68,
	"key_lane_center_left_2": 70,
	"key_lane_center_right_2": 74,
	"key_lane_right_2": 75,
	"key_switch_effect_2": 0,
	"key_select_effect_2": 0,
	"key_pause": 80,
	"key_restart": 82,
	#Audio settings
	"master_volume": 1.0, 
	#Gameplay settings
	"scroll_speed": 1.0,
	"upscroll": false
}

var game_settings: Dictionary = {
	"cpu_difficulty": 98,
	"cpu_1_active": false,
	"cpu_2_active": false,
	"cpu_1_difficulty": 0,
	"cpu_2_difficulty": 0,
	"gamemode": "singleplayer",
}
