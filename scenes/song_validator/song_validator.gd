extends Node2D

@export var highlighting_color: Color = Color.LIGHT_PINK

var file_path: String = "" #needed for audio_src, may fix it later

var line_content: String = "" #The content of the currently active line in the song file.

var default_song_info: Dictionary = { #defaults
	#metadata
	"title": "",
	"artist": "",
	"mapcreator": "",
	"difficulty": 0,
	#paths for files
	"audio_src": "",
	"image_src": "",
	"video_src": "",
	#file-related properties
	"video_offset": 0,
	#song-related information
	"bpm": 100,
	"beat_mode": 1,
	"beats_in_measure": 4,
	"starting_beat_in_measure": 1,
}

var song_info: Dictionary = {}

var current_line_in_file: int = 0

var audio_src_valid: bool = false

func _ready() -> void:
	SignalHandler.connect("send_song_to_validator", Callable(self, "validate_song"))
	song_info = default_song_info
	GlobalData.song_path = ""
	
func validate_song(path: String) -> void: #This is where song validation begins
	check_file_existence(path)
	
func check_file_existence(path: String) -> void: #Step 1: Checking file existence
	if FileAccess.file_exists(path):
		file_path = path
		GlobalData.song_path = path
		open_file(path)
	else:
		GlobalData.song_path = ""
		SignalHandler.emit_signal("send_error", "File does not exist!")
		return
		
func open_file(path: String) -> void: #Step 2: Opening file
	var file: FileAccess = null
	file = FileAccess.open(path, FileAccess.READ)
	if file != null:
		#lmao i spent ages on a bug just to add this one line
		#apparently line content is set at SONG_START at the end, so you need to reset it for it to work again
		line_content = "" 
		current_line_in_file = 0
		#Gets the song metadata type
		#Ex. Gets SONG_TITLE from SONG_TITLE: Test Song
		var metadata_type_regex: RegEx = RegEx.new()
		metadata_type_regex.compile(".*?(?=\\:)")
		for x: int in 20: #Number means starting lines checked TODO: (i should fix this magic number)
			if line_content != "SONG_START":
				if x == 19: #TODO: wtf???
					SignalHandler.emit_signal("send_error", "Song starting command not found before 20 lines.")
					return
				SignalHandler.emit_signal("update_editor_line_color", current_line_in_file, highlighting_color)
				current_line_in_file += 1
				line_content = file.get_line().strip_edges()
				var result: RegExMatch = metadata_type_regex.search(line_content)
				if result != null:
					process_song_metadata_type(result.get_string().strip_edges())
		if !audio_src_valid:
			return
		validate_song_body(file)
	else:
		SignalHandler.emit_signal("send_error", "Error opening file!")
		return
		
func process_song_metadata_type(type: String) -> void: #Step 3: Getting data from headers
	var metadata_data_regex: RegEx = RegEx.new()
	metadata_data_regex.compile("(?<=\\:).*")
	var result: RegExMatch = metadata_data_regex.search(line_content)
	
	if result != null:
		var metadata_content: String = result.get_string().strip_edges()
		
		match type:
			#Chart metadata:
			"TITLE":
				song_info["title"] = str(metadata_content)
			"ARTIST":
				song_info["artist"] = str(metadata_content)
			"MAPCREATOR":
				song_info["mapcreator"] = str(metadata_content)
			"DIFFICULTY":
				song_info["difficulty"] = int(metadata_content)
			#Paths for files:
			"AUDIO_SRC":
				var audio_path: String = file_path.get_base_dir() + "/" + metadata_content
				if FileAccess.file_exists(audio_path):
					song_info["audio_src"] = audio_path
					audio_src_valid = true
				elif ResourceLoader.exists(audio_path):
					song_info["audio_src"] = audio_path
					audio_src_valid = true
				else: #why does this not work for some reason (EDIT: prob works now)
					audio_src_valid = false
					SignalHandler.emit_signal("send_error", "Invalid audio path! " + audio_path + " does not exist!")
					return
			"IMAGE_SRC":
				var image_path: String = file_path.get_base_dir() + "/" + metadata_content
				if FileAccess.file_exists(image_path):
					song_info["image_src"] = image_path
				elif ResourceLoader.exists(image_path):
					song_info["image_src"] = image_path
				else:
					pass
			"VIDEO_SRC":
				var video_path: String = file_path.get_base_dir() + "/" + metadata_content
				if FileAccess.file_exists(video_path):
					song_info["video_src"] = video_path
				elif ResourceLoader.exists(video_path):
					song_info["video_src"] = video_path
				else:
					pass
			#File-related properties:
			"VIDEO_OFFSET":
				song_info["video_offset"] = float(metadata_content)
			#Song-related types:
			"BPM":
				if int(metadata_content) <= 0:
					SignalHandler.emit_signal("send_error", "BPM was invalid, so it will be set to 100 when played.")
					song_info["bpm"] = 100
				else:
					song_info["bpm"] = int(metadata_content)
			"BEAT_MODE":
				if int(metadata_content) <= 0:
					SignalHandler.emit_signal("send_error", "Beat mode was invalid, so it will be set to 1 when played.")
					song_info["beat_mode"] = 1
				else:
					song_info["beat_mode"] = int(metadata_content)
			"BEATS_IN_MEASURE":
				if int(metadata_content) <= 0:
					SignalHandler.emit_signal("send_error", "Beats in measure was invalid, so it will be set to 4 when played.")
					song_info["beats_in_measure"] = 4
				else:
					song_info["beats_in_measure"] = int(metadata_content)
			"STARTING_BEAT_IN_MEASURE":
				if int(metadata_content) <= 0:
					SignalHandler.emit_signal("send_error", "Starting beat in measure was invalid, so it will be set to 1 when played.")
					song_info["starting_beat_in_measure"] = 1
				else:
					song_info["starting_beat_in_measure"] = int(metadata_content)
			_:
				pass
				
func validate_song_body(file: FileAccess) -> void: #Step 4: Validating song body and checking for SONG_END
	#Right now, it only checks for SONG_END, as any errors in the song body will just be ignored by the song manager.
	var end_command_found: bool = false
	while file.get_position() < file.get_length():
		line_content = file.get_line()
		if line_content == "SONG_END":
			end_command_found = true
			
	if !end_command_found:
		SignalHandler.emit_signal("send_error", "Song ending command not found.")
		return
	else:
		GlobalData.song_info = song_info
		SignalHandler.emit_signal("song_validated")
		SignalHandler.emit_signal("send_message", "Successfully validated!")
		return
		#The song information will be stored in the global script global_data.
		#Get the song info from there.
		
func get_validator_lines_processed() -> int:
	return current_line_in_file
