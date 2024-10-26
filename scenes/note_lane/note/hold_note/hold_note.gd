extends Node2D

@export var duration: int = 4
@export var note_type: String = "HOLD"

var starting_position: Vector2 = Vector2.ZERO

var distance_to_target: Vector2 = Vector2.ZERO
var starting_movement_speed: Vector2 = Vector2.ZERO
var ending_movement_speed: Vector2 = Vector2.ZERO
var color_rect_movement_speed: Vector2 = Vector2.ZERO

var target_lane: String = ""
var note_source: int = 1

var is_held: bool = false

var note_collisions_disabled: bool = false

@onready var starting_note: Node = $StartingNote
@onready var ending_note: Node = $EndingNote
@onready var color_rect: Node = $ColorRect

func _ready() -> void:
	starting_movement_speed = Vector2(distance_to_target.x / 1.25, distance_to_target.y / 1.25)
	ending_movement_speed = Vector2(distance_to_target.x / 1.25, distance_to_target.y / 1.25)
	color_rect_movement_speed = Vector2(distance_to_target.x / 1.25, distance_to_target.y / 1.25)
	#ending_note.position.y = -100
	ending_note.position.y = ((GlobalData.global_settings["scroll_speed"] * -1024 / 4.0) * duration) / GlobalData.song_info["beat_mode"]
	color_rect.size.y = ((GlobalData.global_settings["scroll_speed"] * 1024 / 4.0) * duration) / GlobalData.song_info["beat_mode"]
	#color_rect.size.y = 100
	
func _physics_process(delta: float) -> void:
	if starting_note != null:
		starting_note.position.x += starting_movement_speed.x * delta
		starting_note.position.y += starting_movement_speed.y * delta
	if ending_note != null:
		ending_note.position.x += ending_movement_speed.x * delta
		ending_note.position.y += ending_movement_speed.y * delta
	if color_rect != null:
		color_rect.position.x += color_rect_movement_speed.x * delta
		color_rect.position.y += color_rect_movement_speed.y * delta
		
	if starting_note != null && ending_note != null && is_held:
		if starting_note.position.y <= ending_note.position.y: #this is a terrible idea but i'm out of ideas
			SignalHandler.emit_signal("hold_note_completed", note_source, target_lane)
			queue_free()
	
	if is_held:
		color_rect.size.y -= ending_movement_speed.y * delta

func process_hold_note_miss_release(_source: int) -> void:
	is_held = false
	self.modulate = Color(1.0, 1.0, 1.0, 0.5)
	starting_movement_speed = ending_movement_speed
	color_rect_movement_speed = ending_movement_speed
	ending_note.get_node("CollisionShape2D").set_deferred("disabled", true)

func _on_starting_note_process_starting_note_input(source: int, lane: String) -> void:
	target_lane = lane
	starting_movement_speed = Vector2.ZERO
	color_rect_movement_speed = Vector2.ZERO
	is_held = true
	note_source = source
	self.modulate = Color.MAGENTA

func _on_starting_note_process_starting_note_miss() -> void:
	is_held = false
	self.modulate = Color(1.0, 1.0, 1.0, 0.5)
	#starting_note.get_node("CollisionShape2D").set_deferred("disabled", true)
	starting_movement_speed = ending_movement_speed
	color_rect_movement_speed = ending_movement_speed
