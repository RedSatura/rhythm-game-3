extends Node2D

@export_file var file_path: String = ""
@export var auto_mode: bool = false
@export var in_editor: bool = false

var file: FileAccess = null
var line_content: String = ""

var song_title: String = ""

@onready var conductor: Node = $Conductor

@onready var song_start_timer: Node = $SongStartTimer

@export var current_set_beat: int = 0

var disabled: bool = false

var command_processing_enabled: bool = false

var current_line_in_file: int = 0
var line_read_offset: int = 0

func _ready() -> void:
	SignalHandler.connect("update_starting_song_beat", Callable(self, "update_starting_song_beat"))
	SignalHandler.connect("beat_occured", Callable(self, "process_beat"))
	if !in_editor:
		song_start_timer.start()
	
func start_song() -> void:
	setup_file()
	#set note lane settings
	if in_editor:
		SignalHandler.emit_signal("set_note_lane_setting_auto_mode", true)
	
	if FileAccess.file_exists(GlobalData.song_info["audio_src"]):
		conductor.stream = AudioStreamOggVorbis.load_from_file(GlobalData.song_info["audio_src"])
	elif ResourceLoader.exists(GlobalData.song_info["audio_src"]):
		conductor.stream = ResourceLoader.load(GlobalData.song_info["audio_src"])
	conductor.bpm = GlobalData.song_info["bpm"]
	conductor.beat_mode = GlobalData.song_info["beat_mode"]
	conductor.beats_in_measure = GlobalData.song_info["beats_in_measure"]
	conductor.starting_beat_in_measure = GlobalData.song_info["starting_beat_in_measure"]
	if !disabled && conductor.stream:
		conductor.play_song()
		SignalHandler.emit_signal("send_message", "Playing!")
		SignalHandler.emit_signal("song_started")
		
func setup_file() -> void:
	if in_editor:
		file = null
		file = FileAccess.open(GlobalData.song_path, FileAccess.READ)
		for x: int in current_line_in_file:
			file.get_line() #no need to use strip_edges since it isn't used anyway
	else:
		file = FileAccess.open(GlobalData.song_path, FileAccess.READ)
		if file != null:
			for x: int in 20:
				line_content = file.get_line()
				current_line_in_file += 1
				if line_content == "SONG_START":
					break
		else:
			return
	
	for x: int in line_read_offset:
		file.get_line()
		current_line_in_file += 1
		
func end_song() -> void:
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(conductor, "volume_db", -80, 5)
	tween.connect("finished", Callable(self, "stop_song"))
	return
	
func stop_song() -> void:
	conductor.stop()
	conductor.stream = null
	SignalHandler.emit_signal("song_ended")
	current_line_in_file = 0
	#command_processing_enabled = false
	
func get_next_commands(_beat_pos: int) -> void:
	line_content = file.get_line().strip_edges()
	current_line_in_file += 1
	if line_content == "SONG_END":
		SignalHandler.emit_signal("send_message", "Song ended.")
		end_song()
		return
	get_commands()

func get_commands() -> void:
	var regex: RegEx = RegEx.new()
	regex.compile("[^,]+?(?=\\,)")
	var result: Array = regex.search_all(line_content)
	#if command_processing_enabled:
	process_commands(result)
	
func process_commands(commands: Array) -> void:
	if commands != [] && commands != null:
		for x: RegExMatch in commands:
			#Get command type
			var type_regex: RegEx = RegEx.new()
			type_regex.compile(".(?=\\/)")
			var type_matches: RegExMatch = type_regex.search(x.get_string())
			if type_matches == null:
				SignalHandler.emit_signal("send_error", "Match is null!")
				return
			var type_result: String = type_matches.get_string()
			#Get command parameters
			var parameter_regex: RegEx = RegEx.new()
			parameter_regex.compile("(?<=\\/).*?(?=\\+)|(?<=\\+).*?(?=\\+)|(?<=\\+).*?(?=\\,)")
			var parameter_result: Array = parameter_regex.search_all(x.get_string())

			match type_result:
				"d":	#Disable note lane.
					#Parameters:
					#Note lane number (int) - 1 for left, 2 for center left, 3 for center right, 4 for right.
					#Duration (int) - Number of beats to disable.
					if parameter_result != [] && parameter_result != null:
						if parameter_result.size() == 2:
							var cached_params: Array = [] #stores parameters
							for value: RegExMatch in parameter_result: #get and convert parameters
								cached_params.push_back(int(value.get_string()))
							SignalHandler.emit_signal("disable_lane", cached_params[0], cached_params[1])
						else:
							SignalHandler.emit_signal("send_error", "Too few or too many parameters!")
				"l": #Update the lyics
					#Parameters:
					#Text (String) - the text inside will be used to update the lyric label.
					if parameter_result != [] && parameter_result != null:
						if parameter_result.size() == 1:
							var cached_params: Array = [] #stores parameters
							for value: RegExMatch in parameter_result: #get and convert parameters
								cached_params.push_back(value.get_string())
							SignalHandler.emit_signal("update_lyric", cached_params[0])
						else:
							SignalHandler.emit_signal("send_error", "Too few or too many parameters!")
				"m": #Move a note lane.
					#Parameters:
					#Note lane number (int) - 1 for left, 2 for center left, 3 for center right, 4 for right.
					#Movement (int) - How much to move the lane. Positive values move the lane right and negative values do the opposite.
					#Duration (int) - Number of beats to disable.
					if parameter_result != [] && parameter_result != null:
						if parameter_result.size() == 3:
							var cached_params: Array = [] #stores parameters
							for value: RegExMatch in parameter_result: #get and convert parameters
								cached_params.push_back(int(value.get_string()))
							SignalHandler.emit_signal("move_lane", cached_params[0], cached_params[1], cached_params[2])
						else:
							SignalHandler.emit_signal("send_error", "Too few or too many parameters!")
				"s":	#Spawn note.
					#Parameters:
					#Note lane number (int) - 1 for left, 2 for center left, 3 for center right, 4 for right.
					#You can use 0 for random note placement.
					#This has a delay depending on the note speed.
					if parameter_result != [] && parameter_result != null:
						if parameter_result.size() == 1:
							var current_param: int = 1
							for value: RegExMatch in parameter_result:
								match current_param:
									1:	#Param 1: Spawns note on numbered lane.
										SignalHandler.emit_signal("spawn_note", int(value.get_string()))
										break
									_:
										break
						else:
							SignalHandler.emit_signal("send_error", "Too few or too many parameters!")
				_:
					SignalHandler.emit_signal("send_error", "Unrecognized command type.")
	else:
		pass
		
func process_beat(pos: int) -> void:
	get_next_commands(pos)
	#command_processing_enabled = true

func _on_song_start_timer_timeout() -> void:
	start_song()

func update_starting_song_beat(beat: int) -> void:
	conductor.beat_starting_position = beat
	line_read_offset = beat

func _on_conductor_finished() -> void:
	end_song()
