extends Control

@onready var left_lane: Node = $Controls/LeftLane/InputChangerButton
@onready var center_left_lane: Node = $Controls/CenterLeftLane/InputChangerButton
@onready var center_right_lane: Node = $Controls/CenterRightLane/InputChangerButton
@onready var right_lane: Node = $Controls/RightLane/InputChangerButton
@onready var pause: Node = $Controls/Pause/InputChangerButton

var selected_button: Button = null

func _ready() -> void:
	#basically what this means is this connects it to the toggled signal of the button
	left_lane.toggled.connect(_on_input_button_toggled.bind(left_lane))
	center_left_lane.toggled.connect(_on_input_button_toggled.bind(center_left_lane))
	center_right_lane.toggled.connect(_on_input_button_toggled.bind(center_right_lane))
	right_lane.toggled.connect(_on_input_button_toggled.bind(right_lane))
	pause.toggled.connect(_on_input_button_toggled.bind(pause))
	
	var key_scancode: InputEventKey = InputEventKey.new()
	key_scancode.set_keycode(GlobalData.global_settings["key_lane_left"])
	InputMap.action_erase_events("lane_left")
	InputMap.action_add_event("lane_left", key_scancode)
	key_scancode.set_keycode(GlobalData.global_settings["key_lane_center_left"])
	InputMap.action_erase_events("lane_center_left")
	InputMap.action_add_event("lane_center_left", key_scancode)
	key_scancode.set_keycode(GlobalData.global_settings["key_lane_center_right"])
	InputMap.action_erase_events("lane_center_right")
	InputMap.action_add_event("lane_center_right", key_scancode)
	key_scancode.set_keycode(GlobalData.global_settings["key_lane_right"])
	InputMap.action_erase_events("lane_right")
	InputMap.action_add_event("lane_right", key_scancode)
	key_scancode.set_keycode(GlobalData.global_settings["key_pause"])
	InputMap.action_erase_events("pause")
	InputMap.action_add_event("pause", key_scancode)
	update_button_text()
	
func _process(_delta: float) -> void:
	pass
	
func _input(event: InputEvent) -> void:
	if selected_button:
		if event is InputEventKey:
			change_key(event)

func _on_input_button_toggled(toggled_on: bool, button: Button) -> void:
	if toggled_on:
		if selected_button:
			selected_button.button_pressed = false
		selected_button = button
	else:
		pass

func change_key(event: InputEventKey) -> void:
	InputMap.action_erase_events(selected_button.input_action_name)
	InputMap.action_add_event(selected_button.input_action_name, event)
	
	GlobalData.global_settings["key_" + str(selected_button.input_action_name)] = event.keycode
	DataSaver.save_data()
	
	selected_button.text = OS.get_keycode_string(event.keycode)
	selected_button.button_pressed = false
	selected_button = null
	
func update_button_text() -> void:
	left_lane.text = OS.get_keycode_string(GlobalData.global_settings["key_lane_left"])
	center_left_lane.text = OS.get_keycode_string(GlobalData.global_settings["key_lane_center_left"])
	center_right_lane.text = OS.get_keycode_string(GlobalData.global_settings["key_lane_center_right"])
	right_lane.text = OS.get_keycode_string(GlobalData.global_settings["key_lane_right"])
	pause.text = OS.get_keycode_string(GlobalData.global_settings["key_pause"])
