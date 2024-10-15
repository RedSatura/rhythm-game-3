extends Node2D

@onready var ui: Node = $UI

func _ready() -> void:
	$UI/Singleplayer.grab_focus()
	ui.theme = GlobalData.global_settings["theme"]

func _on_singleplayer_pressed() -> void:
	SignalHandler.emit_signal("set_transition_status", false, "res://scenes/stage/stage.tscn")

func _on_multiplayer_classic_pressed() -> void:
	SignalHandler.emit_signal("set_transition_status", false, "res://scenes/stage/two_player_stage.tscn")
