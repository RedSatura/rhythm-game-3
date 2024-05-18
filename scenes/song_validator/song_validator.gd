extends Node2D

var file_path = "" #needed for audio_src, may fix it later

var line_content = "" #The content of the currently active line in the song file.

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

func _ready():
	SignalHandler.connect("send_song_to_validator", Callable(self, "validate_song"))
	
func validate_song(path): #This is where song validation begins
	check_file_existence(path)
	
func check_file_existence(path): #Step 1: Checking file existence
	if FileAccess.file_exists(path):
		file_path = path
		open_file(path)
	else:
		SignalHandler.emit_signal("send_error", "File does not exist!")
		
func open_file(path): #Step 2: Opening file
	var file = null
	file = FileAccess.open(path, FileAccess.READ)
	if file != null:
		#lmao i spent ages on a bug just to add this one line
		#apparently line content is set at SONG_START at the end, so you need to reset it for it to work again
		line_content = "" 
		var start_command_found = false
		#Gets the song metadata type
		#Ex. Gets SONG_TITLE from SONG_TITLE: Test Song
		var metadata_type_regex = RegEx.new()
		metadata_type_regex.compile(".*?(?=\\:)")
		for x in 20: #Number means starting lines checked
			if line_content != "SONG_START":
				line_content = file.get_line().strip_edges()
				var result = metadata_type_regex.search(line_content)
				if result != null:
					process_song_metadata_type(result.get_string().strip_edges())
			else:
				start_command_found = true
				break
		if !start_command_found:
			SignalHandler.emit_signal("send_error", "Song starting command not found before 20 lines.")
		else:
			pass
	else:
		SignalHandler.emit_signal("send_error", "Error opening file!")
	file.close()
		
func process_song_metadata_type(type): #Step 3: Getting data from headers
	var metadata_data_regex = RegEx.new()
	metadata_data_regex.compile("(?<=\\:).*")
	var result = metadata_data_regex.search(line_content)
	
	if result != null:
		result = result.get_string().strip_edges()
		
		match type:
			#Chart metadata:
			"TITLE":
				song_info["title"] = str(result)
			"ARTIST":
				song_info["artist"] = str(result)
			"MAPCREATOR":
				song_info["mapcreator"] = str(result)
			"DIFFICULTY":
				song_info["difficulty"] = int(result)
			#Paths for files:
			"AUDIO_SRC":
				var audio_path = file_path.get_base_dir() + "/" + result
				if FileAccess.file_exists(audio_path):
					song_info["audio_src"] = audio_path
				else:
					SignalHandler.emit_signal("send_error", "Invalid audio path!")
					return
			#Song-related types:
			"BPM":
				if int(result) <= 0:
					SignalHandler.emit_signal("send_error", "BPM was invalid, so it has been set to 100.")
					song_info["bpm"] = 100
				else:
					song_info["bpm"] = int(result)
			"BEAT_MODE":
				if int(result) <= 0:
					SignalHandler.emit_signal("send_error", "Beat mode was invalid, so it has been set to 1.")
					song_info["beat_mode"] = 1
				else:
					song_info["beat_mode"] = int(result)
			"BEATS_IN_MEASURE":
				if int(result) <= 0:
					SignalHandler.emit_signal("send_error", "Beats in measure was invalid, so it has been set to 4.")
					song_info["beats_in_measure"] = 4
				else:
					song_info["beats_in_measure"] = int(result)
			"STARTING_BEAT_IN_MEASURE":
				if int(result) <= 0:
					SignalHandler.emit_signal("send_error", "Starting beat in measure was invalid, so it has been set to 1.")
					song_info["starting_beat_in_measure"] = 1
				else:
					song_info["starting_beat_in_measure"] = int(result)
			_:
				pass
				
func validate_song_body(): #Step 4: Validating song body and checking for SONG_END
	pass
