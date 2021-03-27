extends StaticBody2D
class_name Flora

const TIME_BETWEEN_SPREADINGS = 7
const TIME_BURNING = 10
const TIME_PER_STAGE = 3
const MAX_GROWTH_STAGE = 3
const GRAS_RADIUS = 3
const BURNT_RADIUS = 3

export var growth_stage : int = 3 setget _set_growth_stage

enum FloraState { GROWING, BURNING, BURNT }

export(Globals.PlantType) var type = Globals.PlantType.TREE setget _set_plant_type
export(FloraState) var state = FloraState.GROWING setget _set_state

var time_until_growth = TIME_PER_STAGE
var time_until_fire_spreads = TIME_BETWEEN_SPREADINGS
var time_until_burnt = TIME_BURNING

var texture_path: String setget _set_texture_path

# Called when the node enters the scene tree for the first time.
func _ready():
	set_network_master(1)
	rset_config("growth_stage", MultiplayerAPI.RPC_MODE_REMOTESYNC)
	rset_config("state", MultiplayerAPI.RPC_MODE_REMOTESYNC)
	rset_config("texture_path", MultiplayerAPI.RPC_MODE_REMOTESYNC)
	_set_growth_stage(growth_stage)
	_set_state(state)
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
		time_until_fire_spreads = TIME_BETWEEN_SPREADINGS
		_spread_fire()
	if time_until_burnt <= 0:
		_burnt()

func _burnt():
	rset("state", FloraState.BURNT)
	rset("texture_path", _textures().get_burnt_texture())

func _textures():
	match type:
		Globals.PlantType.TREE:
			return TreeTextures
		Globals.PlantType.FLOWER:
			return FlowerTextures

func update_texture():
	match state:
		FloraState.BURNT:
			_set_texture_path(_textures().get_burnt_texture())
		FloraState.GROWING, FloraState.BURNING:
			_set_texture_path(_textures().get_healthy_texture())

func _set_plant_type(new_plant_type):
	type = new_plant_type

func start_burning():
	if is_network_master() and state == FloraState.GROWING:
		rset("state", FloraState.BURNING)

func can_pick_up():
	return state == FloraState.GROWING and growth_stage == MAX_GROWTH_STAGE

func _spread_fire():
	var surrounding_trees = Globals.get_level().get_surrounding_trees(get_position() / Globals.PIXEL_PER_TILE)
	
	for tree in surrounding_trees:
		tree.start_burning()

func _set_growth_stage(new_stage: int):
	growth_stage = new_stage
	var scale = growth_stage as float / MAX_GROWTH_STAGE as float
	set_scale(Vector2(scale, scale))

func _set_state(new_state):
	state = new_state
	_set_surrounding_tiles()
	$Particles2D.emitting = state == FloraState.BURNING

func _set_surrounding_tiles():
	if Globals.get_level() == null:
		return
	
	if state != FloraState.BURNT and state != FloraState.GROWING:
		return
	
	var pos = get_position() / Globals.PIXEL_PER_TILE
		
	var radius = BURNT_RADIUS if state == FloraState.BURNT else GRAS_RADIUS
	var tile_type = Globals.Tile.DIRT if state == FloraState.BURNT else Globals.Tile.GRAS
	for x_offset in range(-radius, radius):
		for y_offset in range(-radius, radius):
			Globals.get_level().set_tile(pos + Vector2(x_offset, y_offset), tile_type)

func _set_texture_path(path: String):
	texture_path = path
	$Sprite.texture = load(texture_path)