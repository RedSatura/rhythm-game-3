extends Node

#song validator
signal send_song_to_validator(path: String)
signal song_validated

#song statuses
signal song_started
signal song_ended

#file statuses
signal song_saved

signal send_user_song_file_paths(paths: Array)

#send initial song data
signal get_song_length(length: int)
signal get_song_offset(offset: float)
signal get_song_seconds_per_beat(seconds: float)

#send current song data
signal get_song_position(position: float)

#other data
signal get_hitspot_position(position: Vector2)

signal beat_occured(current_beat: int)
signal measure_occured

signal note_hit(grade: String)

signal note_missed

#errors
signal send_error(error: String)

#messages
signal send_message(message: String)

#status label (title screen)
signal clear_status_label

#title screen
signal reset_to_defaults

#song editor
signal update_editor_line_color(line: int, color: Color)
signal update_starting_song_beat(beat: int)

#themes
signal change_theme(theme: Theme)

#region note_lanes
signal spawn_note(lane: int)
signal disable_lane(lane: int, duration: int)
signal move_lane(lane: int, movement: int, duration: int)
signal update_lyric(text: String)

signal set_note_lane_setting_auto_mode(status: bool)

#region title_screen
signal toggle_show_title_screen_options(status: bool)
#endregion
