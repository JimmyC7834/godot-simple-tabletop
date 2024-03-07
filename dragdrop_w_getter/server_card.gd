class_name ServerCard
extends DragDropObject

@export var back_texture: Texture2D
var back: Sprite2D

func _ready():
    super._ready()
    back = Sprite2D.new()
    add_child(back)
    back.texture = back_texture
    back.scale = Vector2.ONE * (float(width) / back_texture.get_width())
    back.visible = false

@rpc("any_peer", "call_local", "reliable")
func _flip():
    super._flip()
    back.visible = not back.visible
