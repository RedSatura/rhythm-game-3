extends Panel

@onready var fade_bar: Node = $FadeBar
@onready var fade_timer: Node = $FadeTimer

func _ready() -> void:
	fade_bar.max_value = fade_timer.wait_time
	
func _process(_delta: float) -> void:
	fade_bar.value = fade_timer.time_left

func _on_close_pressed() -> void:
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(self, "modulate", Color(self.modulate, 0), 0.5)
	tween.tween_callback(queue_free)

func update_message(type: int = 0, message: String = "") -> void:
	match type:
		0: #messages
			$Message.text = message
			get_theme_stylebox("panel", "MessageDisplay").border_width_right = 0
			if fade_timer:
				fade_timer.start(3)
			if fade_bar:
				fade_bar.visible = true
		1: #errors
			$Message.text = message
			get_theme_stylebox("panel", "MessageDisplay").border_width_right = 4
		_:
			pass

func _on_fade_timer_timeout() -> void:
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(self, "modulate", Color(self.modulate, 0), 0.5)
	tween.tween_callback(queue_free)
