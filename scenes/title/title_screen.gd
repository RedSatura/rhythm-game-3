extends Node2D

@onready var status_label = $StatusLabel

func _ready():
	OS.request_permissions()

func _on_song_file_picker_file_selected(path):
	status_label.text = "Loading %s..." % [path]
