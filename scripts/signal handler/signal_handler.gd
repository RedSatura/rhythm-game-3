extends Node

#song validator
signal send_song_to_validator(path)

#send initial song data
signal get_song_length(length)
signal get_song_offset(offset)

#send current song data
signal get_song_position(position)

#other data
signal get_hitspot_position(position)

signal beat_occured(current_beat)
signal measure_occured

signal note_hit(note_damage)

signal note_missed

#errors
signal send_error(error)

#status label (title screen)
signal clear_status_label
