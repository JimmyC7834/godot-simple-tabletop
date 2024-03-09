class_name PlayCard
extends ServerCard

const SQUARE = preload("res://assets/square.png")

@export var private_tint: Color
#var private_indicator

func _ready():
    super._ready()
    #private_indicator = Sprite2D.new()
    #add_child(private_indicator)
    #private_indicator.texture = back_texture
    #private_indicator.scale = Vector2.ONE * (float(width) / back_texture.get_width())
    #private_indicator.visible = false
    #private_indicator.self_modulate

func set_private_value(value: bool):
    modulate = private_tint if value else Color.WHITE
    super.set_private_value(value)
