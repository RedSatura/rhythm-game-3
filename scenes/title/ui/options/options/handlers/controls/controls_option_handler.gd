extends Control

@onready var left_lane_1: Node = $Controls/Player1/LeftLane/InputChangerButton
@onready var center_left_lane_1: Node = $Controls/Player1/CenterLeftLane/InputChangerButton
@onready var center_right_lane_1: Node = $Controls/Player1/CenterRightLane/InputChangerButton
@onready var right_lane_1: Node = $Controls/Player1/RightLane/InputChangerButton
@onready var left_lane_2: Node = $Controls/Player2/LeftLane/InputChangerButton
@onready var center_left_lane_2: Node = $Controls/Player2/CenterLeftLane/InputChangerButton
@onready var center_right_lane_2: Node = $Controls/Player2/CenterRightLane/InputChangerButton
@onready var right_lane_2: Node = $Controls/Player2/RightLane/InputChangerButton
@onready var pause: Node = $Controls/General/Pause/InputChangerButton
@onready var restart: Node = $Controls/General/Restart/InputChangerButton

var selected_button: Button = null

func _ready() -> void:
	#basically what this means is this connects it to the toggled signal of the button
	left_lane_1.toggled.connect(_on_input_button_toggled.bind(left_lane_1))
	center_left_lane_1.toggled.connect(_on_input_button_toggled.bind(center_left_lane_1))
	center_right_lane_1.toggled.connect(_on_input_button_toggled.bind(center_right_lane_1))
	right_lane_1.toggled.connect(_on_input_button_toggled.bind(right_lane_1))
	left_lane_2.toggled.connect(_on_input_button_toggled.bind(left_lane_2))
	center_left_lane_2.toggled.connect(_on_input_button_toggled.bind(center_left_lane_2))
	center_right_lane_2.toggled.connect(_on_input_button_toggled.bind(center_right_lane_2))
	right_lane_2.toggled.connect(_on_input_button_toggled.bind(right_lane_2))
	pause.toggled.connect(_on_input_button_toggled.bind(pause))
	restart.toggled.connect(_on_input_button_toggled.bind(restart))
	
	update_button_text()
	
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
	selected_button.release_focus()
	selected_button = null
	
func update_button_text() -> void:
	left_lane_1.text = OS.get_keycode_string(GlobalData.global_settings["key_lane_left_1"])
	center_left_lane_1.text = OS.get_keycode_string(GlobalData.global_settings["key_lane_center_left_1"])
	center_right_lane_1.text = OS.get_keycode_string(GlobalData.global_settings["key_lane_center_right_1"])
	right_lane_1.text = OS.get_keycode_string(GlobalData.global_settings["key_lane_right_1"])
	left_lane_2.text = OS.get_keycode_string(GlobalData.global_settings["key_lane_left_2"])
	center_left_lane_2.text = OS.get_keycode_string(GlobalData.global_settings["key_lane_center_left_2"])
	center_right_lane_2.text = OS.get_keycode_string(GlobalData.global_settings["key_lane_center_right_2"])
	right_lane_2.text = OS.get_keycode_string(GlobalData.global_settings["key_lane_right_2"])
	pause.text = OS.get_keycode_string(GlobalData.global_settings["key_pause"])
	restart.text = OS.get_keycode_string(GlobalData.global_settings["key_restart"])

func _on_input_changer_button_focus_exited() -> void:
	selected_button.button_pressed = false
	selected_button.release_focus()
	selected_button = null
