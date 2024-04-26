extends Area2D

@export var note_speed = 1.0
@export var note_damage = 25

var distance_to_target = Vector2.ZERO
var movement_speed = Vector2.ZERO

func _ready():
	movement_speed = Vector2(distance_to_target.x / note_speed, distance_to_target.y / note_speed)

func _physics_process(delta):
	self.position.x += movement_speed.x * delta
	self.position.y += movement_speed.y * delta

func _on_visible_on_screen_notifier_2d_screen_exited():
	SignalHandler.emit_signal("note_missed")
	queue_free()
