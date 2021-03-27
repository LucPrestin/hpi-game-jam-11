extends KinematicBody2D
class_name Player

var id: int setget set_id
var texture_path: String setget _set_texture_path

enum Item { EMPTY, TREE, FLOWER }
var inventory_item = Item.EMPTY setget _set_item
enum Action { IDLE, PICKUP_TREE, PICKUP_FLOWER, PLACE }
var action = Action.IDLE

const SPEED = 100
const PICKUP_DISTANCE = 16 * 1.5
const texture_paths = [
	"02",
	"bear",
	"bee",
	"bat",
	"28"
	]

func _ready():
	add_to_group("players")
	rset_config("texture_path", MultiplayerAPI.RPC_MODE_REMOTESYNC)
	rset_config("position", MultiplayerAPI.RPC_MODE_REMOTE)
	rset_config("inventory_item", MultiplayerAPI.RPC_MODE_REMOTESYNC)
	
	$InventoryItem.visible = false
	
	set_process(true)
	randomize()
	
	if is_network_master():
		rset("texture_path", "res://resources/monsters/%s.png" % texture_paths[randi() % texture_paths.size()])

func _physics_process(_delta):
	if not is_network_master():
		return
	
	if action != Action.IDLE:
		return
	
	if Input.is_action_just_released("interact"):
		try_interact()
		return
	
	var direction =  Vector2(0, 0)
	if Input.is_action_pressed("move_up"):
		direction += Vector2(0, -1)
	if Input.is_action_pressed("move_down"):
		direction += Vector2(0, 1)
	if Input.is_action_pressed("move_left"):
		direction += Vector2(-1, 0)
	if Input.is_action_pressed("move_right"):
		direction += Vector2(1, 0)
	
	if not direction.is_equal_approx(Vector2(0, 0)):
		$animator.set_directionv(direction)
		$animator.play_directional("move")
		move_and_slide(direction.normalized() * SPEED)
		rset("position", position)
	else:
		$animator.play_directional("idle")

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

func try_place():
	# TODO
	action = Action.PLACE
	$PickupTimer.start()
	rpc_unreliable("play_pickup_animation", Vector2(1, 0))

remotesync func play_pickup_animation(direction: Vector2):
	$animator.set_directionv(direction)
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
			$InventoryItem.texture = load(TreeTextures.get_healthy_texture())
			$InventoryItem.visible = true
		Item.FLOWER:
			$InventoryItem.texture = load(FlowerTextures.get_healthy_texture())
			$InventoryItem.visible = true

func set_id(new_id: int):
	set_network_master(new_id)
	id = new_id

remotesync func kill():
	hide()

func finish_place():
	if inventory_item == Item.TREE:
		Globals.get_level().rpc("place_tree", get_global_transform().origin)
	elif inventory_item == Item.FLOWER:
		Globals.get_level().rpc("place_flower", get_global_transform().origin)
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
