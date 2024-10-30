extends Node2D

@export var highlighting_color: Color = Color.LIGHT_PINK

@export var play_from_beat: int = 0

@onready var code_edit: Node = $UI/CodeEdit
@onready var song_picker: Node = $SongPicker
@onready var new_song_saver: Node = $NewSongSaver
@onready var song_validator: Node = $SongValidator
@onready var song_manager: Node = $SongManager

@onready var open_button: Node = $UI/Open
@onready var save_button: Node = $UI/Save
@onready var play_button: Node = $UI/Play

@onready var currently_opened: Node = $UI/CurrentlyOpened

@onready var note_lanes: Node = $NoteLanes

@onready var messages_container: Node = $UI/ScrollContainer/MessagesContainer
@onready var song_manager_viewport: Node = $UI/SongManagerViewport

@onready var lyric_label: Node = $UI/LyricLabel

@onready var spinbox: Node = $UI/Play/SpinBox #spinbox for setting current beat in song

var file: FileAccess = null
var file_path: String = ""

var highlights_cleared: bool = false #used only when text is changed once. does not do anything else.

var current_line_in_file: int = 0

enum PlayButtonStatus {
	IDLE,
	PLAYING,
}

var play_button_status: int = PlayButtonStatus.IDLE

func _ready() -> void:
	SignalHandler.connect("send_error", Callable(self, "error_received"))
	SignalHandler.connect("send_message", Callable(self, "message_received"))
	SignalHandler.connect("update_editor_line_color", Callable(self, "update_editor_line_color"))
	SignalHandler.connect("song_validated", Callable(self, "process_song_validation"))
	SignalHandler.connect("beat_occured", Callable(self, "process_beat"))
	SignalHandler.connect("song_started", Callable(self, "song_started"))
	SignalHandler.connect("update_lyric", Callable(self, "update_lyric"))
	$UI.theme = GlobalData.global_settings["theme"]
	song_manager_viewport.visible = false
	song_validator.highlighting_color = highlighting_color
	code_edit.grab_focus()
	
	if GlobalData.global_settings["upscroll"]:
		lyric_label.position.y = 596

func _on_open_pressed() -> void:
	song_picker.popup()

func _on_save_pressed() -> void:
	save_song()
		
func update_lyric(lyric: String) -> void:
	lyric_label.text = lyric
	
func save_song() -> void:
	OS.request_permissions()
	if FileAccess.file_exists(file_path):
		file = FileAccess.open(file_path, FileAccess.WRITE)
		file.store_string(code_edit.text)
		save_button.text = "Save"
		file.flush() #HOURS OF MY LIFE, WASTED.
		SignalHandler.emit_signal("send_message", "File saved!")
	else:
		new_song_saver.popup()
		SignalHandler.emit_signal("send_error", "No existing file to save on.")

func _on_song_picker_file_selected(path: String) -> void:
	if FileAccess.file_exists(path):
		file = FileAccess.open(path, FileAccess.READ)
		if file != null:
			file_path = path
			code_edit.text = file.get_as_text()
			currently_opened.text = "Currently Opened File:\n" + str(path)
			save_button.text = "Save"
			code_edit.editable = true
			spinbox.editable = true
			play_button.text = "Play"
			play_button_status = PlayButtonStatus.IDLE
			SignalHandler.emit_signal("send_message", "Successfully opened file.")

func _on_title_screen_pressed() -> void:
	SignalHandler.emit_signal("set_transition_status", false, "res://scenes/title/title_screen.tscn")

func _on_code_edit_text_changed() -> void:
	clear_highlights() #pls fix, this is terrible (clears every single line of highlighting every time text changes)
	save_button.text = "Save*"

func _on_play_pressed() -> void: #Validates and plays the file
	current_line_in_file = 0
	clear_highlights()
	match play_button_status:
		PlayButtonStatus.IDLE:
			save_song()
			song_validator.validate_song(file_path)
			note_lanes.reset_lanes()
		PlayButtonStatus.PLAYING:
			code_edit.editable = true
			open_button.disabled = false
			save_button.disabled = false
			spinbox.editable = true
			note_lanes.reset_lanes()
			play_button.text = "Play"
			play_button_status = PlayButtonStatus.IDLE
			song_manager.stop_song()
			song_manager_viewport.visible = false
			current_line_in_file = 0
				
func clear_highlights() -> void:
	for x: int in code_edit.get_line_count():
		code_edit.set_line_background_color(x, Color(0, 0, 0, 0))
	
func update_editor_line_color(line: int = 0, color: Color = highlighting_color) -> void:
	if line > 0:
		if line < code_edit.get_line_count(): #This removes the background for the previous line, then adds background to the current line
			code_edit.set_line_background_color(line - 1, Color(0, 0, 0, 0))
			code_edit.set_line_background_color(line, color)
	else:
		if line < code_edit.get_line_count():
			code_edit.set_line_background_color(line, color)
		
func process_song_validation() -> void:
	code_edit.editable = false
	open_button.disabled = true
	save_button.disabled = true
	spinbox.editable = false
	play_button.text = "Stop"
	play_button_status = PlayButtonStatus.PLAYING
	song_manager_viewport.visible = true
	song_manager_viewport.get_node("SubViewport").set_world_2d(get_world_2d())
	current_line_in_file = song_validator.get_validator_lines_processed()
	song_manager.current_line_in_file = current_line_in_file
	song_manager.get_node("SongStartTimer").start()
	
func process_beat(_pos: int) -> void:
	update_editor_line_color(current_line_in_file, highlighting_color)
	current_line_in_file += 1

func _on_new_song_saver_file_selected(path: String) -> void:
	var new_file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	new_file.store_string(code_edit.text)
	new_file.flush()
	SignalHandler.emit_signal("send_message", "New file created and saved.")

func error_received(error: String) -> void:
	var message_display: Node = load("res://scenes/ui/message_display/message_display.tscn").instantiate()
	messages_container.add_child(message_display)
	message_display.update_message(1, error)
	
func message_received(message: String) -> void:
	var message_display: Node = load("res://scenes/ui/message_display/message_display.tscn").instantiate()
	messages_container.add_child(message_display)
	message_display.update_message(0, message)

func _on_spin_box_value_changed(value: float) -> void:
	SignalHandler.emit_signal("update_starting_song_beat", value)

func song_started() -> void:
	clear_highlights()
	current_line_in_file += spinbox.value
