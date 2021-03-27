extends KinematicBody2D
class_name Player

const SPEED = 100
const SWEATING_SPEED = 40
const TIME_SWEATING = 5
const PICKUP_DISTANCE = 16 * 1.5
const texture_paths = [
	"02",
	"bear",
	"bee",
	"bat",
	"28"
]

var id: int setget set_id
var texture_path: String setget _set_texture_path
var direction: Vector2 = Vector2(1, 0)
var sweating: bool = false setget _set_sweating
var time_until_death = TIME_SWEATING

enum Item { EMPTY, TREE, FLOWER }
var inventory_item = Item.EMPTY setget _set_item
enum Action { IDLE, PICKUP_TREE, PICKUP_FLOWER, PLACE, DYING }
var action = Action.IDLE



func _ready():
	add_to_group("players")
	rset_config("texture_path", MultiplayerAPI.RPC_MODE_REMOTESYNC)
	rset_config("position", MultiplayerAPI.RPC_MODE_REMOTE)
	rset_config("inventory_item", MultiplayerAPI.RPC_MODE_REMOTESYNC)
	rset_config("sweating", MultiplayerAPI.RPC_MODE_REMOTESYNC)
	
	$InventoryItem.visible = false
	
	set_process(true)
	randomize()
	
	if is_network_master():
		rset("texture_path", "res://resources/monsters/%s.png" % texture_paths[randi() % texture_paths.size()])

func _should_sweat():
	var position = get_global_transform().origin
	return Globals.get_level().is_burnt(position) or not Globals.get_level().has_gras(position)

func _physics_process(delta):
	if not is_network_master():
		return
	
	var should_sweat = _should_sweat()
	if sweating != should_sweat and action != Action.DYING:
		rset("sweating", should_sweat)
	
	if sweating:
		_sweat(delta)
	else:
		time_until_death = TIME_SWEATING
	
	if action != Action.IDLE:
		return
	
	if Input.is_action_just_released("interact"):
		try_interact()
		return
	
	var new_direction =  Vector2(0, 0)
	if Input.is_action_pressed("move_up"):
		new_direction += Vector2(0, -1)
	if Input.is_action_pressed("move_down"):
		new_direction += Vector2(0, 1)
	if Input.is_action_pressed("move_left"):
		new_direction += Vector2(-1, 0)
	if Input.is_action_pressed("move_right"):
		new_direction += Vector2(1, 0)
	
	if not new_direction.is_equal_approx(Vector2(0, 0)):
		direction = new_direction.normalized()
		$animator.set_directionv(direction)
		$animator.play_directional("move")
		var speed = SPEED if not sweating else SWEATING_SPEED
		move_and_slide(direction * speed)
		rset("position", position)
	else:
		$animator.play_directional("idle")

func _sweat(delta):
	time_until_death -= delta
	if time_until_death <= 0:
		_die()

func _die():
	action = Action.DYING
	rset("sweating", false)
	rpc("play_death_animation")
	$DeathTimer.start()

remotesync func play_death_animation():
	$animator.play_directional("death")

func try_interact():
	match inventory_item:
		Item.EMPTY:
			try_pickup()
		Item.TREE, Item.FLOWER:
			try_place()

func try_pickup():
	var closest_plant = null
	var closest_distance = INF
	
	for plant in Globals.get_level().get_forest():
		var distance = get_global_transform().origin.distance_squared_to(plant.get_global_transform().origin)
		if distance < closest_distance and plant.can_pick_up():
			closest_plant = plant
			closest_distance = distance
	closest_distance = sqrt(closest_distance)
	
	if closest_distance < PICKUP_DISTANCE:
		match closest_plant.type:
			Globals.PlantType.FLOWER:
				action = Action.PICKUP_FLOWER
			Globals.PlantType.TREE:
				action = Action.PICKUP_TREE
		$PickupTimer.start()
		rpc_unreliable("play_pickup_animation",  closest_plant.get_global_transform().origin - get_global_transform().origin)

func _placement_position():
	# Move up the position by 4, as the players hitbox is moved up by that amount
	return get_global_transform().origin + direction * 10 + Vector2(0, -4)

func try_place():
	if not Globals.get_level().can_place_flora(_placement_position()):
		return
	
	action = Action.PLACE
	$PickupTimer.start()
	rpc_unreliable("play_pickup_animation", direction)

remotesync func play_pickup_animation(dir: Vector2):
	$animator.set_directionv(dir)
	$animator.play_directional("attack")

func _set_texture_path(new_path: String):
	texture_path = new_path
	$Sprite.texture = load(self.texture_path)

func _set_item(new_item):
	inventory_item = new_item
	match inventory_item:
		Item.EMPTY:
			$InventoryItem.visible = false
		Item.TREE:
			$InventoryItem.texture = load(TreeInformation.get_healthy_texture())
			$InventoryItem.visible = true
		Item.FLOWER:
			$InventoryItem.texture = load(FlowerInformation.get_healthy_texture())
			$InventoryItem.visible = true

func _set_sweating(is_sweating: bool):
	sweating = is_sweating
	$SweatParticles.emitting = sweating

func set_id(new_id: int):
	set_network_master(new_id)
	id = new_id

remotesync func kill():
	hide()

func finish_place():
	if inventory_item == Item.TREE:
		Globals.get_level().rpc("place_flora", _placement_position(), Globals.PlantType.TREE)
	elif inventory_item == Item.FLOWER:
		Globals.get_level().rpc("place_flora", _placement_position(), Globals.PlantType.FLOWER)
	rset("inventory_item", Item.EMPTY)

func finish_pickup_flower():
	rset("inventory_item", Item.FLOWER)

func finish_pickup_tree():
	rset("inventory_item", Item.TREE)

func _on_PickupTimer_timeout():
	match action:
		Action.PLACE:
			finish_place()
		Action.PICKUP_FLOWER:
			finish_pickup_flower()
		Action.PICKUP_TREE:
			finish_pickup_tree()
	
	action = Action.IDLE


func _on_DeathTimer_timeout():
	Globals.get_game().rpc("respawn_player", self.id)
