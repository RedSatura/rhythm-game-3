extends Node2D

#what 'player' these grouped lanes belong to
#1 means player 1 and 2 means player 2
@export var lane_identifier: int = 1
@export var cpu_active: bool = false
@export var cpu_difficulty: int = 0

@export var identifier_color_1: Color = Color.WHITE
@export var identifier_color_2: Color = Color.WHITE
@export var identifier_color_3: Color = Color.WHITE
@export var identifier_color_4: Color = Color.WHITE

@onready var note_lanes: Node = $NoteLanes
@onready var results: Node = $UI/Results

@onready var note_lane_1: Node = $NoteLanes/NoteLane1
@onready var note_lane_2: Node = $NoteLanes/NoteLane2
@onready var note_lane_3: Node = $NoteLanes/NoteLane3
@onready var note_lane_4: Node = $NoteLanes/NoteLane4

@onready var note_feedback_label: Node = $UI/NoteFeedbackLabel

@onready var ui: Node = $UI

var seconds_per_beat: float = 0 #Important for syncing tweens to the beat!

func _ready() -> void:
	SignalHandler.connect("spawn_note", Callable(self, "spawn_note_on_lane"))
	SignalHandler.connect("disable_lane", Callable(self, "disable_lane"))
	SignalHandler.connect("move_lane", Callable(self, "move_lane"))
	SignalHandler.connect("set_note_lane_setting_auto_mode", Callable(self, "set_note_lane_auto_mode"))
	SignalHandler.connect("get_song_seconds_per_beat", Callable(self, "set_seconds_per_beat"))
	
	ui.theme = GlobalData.global_settings["theme"]
		
	if GlobalData.global_settings["upscroll"]:
		note_lanes.rotation_degrees = -180
		note_lanes.scale.x = -1
		note_lanes.position.y = 368
		
	if cpu_active:
		cpu_difficulty = GlobalData.game_settings["cpu_difficulty"]
		set_note_lane_cpu()
		
	set_note_lane_identifier_colors()
	set_lane_idenitifier_data()
	set_children_identifiers()
		
func set_note_lane_cpu() -> void:
	note_lane_1.difficulty = cpu_difficulty
	note_lane_2.difficulty = cpu_difficulty
	note_lane_3.difficulty = cpu_difficulty
	note_lane_4.difficulty = cpu_difficulty
	
	note_lane_1.auto_mode = true
	note_lane_2.auto_mode = true
	note_lane_3.auto_mode = true
	note_lane_4.auto_mode = true
	
func set_children_identifiers() -> void:
	note_feedback_label.lane_identifier = lane_identifier
	results.lane_identifier = lane_identifier

func set_note_lane_identifier_colors() -> void:
	note_lane_1.set_identifier_color(identifier_color_1)
	note_lane_2.set_identifier_color(identifier_color_2)
	note_lane_3.set_identifier_color(identifier_color_3)
	note_lane_4.set_identifier_color(identifier_color_4)
	
func set_lane_idenitifier_data() -> void:
	note_lane_1.note_source = lane_identifier
	note_lane_2.note_source = lane_identifier
	note_lane_3.note_source = lane_identifier
	note_lane_4.note_source = lane_identifier

func spawn_note_on_lane(lane_number: int) -> void:
	#man this solution is terrible but it works
	match lane_number:
		0:
			var random_number: int = RandomNumberGenerator.new().randi_range(1, 4)
			spawn_note_on_lane(random_number)
		1:
			note_lane_1.spawn_note()
		2:
			note_lane_2.spawn_note()
		3:
			note_lane_3.spawn_note()
		4:
			note_lane_4.spawn_note()
		_:
			pass

func disable_lane(lane_number: int, duration: int) -> void:
	#this is also terrible but i'll improve it eventually
	match lane_number:
		1:
			note_lane_1.disable_lane(duration)
		2:
			note_lane_2.disable_lane(duration)
		3:
			note_lane_3.disable_lane(duration)
		4:
			note_lane_4.disable_lane(duration)
		_:
			pass
			
func set_note_lane_auto_mode(status: bool = false) -> void:
	note_lane_1.auto_mode = status
	note_lane_2.auto_mode = status
	note_lane_3.auto_mode = status
	note_lane_4.auto_mode = status

func move_lane(lane_number: int, movement_value: int = 0, duration: int = 1) -> void:
	match lane_number:
		1:
			note_lane_1.move_lane(movement_value, duration * seconds_per_beat)
		2:
			note_lane_2.move_lane(movement_value, duration * seconds_per_beat)
		3:
			note_lane_3.move_lane(movement_value, duration * seconds_per_beat)
		4:
			note_lane_4.move_lane(movement_value, duration * seconds_per_beat)
		_:
			pass

func set_seconds_per_beat(seconds: float) -> void:
	seconds_per_beat = seconds

func reset_lanes() -> void:
	note_lane_1.position.x = 64
	note_lane_2.position.x = 192
	note_lane_3.position.x = 320
	note_lane_4.position.x = 448
