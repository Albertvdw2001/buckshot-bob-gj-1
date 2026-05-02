extends Node2D
class_name Shotgun

@export var bullet_scene: PackedScene

# this value should be the name of the attack animation connected to the sprite
@export var shoot_animation: String = "attack"
@export var default_animation: String = "default"
@export var reload_animation: String = "reload"

@onready var shell_spawner: Node2D = $ShellSpawner
@onready var anim_sprite: AnimatedSprite2D = $AnimatedSprite2D

var fire_timer: float = 0.0
@export var amount_shells = 3
@export var max_shells = 8
@export var total_shot_spread: float = 30
var mouse_pos
var is_shooting: bool = false

var is_disabled: bool = false


func _ready() -> void:
	anim_sprite.animation_finished.connect(_on_animation_finished)

func _physics_process(delta: float) -> void:
	apply_look_point_direction()
	if Input.is_action_just_pressed("attack") and not is_shooting:
		shoot()

func shoot():
	if (is_shooting) or (anim_sprite.animation == shoot_animation) or (anim_sprite.animation == reload_animation):
		return
	shoot_shells()
	is_shooting = true
	anim_sprite.play(shoot_animation)

# points shotgun front x to where mouse is and applies vertical flip to avoid being upside down
func apply_look_point_direction():
	look_at(get_global_mouse_position())
	var relative_mouse_pos = Node2dUtils.get_relative_global_mouse_pos(self)
	anim_sprite.flip_v = relative_mouse_pos.x < 0

func shoot_shells():
	if amount_shells == 1:
		spawn_shell()
		return
	var deg_between_shells = calc_deg_between_shells(amount_shells)
	var max_angle_offset = 0
	var min_angle_offset = 0
	if amount_shells % 2 == 0:
		for shell_num in range(amount_shells):
			var direction = Vector2.RIGHT.rotated(shell_spawner.global_rotation) #straight
			if shell_num % 2 == 0:
				max_angle_offset += deg_between_shells
				direction = Vector2.RIGHT.rotated(shell_spawner.global_rotation + deg_to_rad(max_angle_offset))
			else:
				min_angle_offset -= deg_between_shells
				direction = Vector2.RIGHT.rotated(shell_spawner.global_rotation + deg_to_rad(min_angle_offset))
			spawn_shell(direction)
	else:
		for shell_num in range(amount_shells):
			var direction = Vector2.RIGHT.rotated(shell_spawner.global_rotation) #straight
			if shell_num != 1:
				if shell_num % 2 == 0:
					max_angle_offset += deg_between_shells
					direction = Vector2.RIGHT.rotated(shell_spawner.global_rotation + deg_to_rad(max_angle_offset))
				else:
					min_angle_offset -= deg_between_shells
					direction = Vector2.RIGHT.rotated(shell_spawner.global_rotation + deg_to_rad(min_angle_offset))
			spawn_shell(direction)

func inc_shells(amount: int):
	if amount_shells < 8:
		amount_shells += amount

# spawns ("instantiates") a new instance of object assigned to bullet_scene
# inside shell_spawnera
func spawn_shell(direction = null):
	if not direction:
		direction = Vector2.RIGHT.rotated(shell_spawner.global_rotation)
	var new_shell = bullet_scene.instantiate() as ShotgunShell
	new_shell.direction = direction
	new_shell.global_position = shell_spawner.global_position
	get_tree().current_scene.add_child(new_shell)

# helper method for calculating spread between shells based on amount_shells
func calc_deg_between_shells(amount_shells: int) -> float:
	#var half = total_shot_spread / 2
	return total_shot_spread / amount_shells
	#todo: refine

func _on_animation_finished():
	if anim_sprite.animation == shoot_animation:
		print("switch to reload")
		is_shooting = false
		anim_sprite.play(reload_animation)
	elif anim_sprite.animation == reload_animation:
		print("switch to default")
		anim_sprite.play(default_animation)
