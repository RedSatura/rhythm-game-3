extends Area2D

var distance_to_target: Vector2 = Vector2.ZERO
var movement_speed: Vector2 = Vector2.ZERO

@onready var note_fadeout_timer: Node = $NoteFadeoutTimer
@onready var texture_rect: Node = $TextureRect

func _ready() -> void:
	#please do not change these numbers, i am an idiot, sorry
	#there's a separate option for scroll speed, use that instead
	movement_speed = Vector2(distance_to_target.x / 1.25, distance_to_target.y / 1.25)

func _physics_process(delta: float) -> void:
	self.position.x += movement_speed.x * delta
	self.position.y += movement_speed.y * delta

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	SignalHandler.emit_signal("note_missed")
	queue_free()

func _on_note_fadeout_timer_timeout() -> void:
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(texture_rect, "modulate", Color(1.0, 1.0, 1.0, 0.0), 0.2)
