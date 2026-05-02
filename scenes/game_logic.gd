extends Node2D

class_name GameLogic

@onready var player_node: Player = $space_guy

@export var enemy: PackedScene

var score: int = 0

# enemy spawn rate in seconds
@export var enemy_spawn_rate: float = 4
@export var enemy_spawn_amount: int = 1
var enemy_spawn_timer: float

func _ready() -> void:
	enemy_spawn_timer = enemy_spawn_rate

func _physics_process(delta: float) -> void:
	print(player_node.get_amount_shells())
	enemy_spawn_timer -= delta
	if enemy_spawn_timer <= 0:
		for i in range(enemy_spawn_amount):
			spawn_enemy()
		enemy_spawn_timer = enemy_spawn_rate
	
func spawn_enemy():
	var new_enemy = enemy.instantiate() as Enemy
	new_enemy.position = calc_enemy_spawn_loc()
	new_enemy.player = player_node
	get_tree().current_scene.add_child(new_enemy)
	
func calc_enemy_spawn_loc() -> Vector2:
	var spawn_radius = randi_range(100, 3000)  # distance from player
	var random_angle = randf() * TAU  # TAU = 2*PI, full 360°
	var offset = Vector2(cos(random_angle), sin(random_angle)) * spawn_radius
	return player_node.position + offset

func on_player_shells_changed(amount_shells: int):
	enemy_spawn_amount = amount_shells

func on_player_death():
	get_tree().reload_current_scene()
