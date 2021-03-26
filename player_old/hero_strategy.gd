extends Node

var player

func _ready():
	pass # Replace with function body.

func set_player(player: Player):
	self.player = player
	add_to_group("heros", true)
	if self.is_network_master():
		var texture_id = randi() % 20 + 1
		player.set_texture_path("res://resources/heros/player_%s.png" % str(texture_id))

func win():
	pass

func process_action(action):
	pass

func check_win_condition():
	return Globals.get_room().get_attribute_at_position_default(player.get_grid_position(), "open_door", false)
