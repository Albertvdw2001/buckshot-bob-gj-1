extends Control

@onready var start_btn: Button = $Button
@onready var high_score_lbl: Label = $Label
@onready var score_manager: ScoreManager = $ScoreManager

@export var start_scene_path: String = "res://scenes/main.tscn"

func _ready() -> void:
	start_btn.pressed.connect(_start_game)
	high_score_lbl.text = "High Score: " +  str(score_manager.high_score)

func _process(delta: float) -> void:
	$Background.scroll_offset.y -= 100 * delta

func _start_game():
	get_tree().change_scene_to_file(start_scene_path)
