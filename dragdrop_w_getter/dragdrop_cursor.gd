class_name DragDropCursor
extends Area2D

const DRAG_THRESHOLD = 5

@onready var popup_menu: PopupMenu = $PopupMenu
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

var selecting: Array[DragDropObject] = []
var hovering: DragDropObject

var cursor_shape: RectangleShape2D
var is_dragging: bool = false

var original_position: Vector2

func _enter_tree():
    set_multiplayer_authority(name.to_int())

func _ready():
    cursor_shape = RectangleShape2D.new()
    cursor_shape.size = Vector2.ONE
    collision_shape.shape = cursor_shape

func _input(event):
    if not is_multiplayer_authority():
        return
    
    hovering = choose_dragdrop_object()

    if hovering != null:
        if Input.is_action_just_pressed("LMB") and !selected_any():
            original_position = global_position
            selecting.append(hovering)
            selecting.map(func(c): c.start_dragging())
        elif Input.is_action_just_released("LMB") and !selected_any():
            hovering.push_to_front()
            hovering.click()
        elif Input.is_action_just_pressed("RMB") and !selected_any():
            hovering.flip()
    
    if selecting != null:
        if Input.is_action_just_pressed("ROTATE_LEFT"):
            selecting.map(func(c): c.move_to(global_position))
            selecting.map(func(c): c.rotate_object(-90))
        elif Input.is_action_just_pressed("ROTATE_RIGHT"):
            selecting.map(func(c): c.move_to(global_position))
            selecting.map(func(c): c.rotate_object(90))
        elif Input.is_action_just_pressed("RMB"):
            selecting.map(func(c): c.flip())
        
        # drop the card
        if Input.is_action_just_released("LMB"):
            if hovering != null:
                selecting.map(func(c): hovering.dropped_by(c))
            selecting.map(func(c): c.end_dragging())
            print(selecting, " dropped")
            selecting = []
    
    if event is InputEventMouseMotion:
        global_position = get_global_mouse_position()
        
        if !selected_any():
            if hovering != null and original_position.distance_to(global_position) > DRAG_THRESHOLD and Input.is_action_pressed("LMB"):
                print("picked ", hovering.name)
                hovering.start_dragging()
                hovering.push_to_front()
                selecting.append(hovering)
        else:
            selecting.map(func(c): c.drag(get_vec_in_cam(event.relative)))
        

func choose_dragdrop_object() -> DragDropObject:
    var cards: Array[Area2D] = get_overlapping_areas().filter(
        func(c): return c is DragDropObject and not c.is_dragging)
        
    if len(cards) == 0:
        return null
    elif len(cards) == 1:
        return cards[0]
    else:
        return cards.reduce(func(a, b): return a if a.get_index() > b.get_index() else b)

func get_vec_in_cam(vec: Vector2) -> Vector2:
    return (Vector2.ONE / DragDropServer.camera.zoom) * vec.rotated(deg_to_rad(DragDropServer.camera.degree))

func selected_any() -> bool:
    return len(selecting) > 0
