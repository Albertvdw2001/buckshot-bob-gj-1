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
	new_enemy.position = Vector2(5,5)
	new_enemy.player = player_node
	new_enemy.look_at(look_direction)
	get_tree().current_scene.add_child(new_enemy)
	
	
