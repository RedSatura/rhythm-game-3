extends Button

@export_file var song_path: String = ""
@export var song_title: String = ""
@export var song_artist: String = ""
@export var song_difficulty: int = 5

@onready var title_scroll: Node = $TitleScroll
@onready var title_scroll_timer: Node = $TitleScroll/Timer
@onready var title_scroll_h: Node = $TitleScroll.get_h_scroll_bar()
@onready var title_label: Node = $TitleScroll/SongTitle
@onready var artist_label: Node = $ArtistName
@onready var difficulty_label: Node = $Difficulty

var scrolling_enabled: bool = false
var on_focus: bool = false

enum ScrollState {
	BEGIN,
	MOVING,
	END,
}

var scroll_state: int = ScrollState.BEGIN

func _ready() -> void:
	SignalHandler.connect("song_validated", Callable(self, "song_validated"))
	title_label.text = song_title
	artist_label.text = song_artist
	difficulty_label.text = "Difficulty: " + str(song_difficulty)
	title_scroll_timer.start()

func _on_pressed() -> void:
	SignalHandler.emit_signal("send_song_to_validator", song_path)
	
func song_validated() -> void:
	if on_focus:
		SignalHandler.emit_signal("set_transition_status", false, "res://scenes/stage/stage.tscn")

func _process(_delta: float) -> void:
	match scroll_state:
		ScrollState.BEGIN:
			pass
		ScrollState.MOVING:
			title_scroll.scroll_horizontal += 1
			if title_scroll.scroll_horizontal + 432 >= title_scroll_h.max_value:
				title_scroll_timer.start()
				scroll_state = ScrollState.END
		ScrollState.END:
			pass

func _on_timer_timeout() -> void:
	match scroll_state:
		ScrollState.BEGIN:
			scrolling_enabled = true
			scroll_state = ScrollState.MOVING
		ScrollState.MOVING:
			pass
		ScrollState.END:
			title_scroll_timer.start()
			title_scroll.scroll_horizontal = 0
			scroll_state = ScrollState.BEGIN

func _on_focus_entered() -> void:
	GlobalData.song_info["video_src"] = ""
	SignalHandler.emit_signal("send_song_to_validator", song_path)
	on_focus = true

func _on_focus_exited() -> void:
	on_focus = false
