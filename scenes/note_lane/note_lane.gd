extends Node2D

@export var lane_position: String = "LEFT"
@export var auto_mode: bool = false

@onready var note_spawn_position: Node = $NoteSpawnPosition
@onready var note_cooldown_timer: Node = $NoteCooldownTimer

@onready var hitspot: Node = $Hitspot
@onready var hitspot_flash_cooldown: Node = $Hitspot/HitspotFlashCooldown

@onready var lane_background: Node = $LaneBackground

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

func spawn_note() -> void:
	var new_note: Node = load("res://scenes/note_lane/note/note.tscn").instantiate()
	new_note.distance_to_target = Vector2(hitspot.position.x - note_spawn_position.position.x, hitspot.position.y - note_spawn_position.position.y)
	add_child(new_note)
	new_note.global_position = note_spawn_position.global_position
	
	
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
	hitspot.color.r = 0.5
	hitspot_flash_cooldown.start()
	if current_note != null:
		if good:
			SignalHandler.emit_signal("note_hit", "GOOD")
		elif perfect:
			SignalHandler.emit_signal("note_hit", "PERFECT")
		current_note.queue_free()
		current_note = null

func _on_note_detector_area_entered(area: Area2D) -> void:
	current_note = area
	good = true

func _on_note_detector_area_exited(_area: Area2D) -> void:
	current_note = null
	good = false

func _on_hitspot_flash_cooldown_timeout() -> void:
	hitspot.color.r = 0.176

func measure_occured() -> void:
	pass
	
func beat_occured(_pos: int) -> void:
	if disabled_beats_left > 0:
		disabled_beats_left -= 1
		if disabled_beats_left <= 0:
			enable_lane()
	
func disable_lane(duration: int = 0) -> void:
	lane_state = LaneState.DISABLED
	lane_background.color = Color(0, 0)
	disabled_beats_left = duration
	
func enable_lane() -> void:
	lane_state = LaneState.ACTIVE
	lane_background.color = Color(0.6, 0.357, 0.224, 0.502)

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

func _on_perfect_area_area_entered(area: Area2D) -> void:
	good = false
	perfect = true
	if auto_mode:
		if current_note != null:
			SignalHandler.emit_signal("note_hit", "PERFECT")
			current_note.queue_free()
			current_note = null

func _on_perfect_area_area_exited(area: Area2D) -> void:
	good = true
	perfect = false

func _on_area_2d_area_entered(area: Area2D) -> void:
	SignalHandler.emit_signal("note_hit", "MISS")
