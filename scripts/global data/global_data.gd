extends Node

var song_path = ""

var song_info = { #defaults
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

var result_data = {
	"total_notes": 0,
	"perfect": 0,
	"good": 0,
	"miss": 0,
}
