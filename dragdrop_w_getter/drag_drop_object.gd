class_name DragDropObject
extends Area2D

@export var texture: Texture2D

@export var is_dragging: bool = false
@export var is_hovering: bool = false
@export var degree: int = 0
@export var can_drag: bool = true
@export var can_be_dropped: bool = true
@export var can_click: bool = true
@export var is_private: bool = false

var front: Sprite2D

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
    front = Sprite2D.new()
    add_child(front)
    front.texture = texture
    front.scale = Vector2.ONE * (float(width) / texture.get_width())
    
    var collision_shape = CollisionShape2D.new()
    add_child(collision_shape)
    collision_shape.shape = RectangleShape2D.new()
    collision_shape.shape.size = texture.get_size() * front.scale   
    
    area_entered.connect(check_hovered)
    area_exited.connect(check_unhovered)

func start_dragging():
    if can_drag:
        _set_dragging.rpc(true)

func end_dragging():
    _set_dragging.rpc(false)
    on_dropped.emit()

@rpc("any_peer", "call_local", "reliable")
func _set_dragging(value: bool):
    is_dragging = value

func drag(d_pos: Vector2):
    _drag.rpc(d_pos)
    on_dragged.emit()

@rpc("any_peer", "call_local", "reliable")
func _drag(d_pos: Vector2):
    if is_dragging:
        global_position += d_pos

func move_to(pos: Vector2):
    _move_to.rpc(pos)

@rpc("any_peer", "call_local", "reliable")
func _move_to(pos: Vector2):
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
    if !is_private:
        _flip.rpc()
        on_flipped.emit()

@rpc("any_peer", "call_local", "reliable")
func _flip():
    var t = create_tween().set_ease(Tween.EASE_OUT)
    var original_scale = scale
    t.tween_property(self, "scale", Vector2(0, scale.y), flip_span / 2)
    await t.finished
    t = create_tween().set_ease(Tween.EASE_OUT)
    t.tween_property(self, "scale", original_scale, flip_span / 2)

func rotate_object(d: int):
    degree += d
    _rotate_object.rpc(degree)

@rpc("any_peer", "call_local", "reliable")
func _rotate_object(d: int):
    var t = create_tween().set_ease(Tween.EASE_OUT)
    t.tween_property(self, "rotation", deg_to_rad(d), rotate_span)

func check_hovered(area: Area2D):
    if area is DragDropCursor:
        _set_is_hovering.rpc(true)
        on_cursor_hovered.emit()

func check_unhovered(area: Area2D):
    if area is DragDropCursor:
        _set_is_hovering.rpc(false)
        on_cursor_exited.emit()  

@rpc("any_peer", "call_local", "reliable")
func _set_is_hovering(value: bool):
    is_hovering = value

func delete():
    _delete.rpc()

@rpc("any_peer", "call_local", "reliable")
func _delete():
    if multiplayer.is_server():
        _delete_client.rpc()

@rpc("authority", "call_local", "reliable")
func _delete_client():
    queue_free()

func set_private_value(value: bool):
    is_private = value    
    _set_private_value.rpc(value)

@rpc("any_peer", "call_remote", "reliable")
func _set_private_value(value: bool):
    is_private = value
    visible = !is_private
