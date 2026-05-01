extends Node2D

class_name GameLogic

@onready var player_node: CharacterBody2D = $space_guy

@export var enemy: PackedScene

var score: int = 0

# enemy spawn rate in ms
@export var enemy_spawn_rate: float = 3
var enemy_spawn_timer: float

func _ready() -> void:
	enemy_spawn_timer = enemy_spawn_rate

func _physics_process(delta: float) -> void:
	enemy_spawn_timer -= delta
	if enemy_spawn_timer <= 0:
		spawn_enemy()
		enemy_spawn_timer = enemy_spawn_rate
	
func spawn_enemy():
	var look_direction = player_node.position.normalized()
	var new_enemy = enemy.instantiate() as Enemy
	new_enemy.position = calc_enemy_spawn_loc()
	new_enemy.player = player_node
	new_enemy.look_at(look_direction)
	get_tree().current_scene.add_child(new_enemy)
	
func calc_enemy_spawn_loc() -> Vector2:
	var spawn_radius = 100  # distance from player
	var random_angle = randf() * TAU  # TAU = 2*PI, full 360°
	var offset = Vector2(cos(random_angle), sin(random_angle)) * spawn_radius
	return player_node.position + offset
