extends Node2D

@export var lane_position: String = "LEFT"
@export var auto_mode: bool = false
@export var in_editor: bool = false

@export var perfect_color: Color = Color.MAGENTA
@export var good_color: Color = Color(1.0, 0.549, 0.784)
@export var miss_color: Color = Color.RED

@export var identifier_color: Color = Color.WHITE

@export var initial_position: int = 0

#the higher the difficulty, the more likely it hits a note
@export var difficulty: int = 0

#basically where the note comes from when playing two-player
#so player 1 gets notes from 1 and player 2 gets notes from 2
#if you get confused note_source is basically equivalent to lane_identifier from its parents
#im stupid, sorry
@export var note_source: int = 1

@onready var note_spawn_position: Node = $NoteSpawnPosition
@onready var note_cooldown_timer: Node = $NoteCooldownTimer

@onready var note_detector: Node = $NoteDetector

@onready var lane_background: Node = $UI/LaneBackground
@onready var note_detector_background: Node = $UI/NoteDetectorBackground
@onready var hit_feedback_background: Node = $UI/HitFeedbackBackground

@onready var lane_identifier: Node = $LaneIdentifier

@onready var effect_cooldown_timer: Node = $EffectCooldown

var current_note: Area2D = null

var disabled_beats_left: int = 0

var effect_active: bool = false
#effect statuses
var note_fadeout: bool = false


var perfect: bool = false
var good: bool = false

var early: bool = false
var late: bool = true

enum LaneState {
	ACTIVE,
	DISABLED,
}

var lane_state: int = LaneState.ACTIVE

func _ready() -> void:
	SignalHandler.connect("beat_occured", Callable(self, "beat_occured"))
	SignalHandler.connect("measure_occured", Callable(self, "measure_occured"))
	SignalHandler.connect("hold_note_completed", Callable(self, "hold_note_completed"))
	perfect = false
	good = false
	current_note = null
	lane_identifier.color = Color(identifier_color.r, identifier_color.g, identifier_color.b, 0.5)
	$UI.theme = GlobalData.global_settings["theme"]
	note_spawn_position.position.y = GlobalData.global_settings["scroll_speed"] * -1024
	
func set_identifier_color(color: Color) -> void:
	lane_identifier.color = Color(color.r, color.g, color.b, 0.75)

func spawn_note() -> void:
	if lane_state == LaneState.ACTIVE:
		var new_note: Node = load("res://scenes/note_lane/note/note.tscn").instantiate()
		new_note.distance_to_target = Vector2(note_detector.position.x - note_spawn_position.position.x, note_detector.position.y - note_spawn_position.position.y)
		add_child(new_note)
		new_note.global_position = note_spawn_position.global_position
		if note_fadeout:
			new_note.note_fadeout_timer.start()
	else:
		SignalHandler.emit_signal("send_error", "Cannot spawn note when lane is disabled.")
		
func spawn_hold_note(duration: int) -> void:
	if duration > 0:
		if lane_state == LaneState.ACTIVE:
			var new_note: Node = load("res://scenes/note_lane/note/hold_note/hold_note.tscn").instantiate()
			new_note.distance_to_target = Vector2(note_detector.position.x - note_spawn_position.position.x, note_detector.position.y - note_spawn_position.position.y)
			new_note.duration = duration
			add_child(new_note)
			new_note.global_position = note_spawn_position.global_position
		else:
			pass
	else:
		SignalHandler.emit_signal("send_error", "Cannot spawn hold note when duration is 0 or less!")
		
func hold_note_completed(source: int, target_lane: String) -> void:
	if target_lane == lane_position:
		if note_source == source:
			if !in_editor:
				if note_source == 1:
					hit_feedback_background.material.set_shader_parameter("background_color", perfect_color)
					SignalHandler.emit_signal("note_hit", "PERFECT", 1)
					fade_feedback_background()
				elif note_source == 2:
					hit_feedback_background.material.set_shader_parameter("background_color", perfect_color)
					SignalHandler.emit_signal("note_hit", "PERFECT", 2)
					fade_feedback_background()
			current_note = null
	
func _on_note_cooldown_timer_timeout() -> void:
	spawn_note()
	
func _unhandled_input(_event: InputEvent) -> void:
	if lane_state == LaneState.ACTIVE && !auto_mode:
		if note_source == 1:
			match lane_position:
				"LEFT":
					if Input.is_action_just_pressed("lane_left_1"):
						handle_input_on_note()
				"CENTER_LEFT":
					if Input.is_action_just_pressed("lane_center_left_1"):
						handle_input_on_note()
				"CENTER_RIGHT":
					if Input.is_action_just_pressed("lane_center_right_1"):
						handle_input_on_note()
				"RIGHT":
					if Input.is_action_just_pressed("lane_right_1"):
						handle_input_on_note()
		if note_source == 2:
			match lane_position:
				"LEFT":
					if Input.is_action_just_pressed("lane_left_2"):
						handle_input_on_note()
				"CENTER_LEFT":
					if Input.is_action_just_pressed("lane_center_left_2"):
						handle_input_on_note()
				"CENTER_RIGHT":
					if Input.is_action_just_pressed("lane_center_right_2"):
						handle_input_on_note()
				"RIGHT":
					if Input.is_action_just_pressed("lane_right_2"):
						handle_input_on_note()
		#hold notes
		if note_source == 1:
			match lane_position:
				"LEFT":
					if Input.is_action_just_released("lane_left_1"):
						if current_note != null:
							if current_note.has_signal("process_ending_note_input"):
								pass
							elif current_note.has_signal("process_hold_note_miss_release"):
								current_note.emit_signal("process_hold_note_miss_release", note_source)
								current_note = null
				"CENTER_LEFT":
					if Input.is_action_just_released("lane_center_left_1"):
						if current_note != null:
							if current_note.has_signal("process_ending_note_input"):
								pass
							elif current_note.has_signal("process_hold_note_miss_release"):
								current_note.emit_signal("process_hold_note_miss_release", note_source)
								current_note = null
				"CENTER_RIGHT":
					if Input.is_action_just_released("lane_right_1"):
						if current_note != null:
							if current_note.has_signal("process_ending_note_input"):
								pass
							elif current_note.has_signal("process_hold_note_miss_release"):
								current_note.emit_signal("process_hold_note_miss_release", note_source)
								current_note = null
				"RIGHT":
					if Input.is_action_just_released("lane_right_1"):
						if current_note != null:
							if current_note.has_signal("process_ending_note_input"):
								pass
							elif current_note.has_signal("process_hold_note_miss_release"):
								current_note.emit_signal("process_hold_note_miss_release", note_source)
								current_note = null
		elif note_source == 2:
			match lane_position:
				"LEFT":
					if Input.is_action_just_released("lane_left_2"):
						if current_note != null:
							if current_note.has_signal("process_ending_note_input"):
								pass
							elif current_note.has_signal("process_hold_note_miss_release"):
								current_note.emit_signal("process_hold_note_miss_release", note_source)
								current_note = null
				"CENTER_LEFT":
					if Input.is_action_just_released("lane_center_left_2"):
						if current_note != null:
							if current_note.has_signal("process_ending_note_input"):
								pass
							elif current_note.has_signal("process_hold_note_miss_release"):
								current_note.emit_signal("process_hold_note_miss_release", note_source)
								current_note = null
				"CENTER_RIGHT":
					if Input.is_action_just_released("lane_right_2"):
						if current_note != null:
							if current_note.has_signal("process_ending_note_input"):
								pass
							elif current_note.has_signal("process_hold_note_miss_release"):
								current_note.emit_signal("process_hold_note_miss_release", note_source)
								current_note = null
				"RIGHT":
					if Input.is_action_just_released("lane_right_2"):
						if current_note != null:
							if current_note.has_signal("process_ending_note_input"):
								pass
							elif current_note.has_signal("process_hold_note_miss_release"):
								current_note.emit_signal("process_hold_note_miss_release", note_source)
								current_note = null
				
func handle_input_on_note() -> void:
	if current_note != null:
		if note_source == 1:
			if current_note.has_signal("process_starting_note_input"):
				current_note.emit_signal("process_starting_note_input", note_source, lane_position)
			elif current_note.has_signal("process_ending_note_input"):
				pass
			else:
				current_note.queue_free()
				current_note = null
		elif note_source == 2:
			if current_note.has_signal("process_starting_note_input"):
				current_note.emit_signal("process_starting_note_input", note_source, lane_position)
			elif current_note.has_signal("process_ending_note_input"):
				pass
			else:
				current_note.queue_free()
				current_note = null
	
		if early:
			SignalHandler.emit_signal("note_hit", "EARLY", note_source)
			if !in_editor:
				hit_feedback_background.material.set_shader_parameter("background_color", good_color)
			fade_feedback_background()
		elif late:
			SignalHandler.emit_signal("note_hit", "LATE", note_source)
			if !in_editor:
				hit_feedback_background.material.set_shader_parameter("background_color", good_color)
			fade_feedback_background()
		elif perfect:
			SignalHandler.emit_signal("note_hit", "PERFECT", note_source)
			if !in_editor:
				hit_feedback_background.material.set_shader_parameter("background_color", perfect_color)
			fade_feedback_background()

func _on_note_detector_area_entered(area: Area2D) -> void:
	if area.has_signal("process_ending_note_input"):
		current_note = null
	else:
		current_note = area
		early = true
		good = true

func _on_note_detector_area_exited(area: Area2D) -> void:
	if area.has_signal("process_starting_note_miss"):
		pass
	current_note = null
	early = false
	late = false
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
	disabled_beats_left = duration
	lane_background.modulate = Color(0, 0)
	
func enable_lane() -> void:
	lane_state = LaneState.ACTIVE
	#lane_background.modulate = Color(0.25, 0.25, 0.25, 1.0)

func _on_note_detector_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventScreenTouch && !auto_mode:
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
	early = false
	late = false
	perfect = true

func _on_perfect_area_area_exited(_area: Area2D) -> void:
	good = true
	late = true
	perfect = false

func fade_feedback_background() -> void:
	var tween: Tween = get_tree().create_tween()
	tween.tween_method(set_fade_value, 1.0, 0.0, 0.5)
	
func set_fade_value(value: float) -> void:
	hit_feedback_background.material.set_shader_parameter("background_transparency", value)

func move_lane(movement_value: int = 0, duration: float = 0) -> void:
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(self, "position", Vector2(initial_position + movement_value, self.position.y), duration)

func stop_tweens() -> void:
	pass

func _on_auto_hit_area_area_entered(_area: Area2D) -> void:
	if in_editor:
		if current_note != null:
			if current_note.has_signal("process_starting_note_input"):
				current_note.emit_signal("process_starting_note_input", note_source, lane_position)
			else:
				current_note.queue_free()
				current_note = null
	else:
		if auto_mode:
			var chance: int = randi_range(0, 100)
			if chance <= difficulty:
				if current_note:
					if current_note.has_signal("process_starting_note_input"):
						current_note.emit_signal("process_starting_note_input", note_source, lane_position)
						var perfect_chance: int = randi_range(0, 100)
						if perfect_chance * 1.2 <= difficulty:
							SignalHandler.emit_signal("note_hit", "PERFECT", note_source)
							hit_feedback_background.material.set_shader_parameter("background_color", perfect_color)
							fade_feedback_background()
						else:
							SignalHandler.emit_signal("note_hit", "GOOD", note_source)
							hit_feedback_background.material.set_shader_parameter("background_color", good_color)
							fade_feedback_background()
					else:
						current_note.queue_free()
						current_note = null
						var perfect_chance: int = randi_range(0, 100)
						if perfect_chance * 1.2 <= difficulty:
							SignalHandler.emit_signal("note_hit", "PERFECT", note_source)
							hit_feedback_background.material.set_shader_parameter("background_color", perfect_color)
							fade_feedback_background()
						else:
							SignalHandler.emit_signal("note_hit", "GOOD", note_source)
							hit_feedback_background.material.set_shader_parameter("background_color", good_color)
							fade_feedback_background()

func process_effect(effect: int) -> void:
	if !effect_active:
		match effect:
			0: #None
				pass
			1: #Note Speed Increase (+25%)
				note_spawn_position.position.y *= 1.25
				effect_active = true
				effect_cooldown_timer.start()
			2: #Note Fadeout
				note_fadeout = true
				effect_active = true
				effect_cooldown_timer.start()
			3: 
				pass

func _on_effect_cooldown_timeout() -> void:
	effect_active = false
	note_fadeout = false
	note_spawn_position.position.y = -1024 * GlobalData.global_settings["scroll_speed"]

func _on_miss_detector_area_entered(area: Area2D) -> void:
	if area.has_signal("process_starting_note_miss"):
		SignalHandler.emit_signal("note_hit", "MISS", note_source)
		area.emit_signal("process_starting_note_miss")
		if !in_editor:
			hit_feedback_background.material.set_shader_parameter("background_color", miss_color)
			fade_feedback_background()
	elif area.has_signal("process_ending_note_miss"):
		SignalHandler.emit_signal("note_hit", "MISS", note_source)
		if !in_editor:
			hit_feedback_background.material.set_shader_parameter("background_color", miss_color)
			fade_feedback_background()
	else:
		SignalHandler.emit_signal("note_hit", "MISS", note_source)
		if !in_editor:
			hit_feedback_background.material.set_shader_parameter("background_color", miss_color)
			fade_feedback_background()
