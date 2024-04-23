extends Area2D

@export var note_speed = 250
@export var note_damage = 25

func _ready():
	pass

func _physics_process(delta):
	self.global_position.y += note_speed * delta

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
