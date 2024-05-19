extends Node2D

##TODO: Make song validator take over the work of file checking

@export_file var file_path = ""

var file = ""
var line_content = ""

var song_title = ""

@onready var conductor = $Conductor
@onready var note_lanes = $NoteLanes

var disabled = false

func _ready():
	SignalHandler.connect("beat_occured", Callable(self, "get_next_commands"))
	
func open_song_file(path):
	file = FileAccess.open(path, FileAccess.READ)
	line_content = ""
	while line_content != "SONG_START":
		line_content = file.get_line()
	
func start_song():
	conductor.stream = AudioStreamOggVorbis.load_from_file(GlobalData.song_info["audio_src"])
	conductor.bpm = GlobalData.song_info["bpm"]
	conductor.beat_mode = GlobalData.song_info["beat_mode"]
	conductor.beats_in_measure = GlobalData.song_info["beats_in_measure"]
	conductor.starting_beat_in_measure = GlobalData.song_info["starting_beat_in_measure"]
	open_song_file(GlobalData.song_path)
	if !disabled:
		conductor.play_song()
		
func end_song():
	var tween = get_tree().create_tween()
	tween.tween_property(conductor, "volume_db", -80, 5)
	tween.connect("finished", Callable(self, "stop_song"))
	
func stop_song():
	conductor.stop()
	get_tree().change_scene_to_file("res://scenes/title/title_screen.tscn")
	
func get_next_commands(_beat_pos):
	line_content = file.get_line().strip_edges()
	if line_content == "SONG_END":
		end_song()
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
