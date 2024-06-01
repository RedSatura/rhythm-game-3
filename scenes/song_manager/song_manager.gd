extends Node2D

@export_file var file_path = ""
@export var auto_mode = false
@export var in_editor = false

var file = ""
var line_content = ""

var song_title = ""

@onready var conductor = $Conductor
@onready var note_lanes = $NoteLanes

@onready var song_start_timer = $SongStartTimer

var disabled = false

var current_line_in_file = 0

func _ready():
	SignalHandler.connect("beat_occured", Callable(self, "process_beat"))
	note_lanes.set_note_lane_auto_mode(auto_mode)
	if !in_editor:
		song_start_timer.start()
	
func start_song():
	setup_file()
	if FileAccess.file_exists(GlobalData.song_info["audio_src"]):
		conductor.stream = AudioStreamOggVorbis.load_from_file(GlobalData.song_info["audio_src"])
	conductor.bpm = GlobalData.song_info["bpm"]
	conductor.beat_mode = GlobalData.song_info["beat_mode"]
	conductor.beats_in_measure = GlobalData.song_info["beats_in_measure"]
	conductor.starting_beat_in_measure = GlobalData.song_info["starting_beat_in_measure"]
	if !disabled && conductor.stream:
		conductor.play_song()
		SignalHandler.emit_signal("send_message", "Playing!")
		
func setup_file():
	if in_editor:
		file = null
		file = FileAccess.open(GlobalData.song_path, FileAccess.READ)
		for x in current_line_in_file:
			file.get_line() #no need to use strip_edges since it isn't used anyway
	else:
		file = FileAccess.open(GlobalData.song_path, FileAccess.READ)
		for x in 20:
			line_content = file.get_line()
			current_line_in_file += 1
			if line_content == "SONG_START":
				break
		
func end_song():
	var tween = get_tree().create_tween()
	tween.tween_property(conductor, "volume_db", -80, 5)
	tween.connect("finished", Callable(self, "stop_song"))
	return
	
func stop_song():
	conductor.stop()
	conductor.stream = null
	if !in_editor:
		get_tree().change_scene_to_file("res://scenes/title/title_screen.tscn")
	current_line_in_file = 0
	
func get_next_commands(_beat_pos):
	line_content = file.get_line().strip_edges()
	current_line_in_file += 1
	if line_content == "SONG_END":
		SignalHandler.emit_signal("send_message", "Song ended.")
		end_song()
		return
	get_commands()

func get_commands():
	var regex = RegEx.new()
	regex.compile("[^,]+?(?=\\,)")
	var result = regex.search_all(line_content)
	process_commands(result)
	
func process_commands(commands):
	if commands != [] && commands != null:
		for x in commands:
			#Get command type
			var type_regex = RegEx.new()
			type_regex.compile(".(?=\\/)")
			var type_result = type_regex.search(x.get_string()).get_string()
			
			#Get command parameters
			var parameter_regex = RegEx.new()
			parameter_regex.compile("(?<=\\/).*?(?=\\+)|(?<=\\+).*?(?=\\+)|(?<=\\+).*?(?=\\,)")
			var parameter_result = parameter_regex.search_all(x.get_string())

			match type_result:
				"d":	#Disable note lane.
					#Parameters:
					#Note lane number (int) - 1 for left, 2 for center left, 3 for center right, 4 for right.
					#Duration (int) - Number of beats to disable.
					if parameter_result != [] && parameter_result != null:
						if parameter_result.size() == 2:
							var cached_params = [] #stores parameters
							for y in parameter_result: #get and convert parameters
								cached_params.push_back(int(y.get_string()))
							note_lanes.disable_lane(cached_params[0], cached_params[1])
						else:
							SignalHandler.emit_signal("send_error", "Too few or too many parameters!")
				"s":	#Spawn note.
					#Parameters:
					#Note lane number (int) - 1 for left, 2 for center left, 3 for center right, 4 for right.
					#You can use r for random note placement.
					#This has a delay depending on the note speed.
					if parameter_result != [] && parameter_result != null:
						if parameter_result.size() == 1:
							var current_param = 1
							for y in parameter_result:
								match current_param:
									1:	#Param 1: Spawns note on numbered lane.
										var value = y.get_string().strip_edges()
										if value == "r":	#Random notes
											note_lanes.spawn_note_on_lane(value)
										else:
											note_lanes.spawn_note_on_lane(int(value))
											break
									_:
										break
						else:
							SignalHandler.emit_signal("send_error", "Too few or too many parameters!")
				_:
					SignalHandler.emit_signal("send_error", "Unrecognized command type.")
	else:
		pass
		
func process_beat(pos):
	get_next_commands(pos)

func _on_song_start_timer_timeout():
	start_song()
