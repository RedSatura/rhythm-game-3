extends Control

var tutorial_messages: Array[String] = [
	"Welcome to Rhythm Game 3!",
	"Notes are white circles that move across the screen.",
	"Align the note with the grey circle on time to hit it!",
	"Next, we will introduce hold notes.",
	"Hold the note until it finishes!",
	"You have completed the tutorial. Enjoy!",
]

@export var tutorial_enabled: bool = true

func _ready() -> void:
	SignalHandler.connect("beat_occured", Callable(self, "beat_occured"))
	SignalHandler.connect("note_hit", Callable(self, "note_hit"))
	
func beat_occured(_pos: int) -> void:
	var tween: Tween = get_tree().create_tween()

func note_hit(_grade: String, _source: int) -> void:
	pass
