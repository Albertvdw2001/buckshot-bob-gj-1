extends CharacterBody2D

class_name Enemy

@onready var anim_sprite: AnimatedSprite2D = $AnimatedSprite2D

@export var health: int = 100

func _process(delta: float) -> void:
	if health <= 0:
		die()


func take_damage(amount: int):
	health -= amount
	print("OUCH. health = ", health)


func die():
	if anim_sprite.animation != "dead":
		anim_sprite.animation = "dead"
