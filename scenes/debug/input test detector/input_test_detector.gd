extends Node2D

func _ready() -> void:
	pass

func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("lane_left"):
		print_debug("Left")
	elif Input.is_action_just_pressed("lane_center_left"):
		print_debug("center_left")
	elif Input.is_action_just_pressed("lane_center_right"):
		print_debug("center_right")
	elif Input.is_action_just_pressed("lane_right"):
		print_debug("right")
