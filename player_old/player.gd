extends Node2D
class_name Player_old

var id
var texture_path: String setget set_texture_path
const speed = 500
var grid_position: Vector2 setget set_grid_position, get_grid_position
const GRID_SIZE = Vector2(128, 128)
const OFFSET = Vector2(64, 30)

var look_direction = "right"

var role: String setget set_role

var health: float setget set_health
const MAX_HEALTH = 100.0

var popped_action

signal push_action(action)
signal pop_action(action, do_send)
signal is_idle()

func _ready():
	rset_config("grid_position", MultiplayerAPI.RPC_MODE_REMOTESYNC)
	rset_config("health", MultiplayerAPI.RPC_MODE_REMOTESYNC)
	rset_config("action_queue", MultiplayerAPI.RPC_MODE_REMOTESYNC)
	set_process(true)
	randomize()
	
	self.grid_position = Vector2(5, 5)
	self.position = self.target_world_position()
	
	set_health(100.0)
	
	$animator.play_directional("idle")
	
	$healthbar.max_value = MAX_HEALTH

func get_sync_state():
	# place all synced properties in here
	var properties = ['texture_path', 'grid_position', 'health', 'role']
	
	var state = {}
	for p in properties:
		state[p] = get(p)
	return state
	

func _process(delta):
	if false:
		if Input.is_mouse_button_pressed(BUTTON_LEFT):
			rpc_unreliable("attack_animation")
	
	var target_position = self.target_world_position()
	var direction = target_position - self.get_global_transform().get_origin()
	
	var velocity = Vector2(0, 0)
	if direction.length() > 5:
		velocity = direction.normalized() * speed
		if $animator.get_current_animation().begins_with('idle'):
			$animator.play_directional('move')
	self.position += velocity * delta

func set_role(new_role):
	role = new_role
	var strategy = load("res://player/" + role + "_strategy.tscn").instance()
	add_child(strategy)
	strategy.set_player(self)

func move(move_vector: Vector2):
	if move_vector.length() > 0:
		var new_position = grid_position + move_vector
		if not Globals.get_room().is_solid(new_position):
			rset('grid_position', new_position)
			if Globals.get_room().get_attribute_at_position_default(self.grid_position, "abyss", false):
				self.die(true)
	

func set_texture_path(_texture_path: String):
	texture_path = _texture_path
	$Sprite.texture = load(self.texture_path)

func modify_health(delta: float):
	rset('health', min(MAX_HEALTH, max(0, health + delta)))
	if delta < 0:
		rpc_unreliable("damage_animation")
	if health <= 0:
		die(false)
	
remotesync func damage_animation():
	$blood_particles.emitting = true

func set_health(new_health: float):
	health = new_health
	$healthbar.value = health

func attack(direction: Vector2):
	rpc_unreliable('attack_animation', direction)
	
	for object in Globals.get_room().get_objects_at(self.grid_position + direction):
		if object.has_method('modify_health'):
			object.modify_health(-Globals.DAMAGE_PLAYER_ATTACK)

remotesync func attack_animation(direction: Vector2):
	$animator.set_directionv(direction)
	$animator.play_directional('attack')

func die(falling: bool):
	self.remove_from_group('players')
	self.remove_from_group('grid_object')
	
	rpc('display_death', falling)
	
	var timer = Timer.new()
	timer.connect("timeout", self, "_on_respawn")
	add_child(timer)
	timer.set_wait_time(2)
	timer.one_shot = true
	timer.start()

func _on_respawn():
	rpc('remove')
	Globals.get_game().spawn_new_player_with_role(self.id, "monster")

remotesync func remove():
	self.queue_free()

remotesync func display_death(falling: bool):
	# necessary to free up the player id on all clients so we can create a new player
	self.name = "corpse_" + String(self.id)
	$animator.set_falling_animation(falling)
	$animator.play_directional("death")
	$controls.queue_free()
	$information.queue_free()
	$healthbar.queue_free()

func _on_animator_animation_finished(anim_name):
	if anim_name != 'idle':
		$animator.play_directional('idle')
	emit_signal("is_idle")

func wait_idle():
	if $animator.get_current_animation().begins_with('idle'):
		return true
	yield(self, "is_idle")
	return true

func get_grid_position():
	return grid_position

func set_grid_position(new_position):
	$animator.set_directionv(new_position - grid_position)
	grid_position = new_position

func target_world_position():
	return self.grid_position * GRID_SIZE + OFFSET

remotesync func set_controls_visibility(_visible: bool):
	var controls = self.get_node("controls")
	controls.visible = _visible

# OK, the below is sort of nasty. Long story short we need to get info
# to and from Server Player and Client Player.Queue
# There may be a better way to do this, but if it works; it works.
func push_action(action): # action: Globals.ACTIONS
	emit_signal("push_action", action)

# Pop is more complicated, we need to send the request over, and then
# get back a response....
# SP == Server Player, CP == Client Player
# SQ == Server Queue, CQ == Client Queue
# The route is SP uses RPC to CP, CP uses signal to CQ
# which uses rset and signal to send to SQ which
# then does a signal back to SP.
# Again; I'm sure there is a better way..... but if it works.
func do_move():
	# same as pop action, call this one
	# same as pop action, call this one
	# SP calling rpc to CP
	if self.is_network_master():
		var actions = $information/queue.actions
		if actions.size() > 0:
			match actions[0]:
				Globals.ACTIONS.move_up:
					self.move(Vector2(0, -1))
				Globals.ACTIONS.move_down:
					self.move(Vector2(0, 1))
				Globals.ACTIONS.move_left:
					self.move(Vector2(-1, 0))
				Globals.ACTIONS.move_right:
					self.move(Vector2(1, 0))

func do_atk():
	if self.is_network_master():
		var actions = $information/queue.actions
		if actions.size() > 0:
			match actions[0]:
				Globals.ACTIONS.atk_up:
					self.attack(Vector2(0, -1))
				Globals.ACTIONS.atk_down:
					self.attack(Vector2(0, 1))
				Globals.ACTIONS.atk_left:
					self.attack(Vector2(-1, 0))
				Globals.ACTIONS.atk_right:
					self.attack(Vector2(1, 0))

func do_pop():
	if self.is_network_master():
		rpc_id(self.id, "local_pop_action")

	
remotesync func local_pop_action():
	# here we are CP sending a signal to CQ
	if is_network_master() and self.id != 1:
		return # Master doesn't care, unless it's masters player
	emit_signal("pop_action", true)

func _on_push_action(action):
	pass # Replace with function body.
