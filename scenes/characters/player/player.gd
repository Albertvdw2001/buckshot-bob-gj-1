extends CharacterBody2D

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

func _ready() -> void:
	print("_ready")
	if ext:
		equip_ext(ext)

func _physics_process(delta: float) -> void:
	has_weapon = current_ext != null
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
	current_ext = ext_scene.instantiate()
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
