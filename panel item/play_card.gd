class_name PlayCard
extends ServerCard

const OUTLINE_WIDTH: float = 8

const SQUARE = preload("res://assets/square.png")
const MAT_OUTLINE = preload("res://outline.tres")

@export var private_tint: Color

var outline: Sprite2D

func _ready():
    super._ready()
    outline = Sprite2D.new()
    add_child(outline)
    move_child(outline, 0)
    outline.texture = texture
    outline.scale = Vector2.ONE * (float(width) / texture.get_width())
    
    outline.material = MAT_OUTLINE.duplicate()
    set_outline(false)

func set_private_value(value: bool):
    modulate = private_tint if value else Color.WHITE
    super.set_private_value(value)

func set_outline(value: bool):
    (outline.material as ShaderMaterial).set_shader_parameter(
        "width", OUTLINE_WIDTH if value else 0)
    
