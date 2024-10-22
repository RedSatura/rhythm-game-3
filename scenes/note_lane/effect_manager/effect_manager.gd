extends Control

@export var active: bool = false
@export var cpu_active: bool = false
@export var lane_identifier: int = 1
@export var difficulty: int = 0

@onready var active_effect_label: Node = $ActiveEffectLabel

var effect_selection_active: bool = false

enum Effects {
	NONE,
	NOTE_SPEED_INCREASE,
	NOTE_FADEOUT,
}

var effect_names: Array = ["None", "Note Speed Increase", "Note Fadeout"]

var active_effect: int = Effects.NONE

func _ready() -> void:
	SignalHandler.connect("beat_occured", Callable(self, "beat_occured"))
	SignalHandler.connect("song_ended", Callable(self, "song_ended"))
	
	if GlobalData.game_settings["gamemode"] == "multiplayer_modified":
		active = true
		self.visible = true
	else:
		active = false
		self.visible = false

func beat_occured(pos: int) -> void:
	if cpu_active && pos % 2 == 0 && active:
		run_cpu()

func _unhandled_input(event: InputEvent) -> void:
	if active:
		if lane_identifier == 1:
			if Input.is_action_just_pressed("switch_effect_1"):
				if active_effect >= Effects.size() - 1:
					active_effect = 0
					active_effect_label.text = effect_names[active_effect]
				else:
					active_effect += 1
					active_effect_label.text = effect_names[active_effect]
			elif Input.is_action_just_pressed("select_effect_1"):
				SignalHandler.emit_signal("send_effect", 2, active_effect)
		elif lane_identifier == 2:
			if Input.is_action_just_pressed("switch_effect_2"):
				if active_effect >= Effects.size() - 1:
					active_effect = 0
					active_effect_label.text = effect_names[active_effect]
				else:
					active_effect += 1
					active_effect_label.text = effect_names[active_effect]
			elif Input.is_action_just_pressed("select_effect_2"):
				SignalHandler.emit_signal("send_effect", 1, active_effect)

func song_ended() -> void:
	self.visible = false

func run_cpu() -> void:
	if lane_identifier == 1:
		pass
	elif lane_identifier == 2:
		var chance: int = randi_range(0, 100)
		if chance + (difficulty / 10) >= 80:
			if active_effect >= Effects.size() - 1:
				active_effect = 0
				active_effect_label.text = effect_names[active_effect]
			else:
				active_effect += 1
				active_effect_label.text = effect_names[active_effect]
				
		var selection_chance: int = randi_range(0, 100)
		if selection_chance + (difficulty / 20) >= 95:
			SignalHandler.emit_signal("send_effect", 1, active_effect)
