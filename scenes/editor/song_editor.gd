extends Node2D

@onready var code_edit = $CodeEdit
@onready var file_dialog = $FileDialog
@onready var song_manager = $SongManager

@onready var open_button = $Open
@onready var save_button = $Save

@onready var status_label = $StatusLabel

var file = null
var file_path = ""

var changes_saved = false

func _ready():
	SignalHandler.connect("send_error", Callable(self, "error_received"))
	SignalHandler.connect("send_message", Callable(self, "message_received"))

func _on_open_pressed():
	file_dialog.popup()

func _on_save_pressed():
	if FileAccess.file_exists(file_path):
		file = FileAccess.open(file_path, FileAccess.WRITE)
		file.store_string(code_edit.text)
		changes_saved = true
		save_button.text = "Save"
		SignalHandler.emit_signal("send_message", "File saved!")
	else:
		SignalHandler.emit_signal("send_error", "No existing file to save on.")

func _on_file_dialog_file_selected(path):
	if FileAccess.file_exists(path):
		file = FileAccess.open(path, FileAccess.READ)
		if file != null:
			file_path = path
			code_edit.text = file.get_as_text()
			changes_saved = true
			save_button.text = "Save"
			#code_edit.set_line_background_color(0, Color.SLATE_GRAY)

func _on_title_screen_pressed():
	get_tree().change_scene_to_file("res://scenes/title/title_screen.tscn")

func _on_code_edit_text_changed():
	changes_saved = false
	save_button.text = "Save*"
	
func error_received(message):
	status_label.modulate = Color.RED
	status_label.text = str(message)
	
func message_received(message):
	status_label.modulate = Color.WHITE
	status_label.text = str(message)
