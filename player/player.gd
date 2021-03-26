extends KinematicBody2D
class_name Player

var id: int setget set_id
const speed = 200

func _ready():
	add_to_group("players")
	
	rset_config("position", MultiplayerAPI.RPC_MODE_REMOTESYNC)
	set_process(true)
	randomize()
	position = Vector2(rand_range(0, get_viewport_rect().size.x), rand_range(0, get_viewport_rect().size.y))

func _process(dt):
	if not is_network_master():
		return
	
	var direction =  Vector2(0, 0)
	if Input.is_action_pressed("ui_up"):
		direction += Vector2(0, -1)
	if Input.is_action_pressed("ui_down"):
		direction += Vector2(0, 1)
	if Input.is_action_pressed("ui_left"):
		direction += Vector2(-1, 0)
	if Input.is_action_pressed("ui_right"):
		direction += Vector2(1, 0)
	
	if not direction.is_equal_approx(Vector2(0, 0)):
		$animator.set_directionv(direction)
		$animator.play_directional("move")
		rset("position", position + direction.normalized() * speed * dt)
	else:
		$animator.play_directional("idle")
	
	
	if Input.is_action_just_pressed("ui_accept"):
		rpc("spawn_box", position)
	
	#if Input.is_mouse_button_pressed(BUTTON_LEFT):
	#	var direction = (get_viewport().get_mouse_position() - position).normalized()
	#	rpc("spawn_projectile", position, direction, Uuid.v4())

func set_id(new_id: int):
	set_network_master(new_id)
	id = new_id

remotesync func spawn_projectile(position, direction, name):
	var projectile = preload("res://examples/physics_projectile/physics_projectile.tscn").instance()
	projectile.set_network_master(1)
	projectile.name = name
	projectile.position = position
	projectile.direction = direction
	projectile.owned_by = self
	get_parent().add_child(projectile)
	return projectile

remotesync func spawn_box(position):
	var box = preload("res://examples/block/block.tscn").instance()
	box.position = position
	get_parent().add_child(box)

remotesync func kill():
	hide()
