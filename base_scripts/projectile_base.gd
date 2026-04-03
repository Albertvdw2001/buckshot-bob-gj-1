class_name ProjectileBase

extends Area2D

var direction: Vector2 = Vector2.RIGHT

# false if projectile is not a moving projectile (e.g. a bullet) with its own, independant movement
# true if projectile sticks to weapon (e.g. taser electric shock)
@export var is_static: bool = false

@export var attack_animation_string: String = "attack"

# speed at which a non-static projectile moves
@export var movement_speed: float = 500

# damage that a single instance of the projectile does per
@export var damage: int = 100

# for static projectiles. interval at which damage is applied
@export var static_damage_interval_sec: float


func _physics_process(delta: float) -> void:
	if is_static:
		if is_attack_released():
			queue_free()
	else:
		apply_movement(delta)


func _ready() -> void:
	body_entered.connect(on_entered)


func on_entered(body: Node):
	if body is Enemy:
		body.take_damage(damage)


func is_attack_released() -> bool:
	return not Input.is_action_pressed("attack")


func apply_movement(delta: float):
	global_position += direction * movement_speed * delta
