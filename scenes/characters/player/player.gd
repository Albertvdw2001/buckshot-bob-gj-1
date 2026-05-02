extends CharacterBody2D
class_name Player

@export var ext: PackedScene

# Objects
@onready var body_sprite = $Body
@onready var stamina_bar: ProgressBar = $StaminaBar
@onready var shells_bar: HBoxContainer = $CanvasLayer/HBoxContainer
var shells_children: Array[Node]
var game: GameLogic

# global params
var move_speed = 5000

# internal params
var current_ext
var mouse_pos
var has_weapon = false
var health: int = 1
var invincibility_timer: float = 0
var flicker_anim = false
var is_dodging = false
var invincibility_sec: float = 1

# dash mechanic
var dash_speed = 600
var dash_time = 0.15
var dash_cooldown_time = 0
var dash_timer = 0.0
var is_dashing = false
var dash_direction = Vector2.ZERO
var stamina = 100
var stamina_refill_per_200ms: int = 2
var stamina_refill_ticker: float = 0
var dash_stamina_cost: int = 30

func _ready() -> void:
	if ext:
		equip_ext(ext)
	shells_children = shells_bar.get_children()
	update_shells_bar(1)
	game = get_parent() as GameLogic

func _physics_process(delta: float) -> void:
	print(get_amount_shells())
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

	if not is_dodging and dash_cooldown_time <= 0:
		stamina_refill_ticker += delta
		if stamina_refill_ticker >= 0.2:
			set_stamina(stamina + stamina_refill_per_200ms)
	apply_movenent(delta)

	if (velocity.x != 0 or velocity.y != 0):
		play_walk_animation()
	else:
		play_idle_animation()

func _input(event):
	if event.is_action_pressed("dash") and not is_dashing:
		start_dash()

func update_shells_bar(amount: int):
	if amount > 8:
		amount = 8
	if amount < 0:
		amount = 0
	for i in range(shells_children.size()):
		shells_children[i].visible = i < amount

func apply_movenent(delta: float):
	if has_weapon:
		mouse_pos = get_local_mouse_position()
	if dash_cooldown_time > 0:
		dash_cooldown_time -= delta
	if dash_cooldown_time < 0:
		dash_cooldown_time = 0
	if is_dashing:
		velocity = dash_direction * dash_speed
		dash_timer -= delta
		if dash_timer <= 0:
			dash_cooldown_time = 3
			is_dashing = false
	else:
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
	if not current_ext:
		return
	var shotgun = current_ext as Shotgun
	if shotgun:
		if shotgun.amount_shells == 0:
			return
		var new_amount = shotgun.amount_shells - amount
		if new_amount == 0:
			die()
		elif new_amount > 8:
			return
		shotgun.amount_shells = new_amount
		game.on_player_shells_changed(shotgun.amount_shells)
		update_shells_bar(shotgun.amount_shells)

func die():
	game.on_player_death()

func handle_collision():
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		if collision.get_collider() is Enemy:
			take_damage(1)
			start_invincibility_timer(invincibility_sec)

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

func start_dash():
	if stamina == 0:
		return
	is_dashing = true
	set_stamina(stamina - dash_stamina_cost)
	dash_timer = dash_time
	# Use current movement input
	dash_direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	# If no input, dash forward (optional fallback)
	if dash_direction == Vector2.ZERO:
		dash_direction = Vector2.RIGHT # or last movement direction
	dash_direction = dash_direction.normalized()

func set_stamina(value: int):
	if stamina_bar and value > stamina_bar.max_value:
		value = stamina_bar.max_value
	if stamina_bar and value < stamina_bar.min_value:
		value = stamina_bar.min_value
	stamina = value
	if stamina_bar:
		stamina_bar.value = stamina
