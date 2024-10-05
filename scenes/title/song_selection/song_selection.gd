extends Control

@onready var song_item_container: Node = $SongSelection/SongItemContainer
@onready var file_dialog: Node = $SongSelection/SongItemContainer/OpenCustomSong/FileDialog

var files: Array = []

var file_processing: bool = false
var custom_processing: bool = false

enum VisibilityState {
	VISIBLE,
	HIDDEN,
}

func _ready() -> void:
	SignalHandler.connect("song_validated", Callable(self, "song_validated"))
	SignalHandler.connect("send_user_song_file_paths", Callable(self, "process_file_paths"))
	SignalHandler.connect("set_song_selection_visibility", Callable(self, "set_visibility"))
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
						pass
					else:
						files.append(song_dir.get_current_dir() + "/" + song_file_name)
					
				song_file_name = song_dir.get_next()
		else:
			SignalHandler.emit_signal("send_error", "File accessing error.")
			break
		file_name = dir.get_next()
		
	SignalHandler.emit_signal("send_user_song_file_paths", files)

func process_file_paths(paths: Array) -> void:
	print(paths)
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
	elif custom_processing:
		get_tree().change_scene_to_file("res://scenes/stage/stage.tscn")


func _on_file_dialog_file_selected(path: String) -> void:
	custom_processing = true
	SignalHandler.emit_signal("send_song_to_validator", path)

func set_visibility(status: bool) -> void:
	if status:
		var tween: Tween = get_tree().create_tween()
		tween.tween_property(self, "position", Vector2(320, 64), 0.3).set_trans(Tween.TRANS_SINE)
		$SongSelection/SongItemContainer/Gateway.grab_focus()
	else:
		var tween: Tween = get_tree().create_tween()
		tween.tween_property(self, "position", Vector2(320, 720), 0.3).set_trans(Tween.TRANS_SINE)

func _on_minimize_pressed() -> void:
	SignalHandler.emit_signal("set_song_selection_visibility", false)


func _on_open_custom_song_pressed() -> void:
	file_dialog.popup()
