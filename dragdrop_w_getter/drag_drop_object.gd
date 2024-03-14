class_name DragDropObject
extends Area2D

const OUTLINE_WIDTH: float = 8
const MAT_OUTLINE = preload("res://assets/shader/outline.tres")

@export var front_texture: Texture2D
@export var back_texture: Texture2D

@export var is_dragging: bool = false
@export var is_hovering: bool = false
@export var degree: int = 0
@export var can_drag: bool = true
@export var can_be_dropped: bool = true
@export var can_click: bool = true

var outline: Sprite2D
var front: Sprite2D
var back: Sprite2D

var rotate_span: float = 0.1
var flip_span: float = 0.1
var width: int

signal on_clicked
signal on_dragged
signal on_dropped
signal on_dropped_on(d: DragDropObject)
signal on_flipped
signal on_cursor_hovered
signal on_cursor_exited

func _init(_width: int = DragDropServer.DEFAULT_OBJECT_WIDTH):
    width = _width 

func _ready():
    front = add_sprite_wtex(front_texture)
    
    back = add_sprite_wtex(back_texture)
    back.visible = false
    
    var collision_shape = CollisionShape2D.new()
    add_child(collision_shape)
    collision_shape.shape = RectangleShape2D.new()
    collision_shape.shape.size = front_texture.get_size() * front.scale   
    
    outline = add_sprite_wtex(front_texture)
    move_child(outline, 0)
    
    outline.material = MAT_OUTLINE.duplicate()
    set_outline(false)
    
    area_entered.connect(check_hovered)
    area_exited.connect(check_unhovered)

func add_sprite_wtex(texture: Texture2D) -> Sprite2D:
    var sprite = Sprite2D.new()
    add_child(sprite)
    sprite.texture = texture
    if texture != null:
        sprite.scale = Vector2.ONE * (float(width) / texture.get_width())
    return sprite

func set_outline(value: bool):
    (outline.material as ShaderMaterial).set_shader_parameter(
        "width", OUTLINE_WIDTH if value else 0)

func start_dragging():
    if can_drag:
        set_dragging(true)

func end_dragging():
    set_dragging(false)
    on_dropped.emit()

func set_dragging(value: bool):
    is_dragging = value

func drag(d_pos: Vector2):
    if is_dragging:
        global_position += d_pos
        on_dragged.emit()

func move_to(pos: Vector2):
    global_position = pos

func dropped_by(d: DragDropObject):
    if can_be_dropped:
        on_dropped_on.emit()

func click():
    if can_click:
        print("clicked ", name)
    on_clicked.emit()

func push_to_front():
    DragDropServer.push_to_front(self)

func flip():
    var t = create_tween().set_ease(Tween.EASE_OUT)
    var original_scale = scale
    t.tween_property(self, "scale", Vector2(0, scale.y), flip_span / 2)
    await t.finished
    back.visible = not back.visible
    t = create_tween().set_ease(Tween.EASE_OUT)
    t.tween_property(self, "scale", original_scale, flip_span / 2)
    
    on_flipped.emit()

func rotate_object(d: int):
    degree += d

    var t = create_tween().set_ease(Tween.EASE_OUT)
    t.tween_property(self, "rotation", deg_to_rad(degree), rotate_span)

func check_hovered(area: Area2D):
    if area is DragDropCursor:
        set_is_hovering(true)
        on_cursor_hovered.emit()

func check_unhovered(area: Area2D):
    if area is DragDropCursor:
        set_is_hovering(false)
        on_cursor_exited.emit()  

func set_is_hovering(value: bool):
    is_hovering = value

func delete():
    queue_free()
