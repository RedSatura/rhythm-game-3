extends Button

@export var input_action_name: String = ""

func _ready() -> void:
	self.text = OS.get_keycode_string(InputMap.action_get_events(input_action_name)[0].physical_keycode)

func _process(delta: float) -> void:
	pass
