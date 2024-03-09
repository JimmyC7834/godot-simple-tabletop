class_name DragDropCursor
extends Area2D

const DRAG_THRESHOLD: int = 5
const CONTEXT_MENU_OFFSET: Vector2 = Vector2(580, 325)

const CM_FLIP = 0
const CM_PRIVATE = 1
const CM_DELETE = 2
const CM_GATHER = 3
const CM_SHUFFLE = 4
const CM_SPAWN_DECK = 5

@onready var context_menu: PopupMenu = $PopupMenu
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

# card control variable
var selecting: Array[DragDropObject] = []
var hovering: DragDropObject

var cursor_shape: RectangleShape2D
var is_dragging: bool = false

var original_position: Vector2

var menu_func_table = {
    CM_FLIP: context_menu_flip,
    CM_PRIVATE: context_menu_private,
    CM_DELETE: context_menu_delete,
    CM_GATHER: context_menu_gather,
    CM_SHUFFLE: context_menu_shuffle,
    CM_SPAWN_DECK: context_menu_spawn_deck,
}

# state machine
var current_state: Callable

func _enter_tree():
    set_multiplayer_authority(name.to_int())

func _ready():
    cursor_shape = RectangleShape2D.new()
    collision_shape.shape = cursor_shape
    set_default_cursor_shape()
    
    current_state = state_empty
    
    context_menu.id_pressed.connect(handle_context_menu)

func _input(event):
    if not is_multiplayer_authority():
        return
        
    hovering = choose_dragdrop_object()
    current_state.call(event)

    if Input.is_action_just_pressed("RMB"):
        # context menu
        open_context_menu()

    #if hovering != null:
        #if Input.is_action_just_pressed("LMB") and !selected_any():
            #original_position = global_position
            #selecting.append(hovering)
            #selecting.map(func(c): c.start_dragging())
        #elif Input.is_action_just_released("LMB") and !selected_any():
            #hovering.push_to_front()
            #hovering.click()
        #elif Input.is_action_just_pressed("RMB") and !selected_any():
            #hovering.flip()
    #
    #if selecting != null:
        #if Input.is_action_just_pressed("ROTATE_LEFT"):
            #selecting.map(func(c): c.move_to(global_position))
            #selecting.map(func(c): c.rotate_object(-90))
        #elif Input.is_action_just_pressed("ROTATE_RIGHT"):
            #selecting.map(func(c): c.move_to(global_position))
            #selecting.map(func(c): c.rotate_object(90))
        #elif Input.is_action_just_pressed("RMB"):
            #selecting.map(func(c): c.flip())
        #
        ## drop the card
        #if Input.is_action_just_released("LMB"):
            #if hovering != null:
                #selecting.map(func(c): hovering.dropped_by(c))
            #selecting.map(func(c): c.end_dragging())
            #print(selecting, " dropped")
            #selecting = []
    #
    #if event is InputEventMouseMotion:
        #global_position = get_global_mouse_position()
        #
        #if !selected_any():
            #if hovering != null and original_position.distance_to(global_position) > DRAG_THRESHOLD and Input.is_action_pressed("LMB"):
                #print("picked ", hovering.name)
                #hovering.start_dragging()
                #hovering.push_to_front()
                #selecting.append(hovering)
        #else:
            #selecting.map(func(c): c.drag(get_vec_in_cam(event.relative)))

############################# STATE MACHINE ##############################

# idle state of the cursor
func state_empty(event):
    if event is InputEventMouseMotion:
        global_position = get_global_mouse_position()
    elif event is InputEventMouseButton:
        if Input.is_action_just_pressed("LMB"):
            original_position = global_position
            if hovering == null:
                print("start selection")
                current_state = state_dragging
            else:
                print("clicked on ", hovering)
                hovering.push_to_front()
                selecting = [hovering]
                current_state = state_single_clicked

# state where the cursor is dragging with nothing selected
func state_dragging(event):
    if event is InputEventMouseMotion:
        # create selection area
        global_position = get_global_mouse_position()
        
        if original_position.distance_to(global_position) < DRAG_THRESHOLD:
            return
        
        cursor_shape.size = abs(global_position - original_position)
        var offset = cursor_shape.size / 2.0
        if global_position.x < original_position.x:
            offset.x *= -1
        if global_position.y < original_position.y:
            offset.y *= -1
            
        collision_shape.global_position = original_position + offset
    elif event is InputEventMouseButton:
        # select the cards
        if Input.is_action_just_released("LMB"):
            # dragged selection area, get all objects covered
            selecting = get_all_dragdrop_objects()
            print("selected ", selecting)
            set_default_cursor_shape()
            if selected_any():
                current_state = state_selected
            else:
                # no object selected, return to idle state
                current_state = state_empty

# state where one card is clicked for drag n drop or click
func state_single_clicked(event):
    assert(len(selecting) == 1)
    if event is InputEventMouseMotion:
        global_position = get_global_mouse_position()
    
        if original_position.distance_to(global_position) > DRAG_THRESHOLD:
            # start drag
            print("start dragging ", selecting)
            selecting[0].start_dragging()
            current_state = state_single_drag
    
    if event is InputEventMouseButton:
        if Input.is_action_just_released("LMB"):
            # not dragged, do click
            selecting[0].click()
            current_state = state_empty

func state_single_drag(event):
    if event is InputEventMouseMotion:
        global_position = get_global_mouse_position()
        selecting[0].drag(get_vec_in_cam(event.relative))
    rotation_action_check()
    
    if event is InputEventMouseButton and Input.is_action_just_released("LMB"):
        if hovering != null:
            hovering.dropped_by(selecting[0])
        selecting[0].end_dragging()
        print("drop ", selecting)
        selecting = []
        current_state = state_empty

# state where any number of objects is selected by cursor
func state_selected(event):
    assert(len(selecting) > 0)
    if event is InputEventMouseMotion:
        # move all
        global_position = get_global_mouse_position()
    
    if event is InputEventMouseButton:
        if Input.is_action_just_pressed("LMB"):
            # start drag all the objects if mouse is on one of them
            if hovering in selecting:
                print("start dragging all ", selecting)
                selecting.map(func(c): c.start_dragging())
                current_state = state_selected_drag
            else:
                selecting = []
                current_state = state_empty                

func state_selected_drag(event):
    if event is InputEventMouseMotion:
        # move all
        global_position = get_global_mouse_position()
        # drag all the objects if mouse is on one of them
        selecting.map(func(c): c.drag(get_vec_in_cam(event.relative)))
    
    rotation_action_check()
    
    if event is InputEventMouseButton:
        if Input.is_action_just_released("LMB"):
            selecting.map(func(c): c.end_dragging())
            if hovering == null:
                # just dragged the objects
                current_state = state_selected
            else:
                # dropped objects on something
                selecting.map(func(c): hovering.dropped_by(c))
                selecting = []
                current_state = state_empty

############################ CONTEXT MENU ############################

func open_context_menu():
    if hovering == null:
        context_menu.set_item_disabled(CM_FLIP, true)
        context_menu.set_item_disabled(CM_PRIVATE, true)
        context_menu.set_item_disabled(CM_DELETE, true)
        context_menu.set_item_disabled(CM_FLIP, true)
        context_menu.set_item_disabled(CM_GATHER, true)
        context_menu.set_item_disabled(CM_SHUFFLE, true)
        context_menu.set_item_disabled(CM_SPAWN_DECK, false)
        
    else:
        context_menu.set_item_disabled(CM_FLIP, false)
        context_menu.set_item_disabled(CM_PRIVATE, false)
        context_menu.set_item_disabled(CM_DELETE, false)
        context_menu.set_item_disabled(CM_FLIP, false)
        context_menu.set_item_disabled(CM_GATHER, false)
        context_menu.set_item_disabled(CM_SHUFFLE, false)
        context_menu.set_item_disabled(CM_SPAWN_DECK, true)
        
        if not hovering in selecting:
            selecting.append(hovering)
        context_menu.set_item_checked(CM_PRIVATE, selecting[0].is_private)

    context_menu.popup_on_parent(
        Rect2i(get_global_mouse_position() + CONTEXT_MENU_OFFSET, Vector2.ONE))

func handle_context_menu(id: int):
    if id in menu_func_table:
        menu_func_table[id].call(id)

func context_menu_flip(id: int):
    if selected_any():
        selecting.map(func(c): c.flip())
        selecting = []
        current_state = state_empty    

func context_menu_private(id: int):
    context_menu.set_item_checked(CM_PRIVATE, !context_menu.is_item_checked(CM_PRIVATE))
    if selected_any():
        selecting.map(func(c): c.set_private_value(context_menu.is_item_checked(CM_PRIVATE)))
        selecting = []
        current_state = state_empty

func context_menu_delete(id: int):
    if selected_any():
        selecting.map(func(c): c.delete())
        selecting = []
        current_state = state_empty

func context_menu_gather(id: int):
    if selected_any():
        selecting.map(func(c): c.move_to(selecting[0].global_position))
        selecting = []
        current_state = state_empty

func context_menu_shuffle(id: int):
    if selected_any():
        while selecting.size() > 0:
            var c = selecting.pick_random()
            c.push_to_front()
            selecting.erase(c)

        selecting = []
        current_state = state_empty

func context_menu_spawn_deck(id: int):
    if selected_any():
        selecting = []
        current_state = state_empty
    
    var path = await Database.choose_path(FileDialog.FILE_MODE_OPEN_FILE)
    var res = Database.load_file(path)
    if res is DeckRes:
        for key in res.cards_dict:
            for i in range(res.cards_dict[key]):
                var inst = DragDropServer.new_card(key)
                inst.move_to(global_position)

########################  HELPER FUNC  ############################

func rotation_action_check():
    if selected_any():
        if Input.is_action_just_pressed("ROTATE_LEFT"):
            rotate_selected(-90)
        elif Input.is_action_just_pressed("ROTATE_RIGHT"):
            rotate_selected(90)

func rotate_selected(d_degree: int):
    if selecting.size() == 0:
        return

    var offset: Vector2 = get_global_mouse_position() - selecting[0].global_position
    selecting.map(func(c):
        c.move_to(c.global_position + offset)
        c.rotate_object(d_degree))

func set_default_cursor_shape():
    cursor_shape.size = Vector2.ONE
    collision_shape.global_position = global_position

func get_all_dragdrop_objects() -> Array[DragDropObject]:
    var areas: Array[Area2D] = get_overlapping_areas().filter(
        func(c): return c is DragDropObject and not c.is_dragging and c.modulate != Color.BLACK)
    
    var cards: Array[DragDropObject]
    cards.append_array(areas)

    return cards

func choose_dragdrop_object() -> DragDropObject:
    var cards: Array[Area2D] = get_overlapping_areas().filter(
        func(c): return c is DragDropObject and not c.is_dragging and c.modulate != Color.BLACK)
        
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
