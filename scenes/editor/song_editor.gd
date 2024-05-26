extends Node2D

@onready var code_edit = $CodeEdit
@onready var file_dialog = $FileDialog
@onready var song_validator = $SongValidator

@onready var open_button = $Open
@onready var save_button = $Save
@onready var play_button = $Play


@onready var currently_opened = $CurrentlyOpened
@onready var status_label = $StatusLabel

var file = null
var file_path = ""

var highlights_cleared = false #used only when text is changed once. does not do anything else.

enum PlayButtonStatus {
	IDLE,
	PLAYING,
}

var play_button_status = PlayButtonStatus.IDLE

func _ready():
	SignalHandler.connect("send_error", Callable(self, "error_received"))
	SignalHandler.connect("send_message", Callable(self, "message_received"))
	SignalHandler.connect("update_editor_line_color", Callable(self, "update_editor_line_color"))
	SignalHandler.connect("song_validated", Callable(self, "process_song_validation"))
	SignalHandler.connect("song_saved", Callable(self, "process_song_saving"))

func _on_open_pressed():
	file_dialog.popup()

func _on_save_pressed():
	save_song()
		
func save_song():
	if FileAccess.file_exists(file_path):
		file = FileAccess.open(file_path, FileAccess.WRITE)
		file.store_string(code_edit.text)
		save_button.text = "Save"
		file.flush() #HOURS OF MY LIFE, WASTED.
		SignalHandler.emit_signal("send_message", "File saved!")
	else:
		SignalHandler.emit_signal("send_error", "No existing file to save on.")

func _on_file_dialog_file_selected(path):
	if FileAccess.file_exists(path):
		file = FileAccess.open(path, FileAccess.READ)
		if file != null:
			file_path = path
			code_edit.text = file.get_as_text()
			currently_opened.text = "Currently Opened File:\n" + str(path)
			save_button.text = "Save"
			code_edit.editable = true
			play_button.text = "Play"
			play_button_status = PlayButtonStatus.IDLE
			SignalHandler.emit_signal("send_message", "Successfully opened file.")

func _on_title_screen_pressed():
	get_tree().change_scene_to_file("res://scenes/title/title_screen.tscn")

func _on_code_edit_text_changed():
	clear_highlights() #pls fix, this is terrible (clears every single line of highlighting every time text changes)
	save_button.text = "Save*"
	
func error_received(message):
	status_label.modulate = Color.RED
	status_label.text = str(message)
	
func message_received(message):
	status_label.modulate = Color.WHITE
	status_label.text = str(message)

func _on_play_pressed(): #Validates and plays the file
	clear_highlights()
	save_song()
	match play_button_status:
		PlayButtonStatus.IDLE:
			song_validator.validate_song(file_path)
		PlayButtonStatus.PLAYING:
			code_edit.editable = true
			play_button.text = "Play"
			play_button_status = PlayButtonStatus.IDLE
				
func clear_highlights():
	for x in code_edit.get_line_count():
		code_edit.set_line_background_color(x, Color(0, 0, 0, 0))
	
func update_editor_line_color(line = 0, color = Color.SLATE_GRAY):
	if line > 0:
		if line < code_edit.get_line_count():
			code_edit.set_line_background_color(line - 1, Color(0, 0, 0, 0))
			code_edit.set_line_background_color(line, color)
	else:
		if line <= code_edit.get_line_count():
			code_edit.set_line_background_color(line, color)
		
func process_song_validation():
	code_edit.editable = false
	play_button.text = "Stop"
	play_button_status = PlayButtonStatus.PLAYING

func process_song_saving():
	pass
