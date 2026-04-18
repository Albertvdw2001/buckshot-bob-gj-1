extends CharacterBody2D
class_name Enemy

enum sizes { LARGE = 0, MEDIUM = 1, SMALL = 2 }

var size_health_mapping: Dictionary = {
	0: 100,
	1: 50,
	2: 25
}

var size_speed_mapping: Dictionary = {
	0: 5000,
	1: 7500,
	2: 10000
}

@onready var anim_sprite: AnimatedSprite2D = $AnimatedSprite2D
@export var size: sizes
@export var num_split: int = 2
@export var health: int = 100
@export var move_speed: float = 5000
@export var child_size_type: PackedScene = null
var player: CharacterBody2D

func _ready() -> void:
	move_speed = size_speed_mapping[size]
	health = size_health_mapping[size]

func _process(delta: float) -> void:
	if health <= 0:
		split()
		die()
	move_to_player(delta)

func take_damage(amount: int):
	health -= amount
	print("OUCH. health = ", health)

func die():
	if anim_sprite.animation != "dead":
		anim_sprite.animation = "dead"
	queue_free()

func move_to_player(delta):
	if not player:
		print("WARNING: Enemy will not attack or interact with player as player is null in enemy.gd.")
		return
	var direction = (player.global_position - global_position).normalized()
	velocity = direction * move_speed * delta
	look_at(direction)
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
	
