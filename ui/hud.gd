extends CanvasLayer

const HUD = preload("res://ui/hud.tscn")

func _ready():
    add_child(HUD.instantiate())
