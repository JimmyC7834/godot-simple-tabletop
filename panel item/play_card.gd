class_name PlayCard
extends RPCDragDrop

@export var private_tint: Color
var file_names: PackedStringArray

func set_private_value(value: bool):
    modulate = private_tint if value else Color.WHITE
    super.set_private_value(value)
