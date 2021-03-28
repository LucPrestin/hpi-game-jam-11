extends Area2D


export var next_level : String = "res://level/level.tscn"

func _on_StartArea_body_entered(body):
	for player in Globals.get_players():
		if !self.overlaps_body(player):
			return
	
	Globals.get_game().call_deferred("switch_level", next_level)
