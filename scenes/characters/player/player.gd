extends CharacterBody2D
class_name Player

# test
@export var ext: PackedScene

# Objects
@onready var body_sprite = $Body

# global params
var move_speed = 5000

# internal params
var current_ext
var mouse_pos
var has_weapon = false
var health: int = 1 # this refer to shells but for reuse purposes im calling it health
var invincibility_timer: float = 0
var flicker_anim = false

func _ready() -> void:
	print("_ready")
	if ext:
		equip_ext(ext)

func _physics_process(delta: float) -> void:
	if invincibility_timer <= 0:
		invincibility_timer = 0
		handle_collision()
	else:
		if not flicker_anim:
			play_flicker_anim(0.3)
		invincibility_timer -= delta
	has_weapon = current_ext != null
	if get_amount_shells() <= 0:
		die()
	apply_movenent(delta)
	if (velocity.x != 0 or velocity.y != 0):
		play_walk_animation()
	else:
		play_idle_animation()


func apply_movenent(delta: float):
	if has_weapon:
		mouse_pos = get_local_mouse_position()
	var x_move = Input.get_axis("ui_left", "ui_right") * move_speed * delta
	var y_move = Input.get_axis("ui_up", "ui_down") * move_speed * delta
	velocity = Vector2(x_move, y_move)
	apply_body_look_direction()
	move_and_slide()


func play_walk_animation():
	if (body_sprite.animation != "walk"):
		body_sprite.play("walk")


func play_idle_animation():
	if (body_sprite.animation != "idle"):
		body_sprite.play("idle")


func equip_ext(ext_scene: PackedScene):
	if (current_ext):
		current_ext.queue_free()
	current_ext = ext_scene.instantiate() as Shotgun
	current_ext.amount_shells = health
	add_child(current_ext)


func apply_body_look_direction():
	if (has_weapon):
		if (mouse_pos.x < 0):
			body_sprite.flip_h = true
		else:
			body_sprite.flip_h = false
	else:
		if (velocity.x < 0):
			body_sprite.flip_h = true
		else:
			body_sprite.flip_h = false

func get_amount_shells() -> int:
	if current_ext:
		var shotgun = current_ext as Shotgun
		if shotgun:
			return shotgun.amount_shells
	return 0

func take_damage(amount: int):
	if current_ext:
		var shotgun = current_ext as Shotgun
		if shotgun:
			shotgun.amount_shells -= amount

func die():
	return

func handle_collision():
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		if collision.get_collider() is Enemy:
			take_damage(1)
			start_invincibility_timer(3)

func start_invincibility_timer(seconds: int):
	invincibility_timer = seconds

func play_flicker_anim(interval: float):
	if invincibility_timer <= 0:
		visible = true
		return
	flicker_anim = true
	visible = false
	await get_tree().create_timer(interval).timeout
	visible = true
	await get_tree().create_timer(interval).timeout
	flicker_anim = false
