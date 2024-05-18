extends Node2D

@onready var status_label = $ScrollContainer/StatusLabel

func _ready():
	SignalHandler.connect("send_error", Callable(self, "error_sent"))
	SignalHandler.connect("clear_status_label", Callable(self, "clear_status_label"))
	OS.request_permissions()

func _on_song_file_picker_file_selected(path):
	status_label.text = "Loading %s..." % [path]

func error_sent(message):
	status_label.text += str(message + '\n')

func clear_status_label():
	status_label.text = ""
