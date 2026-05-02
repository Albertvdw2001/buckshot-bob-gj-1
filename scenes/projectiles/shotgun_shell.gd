extends Area2D
class_name ShotgunShell

@export var movement_speed: float = 500
@export var damage: int = 30
var timer
var lifespan_sec: float = 4

var direction: Vector2 = Vector2.RIGHT

func _ready() -> void:
	look_at(direction)
	body_entered.connect(_on_entered)

func _physics_process(delta: float) -> void:
	timer += delta
	damage -= timer * 2
	lifespan_sec -= delta
	if lifespan_sec <= 0:
		queue_free()
	apply_movement(delta)

func _on_entered(body: Node):
	if body is Enemy:
		body.take_damage(damage)
		queue_free()

func is_attack_released() -> bool:
	return not Input.is_action_pressed("attack")

func apply_movement(delta: float):
	global_position += direction * movement_speed * delta
