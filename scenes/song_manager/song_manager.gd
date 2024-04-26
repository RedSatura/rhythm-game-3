extends Node2D

@export_file var file_path = ""

var file = ""
var line_content = ""

@onready var conductor = $Conductor

func _ready():
	SignalHandler.connect("beat_occured", Callable(self, "get_next_commands"))
	if FileAccess.file_exists(file_path):
		open_file()

func open_file():
	file = FileAccess.open(file_path, FileAccess.READ)
	while line_content != "SONG_START":
		line_content = file.get_line().strip_edges()
	
func start_song():
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
			var _parameter_result = parameter_regex.search_all(x.get_string())
			
			match type_result:
				"s":
					pass
				_:
					pass
