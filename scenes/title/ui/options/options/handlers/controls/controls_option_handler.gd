extends Control

@onready var left_lane: Node = $Controls/LeftLane/InputChangerButton
@onready var center_left_lane: Node = $Controls/CenterLeftLane/InputChangerButton
@onready var center_right_lane: Node = $Controls/CenterRightLane/InputChangerButton
@onready var right_lane: Node = $Controls/RightLane/InputChangerButton
@onready var paused: Node = $Controls/Pause/InputChangerButton

var selected_button: Button = null

func _ready() -> void:
	left_lane.toggled.connect(_on_input_button_toggled.bind(left_lane))
	center_left_lane.toggled.connect(_on_input_button_toggled.bind(center_left_lane))
	center_right_lane.toggled.connect(_on_input_button_toggled.bind(center_right_lane))
	right_lane.toggled.connect(_on_input_button_toggled.bind(right_lane))
	paused.toggled.connect(_on_input_button_toggled.bind(paused))
	
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
	selected_button.text = OS.get_keycode_string(event.keycode)
	selected_button.button_pressed = false
	selected_button = null
