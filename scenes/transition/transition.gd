extends ColorRect

var scene_path: String = ""

func _ready() -> void:
	SignalHandler.connect("set_transition_status", Callable(self, "set_transition_status"))
	self.visible = true
	set_transition_status(true)

func set_transition_status(status: bool, path: String = "") -> void:
	if status:
		var tween: Tween = get_tree().create_tween()
		tween.tween_property(self, "position", Vector2(-1280, 0), 0.5).set_trans(Tween.TRANS_SINE)
	else:
		if ResourceLoader.exists(path):
			scene_path = path
			var tween: Tween = get_tree().create_tween()
			tween.tween_property(self, "position", Vector2(0, 0), 0.5).set_trans(Tween.TRANS_SINE)
			tween.connect("finished", change_scene)

func change_scene() -> void:
	if get_tree():
		get_tree().change_scene_to_file(scene_path)
