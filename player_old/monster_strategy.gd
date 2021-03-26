extends Node

var player

func _ready():
	pass # Replace with function body.

func set_player(player: Player):
	self.player = player
	add_to_group("monsters", true)
	if self.is_network_master():
		var texture_id = randi() % 30 + 1
		player.set_texture_path("res://resources/monsters/%0*d.png" % [2, texture_id])

func process_action(action):
	pass
