extends Node2D

@export var lane_position = "LEFT"

@onready var note_spawn_position = $NoteSpawnPosition
@onready var note_cooldown_timer = $NoteCooldownTimer

@onready var hitspot = $Hitspot
@onready var hitspot_flash_cooldown = $Hitspot/HitspotFlashCooldown

var current_note = null

func spawn_note():
	var new_note = load("res://scenes/note_lane/note/note.tscn").instantiate()
	add_child(new_note)
	new_note.global_position = note_spawn_position.global_position
	
func _on_note_cooldown_timer_timeout():
	spawn_note()
	
func _unhandled_input(event):
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
				
func handle_input_on_note():
	hitspot.color.r = 0.5
	hitspot_flash_cooldown.start()
	if current_note != null:
		current_note.queue_free()
		current_note = null

func _on_note_detector_area_entered(area):
	current_note = area

func _on_note_detector_area_exited(area):
	current_note = null

func _on_hitspot_flash_cooldown_timeout():
	hitspot.color.r = 0.176
