extends Area2D

@export var note_speed: float = 1.0

var distance_to_target: Vector2 = Vector2.ZERO
var movement_speed: Vector2 = Vector2.ZERO

func _ready() -> void:
	movement_speed = Vector2(distance_to_target.x / note_speed, distance_to_target.y / note_speed)

func _physics_process(delta: float) -> void:
	self.position.x += movement_speed.x * delta
	self.position.y += movement_speed.y * delta

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	SignalHandler.emit_signal("note_missed")
	queue_free()
