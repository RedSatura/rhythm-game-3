extends Node2D

@export var lane_position: String = "LEFT"
@export var auto_mode: bool = false
@export var in_editor: bool = false

@export var perfect_color: Color = Color.MAGENTA
@export var good_color: Color = Color(1.0, 0.549, 0.784)
@export var miss_color: Color = Color.RED

@onready var note_spawn_position: Node = $NoteSpawnPosition
@onready var note_cooldown_timer: Node = $NoteCooldownTimer

@onready var note_detector: Node = $NoteDetector

@onready var lane_background: Node = $UI/LaneBackground
@onready var note_detector_background: Node = $UI/NoteDetectorBackground
@onready var hit_feedback_background: Node = $UI/HitFeedbackBackground

var current_note: Area2D = null

var disabled_beats_left: int = 0

var perfect: bool = false
var good: bool = false

enum LaneState {
	ACTIVE,
	DISABLED,
}

var lane_state: int = LaneState.ACTIVE

func _ready() -> void:
	SignalHandler.connect("beat_occured", Callable(self, "beat_occured"))
	SignalHandler.connect("measure_occured", Callable(self, "measure_occured"))
	perfect = false
	good = false
	current_note = null
	$UI.theme = GlobalData.global_settings["theme"]

func spawn_note() -> void:
	if lane_state == LaneState.ACTIVE:
		var new_note: Node = load("res://scenes/note_lane/note/note.tscn").instantiate()
		new_note.distance_to_target = Vector2(note_detector.position.x - note_spawn_position.position.x, note_detector.position.y - note_spawn_position.position.y)
		add_child(new_note)
		new_note.global_position = note_spawn_position.global_position
	else:
		SignalHandler.emit_signal("send_error", "Cannot spawn note when lane is disabled.")
	
func _on_note_cooldown_timer_timeout() -> void:
	spawn_note()
	
func _unhandled_input(_event: InputEvent) -> void:
	if lane_state == LaneState.ACTIVE && !auto_mode:
		match lane_position:
			"LEFT":
				if Input.is_action_just_pressed("lane_left"):
					handle_input_on_note()
			"CENTER_LEFT":
				if Input.is_action_just_pressed("lane_center_left"):
					handle_input_on_note()
			"CENTER_RIGHT":
				if Input.is_action_just_pressed("lane_center_right"):
					handle_input_on_note()
			"RIGHT":
				if Input.is_action_just_pressed("lane_right"):
					handle_input_on_note()
				
func handle_input_on_note() -> void:
	if current_note != null:
		if good:
			SignalHandler.emit_signal("note_hit", "GOOD")
			if !in_editor:
				hit_feedback_background.material.set_shader_parameter("background_color", good_color)
			fade_feedback_background()
		elif perfect:
			SignalHandler.emit_signal("note_hit", "PERFECT")
			if !in_editor:
				hit_feedback_background.material.set_shader_parameter("background_color", perfect_color)
			fade_feedback_background()
		current_note.queue_free()
		current_note = null

func _on_note_detector_area_entered(area: Area2D) -> void:
	current_note = area
	good = true

func _on_note_detector_area_exited(_area: Area2D) -> void:
	current_note = null
	good = false

func measure_occured() -> void:
	pass
	
func beat_occured(_pos: int) -> void:
	if disabled_beats_left > 0:
		disabled_beats_left -= 1
		if disabled_beats_left <= 0:
			enable_lane()
	
func disable_lane(duration: int = 0) -> void:
	lane_state = LaneState.DISABLED
	lane_background.modulate = Color(0, 0)
	disabled_beats_left = duration
	
func enable_lane() -> void:
	lane_state = LaneState.ACTIVE
	lane_background.modulate = Color(0.7, 0.7, 0.7, 1.0)

func _on_note_detector_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventScreenTouch:
		match lane_position:
			"LEFT":
					handle_input_on_note()
			"CENTER_LEFT":
					handle_input_on_note()
			"CENTER_RIGHT":
					handle_input_on_note()
			"RIGHT":
					handle_input_on_note()

func _on_perfect_area_area_entered(_area: Area2D) -> void:
	good = false
	perfect = true
	if auto_mode:
		if current_note != null:
			SignalHandler.emit_signal("note_hit", "PERFECT")
			current_note.queue_free()
			current_note = null

func _on_perfect_area_area_exited(_area: Area2D) -> void:
	good = true
	perfect = false

func _on_area_2d_area_entered(_area: Area2D) -> void:
	SignalHandler.emit_signal("note_hit", "MISS")
	if !in_editor:
		hit_feedback_background.material.set_shader_parameter("background_color", miss_color)
	fade_feedback_background()

func fade_feedback_background() -> void:
	var tween: Tween = get_tree().create_tween()
	tween.tween_method(set_fade_value, 1.0, 0.0, 0.5)
	
func set_fade_value(value: float) -> void:
	hit_feedback_background.material.set_shader_parameter("background_transparency", value)

func move_lane(movement_value: int = 0, duration: float = 0) -> void:
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(self, "position", Vector2(self.position.x + movement_value, self.position.y), duration)

func stop_tweens() -> void:
	pass
