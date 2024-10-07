extends Button

@export_file var song_path: String = ""
@export var song_title: String = ""
@export var song_artist: String = ""
@export var song_difficulty: int = 5

@onready var title_scroll: Node = $TitleScroll
@onready var title_scroll_timer: Node = $TitleScroll/Timer
@onready var title_scroll_h: Node = $TitleScroll.get_h_scroll_bar()
@onready var title_label: Node = $TitleScroll/SongTitle

@onready var artist_scroll: Node = $ArtistScroll
@onready var artist_scroll_timer: Node = $ArtistScroll/ArtistScrollTimer
@onready var artist_scroll_h: Node = $ArtistScroll.get_h_scroll_bar()
@onready var artist_label: Node = $ArtistScroll/ArtistName

@onready var difficulty_label: Node = $Difficulty

var scrolling_enabled: bool = false
var artist_scrolling_enabled: bool = true
var on_focus: bool = false

enum ScrollState {
	BEGIN,
	MOVING,
	END,
}

enum ArtistScrollState {
	BEGIN,
	MOVING,
	END,
}

var scroll_state: int = ScrollState.BEGIN
var artist_scroll_state: int = ArtistScrollState.BEGIN

func _ready() -> void:
	SignalHandler.connect("song_validated", Callable(self, "song_validated"))
	title_label.text = song_title
	artist_label.text = song_artist
	difficulty_label.text = "Difficulty: " + str(song_difficulty)
	title_scroll_timer.start()
	artist_scroll_timer.start()

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
			
	match artist_scroll_state:
		ArtistScrollState.BEGIN:
			pass
		ArtistScrollState.MOVING:
			artist_scroll.scroll_horizontal += 1
			if artist_scroll.scroll_horizontal + 176 >= artist_scroll_h.max_value:
				artist_scroll_timer.start()
				artist_scroll_state = ArtistScrollState.END
		ArtistScrollState.END:
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

func _on_artist_scroll_timer_timeout() -> void:
	match artist_scroll_state:
		ArtistScrollState.BEGIN:
			artist_scrolling_enabled = true
			artist_scroll_state = ArtistScrollState.MOVING
		ArtistScrollState.MOVING:
			pass
		ArtistScrollState.END:
			artist_scroll_timer.start()
			artist_scroll.scroll_horizontal = 0
			artist_scroll_state = ArtistScrollState.BEGIN
