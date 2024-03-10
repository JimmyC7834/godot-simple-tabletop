class_name PlayCard
extends ServerCard

const OUTLINE_SCALE: float = 1.1
const SQUARE = preload("res://assets/square.png")
const MAT_OUTLINE = preload("res://outline.tres")

@export var private_tint: Color

var outline: Sprite2D

func _ready():
    super._ready()
    front.material = MAT_OUTLINE.duplicate()
    set_outline(false)

func set_private_value(value: bool):
    modulate = private_tint if value else Color.WHITE
    super.set_private_value(value)

func set_outline(value: bool):
    (front.material as ShaderMaterial).set_shader_parameter(
        "width", 5 if value else 0)
    
