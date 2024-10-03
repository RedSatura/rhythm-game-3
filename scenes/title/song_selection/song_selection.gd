extends Control

@onready var song_item_container: Node = $SongSelection/SongItemContainer

var files: Array = []

var file_processing: bool = false

func _ready() -> void:
	SignalHandler.connect("song_validated", Callable(self, "song_validated"))
	SignalHandler.connect("send_user_song_file_paths", Callable(self, "process_file_paths"))
	check_songs()
	
func check_songs() -> void:
	#thanks hiulit and RedwanFox
	#https://gist.github.com/hiulit/772b8784436898fd7f942750ad99e33e
	var user_dir: DirAccess = DirAccess.open("user://")
	if !user_dir.dir_exists("user://songs"):
		user_dir.make_dir("user://songs")
		
	var dir: DirAccess = DirAccess.open("user://songs")
	dir.list_dir_begin()
	
	var file_name: String = dir.get_next()
	
	while file_name != "":
		if dir.current_is_dir():
			var song_dir: DirAccess = DirAccess.open("user://songs/" + file_name)
			song_dir.list_dir_begin()
			
			var song_file_name: String = song_dir.get_next()
			
			while song_file_name != "":
				if song_dir.current_is_dir():
					pass
				else:
					if song_file_name.get_extension() != "msf":
						song_file_name = song_dir.get_next()
					else:
						files.append(song_dir.get_current_dir() + "/" + song_file_name)
						song_file_name = song_dir.get_next()
					
				song_file_name = song_dir.get_next()
		else:
			SignalHandler.emit_signal("send_error", "File accessing error.")
		file_name = dir.get_next()
		
	SignalHandler.emit_signal("send_user_song_file_paths", files)

func process_file_paths(paths: Array) -> void:
	for path: String in paths:
		if FileAccess.file_exists(path):
			read_file(path)
		else:
			continue

func read_file(path: String) -> void:
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if file != null:
		file_processing = true
		SignalHandler.emit_signal("send_song_to_validator", path)

func song_validated() -> void:
	if file_processing:
		var new_song_item: Node = load("res://scenes/title/song_selection/song_item/song_item.tscn").instantiate()
		new_song_item.song_path = GlobalData.song_path
		new_song_item.song_title = GlobalData.song_info["title"]
		new_song_item.song_artist = GlobalData.song_info["artist"]
		new_song_item.song_difficulty = GlobalData.song_info["difficulty"]
		song_item_container.add_child(new_song_item)
		file_processing = false

func _on_open_custom_song_gui_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("click"):
		pass
