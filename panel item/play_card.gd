class_name PlayCard
extends RPCDragDrop

const SQUARE = preload("res://assets/texture/square.png")

@export var private_tint: Color

func set_private_value(value: bool):
    modulate = private_tint if value else Color.WHITE
    super.set_private_value(value)
