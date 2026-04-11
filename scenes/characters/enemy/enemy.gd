extends CharacterBody2D

class_name Enemy

@onready var anim_sprite: AnimatedSprite2D = $AnimatedSprite2D

var player: CharacterBody2D
@export var health: int = 100
@export var move_speed: float = 5000

func _process(delta: float) -> void:
	if health <= 0:
		die()
	move_to_player(delta)


func take_damage(amount: int):
	health -= amount
	print("OUCH. health = ", health)


func die():
	if anim_sprite.animation != "dead":
		anim_sprite.animation = "dead"


func move_to_player(delta):
	if not player:
		print("WARNING: player is null in enemy.gd")
		return
	var direction = (player.global_position - global_position).normalized()
	velocity = direction * move_speed * delta
	look_at(direction)
	move_and_slide()
	
