extends FileDialog

func _ready():
	set_use_native_dialog(false)

func _on_file_selected(path):
	GlobalData.song_path = path
	get_tree().change_scene_to_file("res://scenes/stage/stage.tscn")

func _on_open_file_pressed():
	popup()
