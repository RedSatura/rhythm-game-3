extends Node2D

@export_file var file_path = ""

var file = ""
var line_content = ""

@onready var conductor = $Conductor
@onready var note_lanes = $NoteLanes

var disabled = false

func _ready():
	SignalHandler.connect("beat_occured", Callable(self, "get_next_commands"))
	if FileAccess.file_exists(file_path):
		open_file()
	else:
		SignalHandler.emit_signal("send_error", "File does not exist!")

func open_file():
	file = FileAccess.open(file_path, FileAccess.READ)
	var start_command_found = false
	for x in 20:
		if line_content != "SONG_START":
			line_content = file.get_line().strip_edges()
		else:
			start_command_found = true
			break
			
	if !start_command_found:
		disabled = true
		SignalHandler.emit_signal("send_error", "Starting song command not found after 20 lines.")
	
func start_song():
	if !disabled:
		conductor.play_song()
	
func get_next_commands(_beat_pos):
	line_content = file.get_line().strip_edges()
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
