extends Node2D

@export var projectile: PackedScene
@export var is_static_projectile: bool # melee
# whether an extension with a non-static projectile is automatic (hold attack) or semi-automatic (fire one per attack press)
@export var is_automatic: bool = true
@export var fire_rate_per_sec: float = 3

# this value should be the name of the attack animation connected to the sprite
@export var shoot_animation: String = "attack"
@export var default_animation: String = "default"

@onready var projectile_slot: Node2D = $ProjectileSlot
@onready var anim_sprite: AnimatedSprite2D = $AnimatedSprite2D

var fire_timer: float = 0.0
var amount_bullets = 1
var mouse_pos
var is_shooting: bool = false

func _ready() -> void:
	anim_sprite.animation_finished.connect(_on_animation_finished)

func _physics_process(delta: float) -> void:
	apply_look_point_direction()
	if is_automatic and is_automatic_interval() and Input.is_action_pressed("attack"):
		fire_timer += delta
		spawn_projectile()
	elif Input.is_action_just_pressed("attack") and not is_shooting:
		shoot()

func shoot():
	if (!is_shooting and anim_sprite.animation != shoot_animation):
		is_shooting = true
		anim_sprite.play(shoot_animation)
		#anim_sprite.animation = default_animation

# points extension front x to where mouse is
func apply_look_point_direction():
	look_at(get_global_mouse_position())
	var relative_mouse_pos = Node2dUtils.get_relative_global_mouse_pos(self)
	anim_sprite.flip_v = relative_mouse_pos.x < 0


# spawns (or rather "instantiates") a new instance of object assigned to 'projectile'
# inside 'projectile_slot'
func spawn_projectile():
	var new_projectile = projectile.instantiate() as ProjectileBase
	new_projectile.is_static = is_static_projectile
	if is_static_projectile:
		#new_projectile.position = projectile_slot.position
		projectile_slot.add_child(new_projectile)
	else:
		new_projectile.direction = Vector2.RIGHT.rotated(projectile_slot.global_rotation)
		new_projectile.global_position = projectile_slot.global_position
		get_tree().current_scene.add_child(new_projectile)


# helper method that checks whether an automatic projectile should be fired or not
# returns true if enough time has passed since the last shot (based on fire_rate_per_sec)
func is_automatic_interval() -> bool:
	var interval = 1.0 / fire_rate_per_sec
	if fire_timer >= interval:
		fire_timer = 0.0
		return true
	return false


func _on_animation_finished():
	if anim_sprite.animation == shoot_animation:
		anim_sprite.play(default_animation)
		is_shooting = false
