extends Node

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
