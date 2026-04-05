extends AnimatedSprite2D
class_name shotgun_shell

@export var movement_speed: float = 500

# damage that a single instance of the shell does per hit
@export var damage: int = 100


func _ready() -> void:
	body_entered.connect(on_entered)

func _physics_process(delta: float) -> void:
	apply_movement(delta)

func _on_entered(body: Node):
	if body is Enemy:
		body.take_damage(damage)


func is_attack_released() -> bool:
	return not Input.is_action_pressed("attack")


func apply_movement(delta: float):
	global_position += direction * movement_speed * delta
