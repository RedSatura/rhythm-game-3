extends Node2D

@onready var ui: Node = $UI

@onready var gamemode_buttons: Node = $UI/GamemodeButtons
@onready var gamemode_player_buttons: Node = $UI/GamemodePlayerButtons

@onready var selection_title_label: Node = $UI/SelectionTitleLabel

func _ready() -> void:
	$UI/GamemodeButtons/Singleplayer.grab_focus()
	ui.theme = GlobalData.global_settings["theme"]
	$UI/GamemodePlayerButtons/PlayerComputer/Difficulty/DifficultySlider.value = GlobalData.game_settings["cpu_1_difficulty"]

func _on_singleplayer_pressed() -> void:
	GlobalData.game_settings["gamemode"] = "singleplayer"
	SignalHandler.emit_signal("set_transition_status", false, "res://scenes/stage/stage.tscn")

func _on_multiplayer_classic_pressed() -> void:
	GlobalData.game_settings["gamemode"] = "multiplayer_classic"
	#SignalHandler.emit_signal("set_transition_status", false, "res://scenes/stage/two_player_stage.tscn")
	gamemode_player_buttons.visible = true
	gamemode_buttons.visible = false
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(gamemode_buttons, "modulate", Color(1.0, 1.0, 1.0, 0.0), 0.1)
	tween.tween_property(gamemode_player_buttons, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.1)
	$UI/GamemodePlayerButtons/PlayerPlayer.grab_focus()
	
func _on_multiplayer_modified_pressed() -> void:
	GlobalData.game_settings["gamemode"] = "multiplayer_modified"
	SignalHandler.emit_signal("set_transition_status", false, "res://scenes/stage/two_player_stage.tscn")

func set_gamemode_status(_status: bool) -> void:
	pass

func _on_home_button_pressed() -> void:
	SignalHandler.emit_signal("set_transition_status", false, "res://scenes/title/title_screen.tscn")

func _on_player_player_pressed() -> void:
	GlobalData.game_settings["cpu_1_active"] = false
	GlobalData.game_settings["cpu_2_active"] = false
	SignalHandler.emit_signal("set_transition_status", false, "res://scenes/stage/two_player_stage.tscn")

func _on_player_computer_pressed() -> void:
	GlobalData.game_settings["cpu_1_active"] = false
	GlobalData.game_settings["cpu_2_active"] = true
	SignalHandler.emit_signal("set_transition_status", false, "res://scenes/stage/two_player_stage.tscn")

func _on_computer_computer_pressed() -> void:
	GlobalData.game_settings["cpu_1_active"] = true
	GlobalData.game_settings["cpu_2_active"] = true
	SignalHandler.emit_signal("set_transition_status", false, "res://scenes/stage/two_player_stage.tscn")

func _on_multiplayer_return_pressed() -> void:
	gamemode_player_buttons.visible = false
	gamemode_buttons.visible = true
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(gamemode_buttons, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.1)
	tween.tween_property(gamemode_player_buttons, "modulate", Color(1.0, 1.0, 1.0, 0.0), 0.1)
	$UI/GamemodeButtons/Singleplayer.grab_focus()

func _on_difficulty_slider_value_changed(value: float) -> void:
	GlobalData.game_settings["cpu_1_difficulty"] = value
	GlobalData.game_settings["cpu_2_difficulty"] = value
	$UI/GamemodePlayerButtons/PlayerComputer/Difficulty.text = "Difficulty\n" + str(value)
