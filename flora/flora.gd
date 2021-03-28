extends StaticBody2D
class_name Flora

const TIME_BETWEEN_SPREADINGS = 6
const MAX_SPREAD_DISTANCE = 7
const TIME_BURNING = 30
const TIME_PER_STAGE = 3
const MAX_GROWTH_STAGE = 3

const MAX_SYMBIOSIS_RADIUS = 5
const MAX_SYMBIOSIS_NUMBER = 7
const GRAS_RADIUS = 3.5
const BURNT_RADIUS = 3.5

export var growth_stage : int = 3 setget _set_growth_stage

enum FloraState { GROWING, BURNING, BURNT }

export(Globals.PlantType) var type = Globals.PlantType.TREE setget _set_plant_type
export(FloraState) var state = FloraState.GROWING setget _set_state

var time_until_growth = TIME_PER_STAGE
var time_until_fire_spreads = TIME_BETWEEN_SPREADINGS
var time_until_burnt = TIME_BURNING

var texture_path: String setget _set_texture_path

var rng = RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	set_network_master(1)
	rset_config("growth_stage", MultiplayerAPI.RPC_MODE_REMOTESYNC)
	rset_config("state", MultiplayerAPI.RPC_MODE_REMOTESYNC)
	rset_config("texture_path", MultiplayerAPI.RPC_MODE_REMOTESYNC)
	_set_growth_stage(growth_stage)
	_set_state(state)
	
	rng.randomize()
	
	if is_network_master():
		update_texture()

func _process(delta):
	if is_network_master():
		match state:
			FloraState.GROWING:
				_process_growing(delta)
			FloraState.BURNING:
				_process_burning(delta)

func _process_growing(delta):
	if growth_stage < MAX_GROWTH_STAGE:
		time_until_growth -= delta
		if time_until_growth <= 0:
			time_until_growth = TIME_PER_STAGE
			rset("growth_stage", growth_stage + 1)

func _process_burning(delta):
	time_until_fire_spreads -= delta
	time_until_burnt -= delta
	if time_until_fire_spreads <= 0:
		time_until_fire_spreads = TIME_BETWEEN_SPREADINGS + rng.randf_range(-1, 1)
		_spread_fire()
	if time_until_burnt <= 0:
		_burnt()

func _burnt():
	rset("state", FloraState.BURNT)
	rset("texture_path", _information().get_burnt_texture())

func _information():
	match type:
		Globals.PlantType.TREE:
			return TreeInformation
		Globals.PlantType.FLOWER:
			return FlowerInformation

func update_texture():
	match state:
		FloraState.BURNT:
			_set_texture_path(_information().get_burnt_texture())
		FloraState.GROWING, FloraState.BURNING:
			_set_texture_path(_information().get_healthy_texture())

func _set_plant_type(new_plant_type):
	type = new_plant_type
	set_collision_mask_bit(0, _information().can_collide())
	set_collision_layer_bit(0, _information().can_collide())

func start_burning():
	if is_network_master() and state == FloraState.GROWING:
		rset("state", FloraState.BURNING)

func can_pick_up():
	return state == FloraState.GROWING and growth_stage == MAX_GROWTH_STAGE

func _spread_fire():
	var closest_tree = null
	var closest_distance = INF
	
	for tree in Globals.get_level().get_forest():
		var distance = get_position().distance_squared_to(tree.get_position())
		if tree.state == FloraState.GROWING and distance < closest_distance:
			closest_tree = tree
			closest_distance = distance
	closest_distance = sqrt(closest_distance)
	
	var max_burning_distance = MAX_SPREAD_DISTANCE * Globals.PIXEL_PER_TILE
	var distance_proportion = closest_distance / max_burning_distance
	
	if closest_distance < max_burning_distance and rng.randf_range(-1, 1) < distance_proportion:
		closest_tree.start_burning()

func _set_growth_stage(new_stage: int):
	growth_stage = new_stage
	var scale = growth_stage as float / MAX_GROWTH_STAGE as float
	set_scale(Vector2(scale, scale))

func _set_state(new_state):
	state = new_state
	_set_surrounding_tiles()
	$Particles2D.emitting = state == FloraState.BURNING
	if state == FloraState.BURNING:
		#$AudioStreamPlayer2D.play()
		pass
	else:
		#$AudioStreamPlayer2D.stop()
		pass

func _gras_spread_radius():
	var symbiosis_count = Globals.get_level().get_surrounding_trees(get_position(), MAX_SYMBIOSIS_RADIUS * Globals.PIXEL_PER_TILE).size()
	return min(GRAS_RADIUS, GRAS_RADIUS * symbiosis_count / MAX_SYMBIOSIS_NUMBER)

func _set_surrounding_tiles():
	if Globals.get_level() == null:
		return
	
	if state != FloraState.BURNT and state != FloraState.GROWING:
		return
	
	var pos = get_position() / Globals.PIXEL_PER_TILE
		
	var radius = BURNT_RADIUS if state == FloraState.BURNT else _gras_spread_radius()
	var tile_type = Globals.Tile.DIRT if state == FloraState.BURNT else Globals.Tile.GRAS
	for x_offset in range(-radius, radius):
		for y_offset in range(-radius, radius):
			var offset = Vector2(x_offset, y_offset)
			if offset.length() <= radius:
				Globals.get_level().set_tile(pos + offset, tile_type)

func _set_texture_path(path: String):
	texture_path = path
	$Sprite.texture = load(texture_path)
