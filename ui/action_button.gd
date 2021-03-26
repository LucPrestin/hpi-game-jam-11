extends Button

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export(Globals.ACTIONS) var action = Globals.ACTIONS.move_up
var remove: bool = false

signal push_action(action)
signal remove_child(child)


# Called when the node enters the scene tree for the first time.
func _ready():
	self.text = Globals.ACTION_TEXT[self.action]
	self.connect("pressed", self, "_on_pressed")
	
	var dynamic_font = DynamicFont.new()
	#dynamic_font.font_data = load("res://resources/hud/fonts/vinque.ttf")
	dynamic_font.font_data = load("res://resources/hud/fonts/roboto.ttf")
	dynamic_font.size = 30
	self.set("custom_fonts/font", dynamic_font)

func make_removal_button(target):
	self.remove = true
	self.connect("remove_child", target, "_on_remove_child")

func _on_pressed():
	if remove:
		emit_signal("remove_child", self)
	else:
		emit_signal("push_action", self.action)

