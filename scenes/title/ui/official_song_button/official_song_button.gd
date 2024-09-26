extends Button

@export_file("*.msf") var song_path: String

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		emit_signal("pressed")
