extends CharacterBody2D
class_name Enemy

enum sizes { LARGE = 0, MEDIUM = 1, SMALL = 2 }

var size_health_map: Dictionary = {
	0: 100,
	1: 50,
	2: 25
}

var size_speed_map: Dictionary = {
	0: 5000,
	1: 7500,
	2: 10000
}

@onready var collision: CollisionPolygon2D = $CollisionPolygon2D
@onready var anim_sprite: AnimatedSprite2D = $Body/AnimatedSprite2D
@onready var health_bar: ProgressBar = $HealthBar
@onready var Body:  Node2D = $Body
var hb_rel_x: float
var hb_rel_y: float

@export var size: sizes
@export var num_split: int = 2
@export var health: int = 100
@export var move_speed: float = 5000
@export var child_size_type: PackedScene = null
var player: Player

var inv_timer: float = 0.7

func _ready() -> void:
	move_speed = size_speed_map[size]
	health = size_health_map[size]
	health_bar.max_value = health
	set_health_bar(health)

func _process(delta: float) -> void:
	if inv_timer > 0:
		inv_timer -= delta
	if health <= 0:
		split()
		die()
	move_to_player(delta)

func take_damage(amount: int):
	if inv_timer > 0:
		return
	health -= amount
	set_health_bar(health)

func die():
	#if anim_sprite.animation != "dead":
#		anim_sprite.animation = "dead"
	player.take_damage(-1)
	queue_free()

func move_to_player(delta):
	if not player:
		print("WARNING: Enemy will not attack or interact with player as player is null in enemy.gd.")
		return
	var direction = (player.global_position - global_position).normalized()
	velocity = direction * move_speed * delta
	Body.look_at(direction)
	move_and_slide()

func split():
	if not child_size_type:
		return
	for i in num_split:
		var new_child = child_size_type.instantiate() as Enemy
		new_child.player = player
		if i % 2 == 0:
			new_child.global_position = global_position + Vector2(5, 0) # todo: calculation
		else:
			new_child.global_position = global_position - Vector2(5, 0)
		get_parent().get_tree().current_scene.add_child(new_child)

func set_health_bar(value: int):
	if not health_bar:
		return
	if value > health_bar.max_value:
		value = health_bar.max_value
	if value < health_bar.min_value:
		value = health_bar.min_value
	health_bar.value = value
