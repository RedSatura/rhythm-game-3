extends Button

func _on_toggled(toggled_on: bool) -> void:
	spin_icon(toggled_on)

func spin_icon(status: bool) -> void:
	if status:
		var tween: Tween = get_tree().create_tween()
		tween.tween_property(self, "rotation_degrees", 180, 0.25).set_trans(Tween.TRANS_ELASTIC)
		SignalHandler.emit_signal("toggle_show_title_screen_options", true)
	else:
		var tween: Tween = get_tree().create_tween()
		tween.tween_property(self, "rotation_degrees", 0, 0.25).set_trans(Tween.TRANS_ELASTIC)
		SignalHandler.emit_signal("toggle_show_title_screen_options", false)
