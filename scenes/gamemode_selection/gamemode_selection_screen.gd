extends Node2D

@onready var ui: Node = $UI

@onready var gamemode_buttons: Node = $UI/GamemodeButtons
@onready var gamemode_player_buttons: Node = $UI/GamemodePlayerButtons

@onready var selection_title_label: Node = $UI/SelectionTitleLabel

func _ready() -> void:
	$UI/GamemodeButtons/Singleplayer.grab_focus()
	ui.theme = GlobalData.global_settings["theme"]

func _on_singleplayer_pressed() -> void:
	GlobalData.game_settings["gamemode"] = "singleplayer"
	SignalHandler.emit_signal("set_transition_status", false, "res://scenes/stage/stage.tscn")

func _on_multiplayer_classic_pressed() -> void:
	GlobalData.game_settings["gamemode"] = "multiplayer_classic"
	SignalHandler.emit_signal("set_transition_status", false, "res://scenes/stage/two_player_stage.tscn")
	
func _on_multiplayer_modified_pressed() -> void:
	GlobalData.game_settings["gamemode"] = "multiplayer_modified"
	SignalHandler.emit_signal("set_transition_status", false, "res://scenes/stage/two_player_stage.tscn")

func set_gamemode_status(_status: bool) -> void:
	pass

func _on_home_button_pressed() -> void:
	SignalHandler.emit_signal("set_transition_status", false, "res://scenes/title/title_screen.tscn")
