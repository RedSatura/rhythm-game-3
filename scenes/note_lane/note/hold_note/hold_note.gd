extends Area2D

@export var duration: int = 4

var distance_to_target: Vector2 = Vector2.ZERO
var movement_speed: Vector2 = Vector2.ZERO

var is_held: bool = false

func _ready() -> void:
	#please do not change these numbers, i am an idiot, sorry
	#there's a separate option for scroll speed, use that instead
	movement_speed = Vector2(distance_to_target.x / 1.25, distance_to_target.y / 1.25)

func _physics_process(delta: float) -> void:
	self.position.x += movement_speed.x * delta
	self.position.y += movement_speed.y * delta
