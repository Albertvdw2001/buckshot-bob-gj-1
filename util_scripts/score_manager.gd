extends Node

class_name ScoreManager

const SAVE_PATH = "user://highscore.save"
var high_score = 0

func _ready():
	load_score()

func save_score():
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_var(high_score)
		file.close()

func load_score():
	if FileAccess.file_exists(SAVE_PATH):
		var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
		if file:
			high_score = file.get_var()
			file.close()

func update_score(new_score):
	if new_score > high_score:
		high_score = new_score
		save_score()
