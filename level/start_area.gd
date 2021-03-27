extends Area2D


export var next_level : String = "res://level/luc.tscn"

func _on_StartArea_body_entered(body):
	if self.get_overlapping_bodies().size() == Globals.get_players().size():
		Globals.get_game().switch_level(next_level)
