class_name DragDropCursor
extends Area2D

const D_ZOOM: float = 0.02
const DRAG_THRESHOLD: int = 5
const CONTEXT_MENU_OFFSET: Vector2 = Vector2(3, 3)
const DEFAULT_CURSOR_SIZE: Vector2 = Vector2(0.15, 0.15)

const CM_FLIP = 0
const CM_PRIVATE = 1
const CM_DELETE = 2
const CM_GATHER = 3
const CM_SHUFFLE = 4
const CM_INFO = 5

const PM_SPAWN_CARD = 0
const PM_SPAWN_OBJECT = 1
const PM_SPAWN_DECK = 2

@onready var panel_menu: PopupMenu = $PanelMenu
@onready var card_menu: PopupMenu = $CardMenu
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var sprite: Sprite2D = $Sprite2D

# card control variable
var selecting: Array[DragDropObject] = []:
    set(x):
        selecting.map(func(c): c.set_outline(false))
        selecting = x
        selecting.map(func(c): c.set_outline(true))

var hovering: DragDropObject

var cursor_shape: RectangleShape2D
var is_dragging: bool = false

var original_position: Vector2

var card_menu_func_table = {
    CM_FLIP: context_menu_flip,
    CM_PRIVATE: context_menu_private,
    CM_DELETE: context_menu_delete,
    CM_GATHER: context_menu_gather,
    CM_SHUFFLE: context_menu_shuffle,
}

var panel_menu_func_table = {
    PM_SPAWN_CARD: context_menu_spawn_card,
    PM_SPAWN_OBJECT: context_menu_spawn_object,
    PM_SPAWN_DECK: context_menu_spawn_deck,
}

# state machine
var current_state: Callable

signal on_input(event)
signal on_hover(obj: DragDropObject)

func _enter_tree():
    set_multiplayer_authority(name.to_int())

func _ready():
    cursor_shape = RectangleShape2D.new()
    collision_shape.shape = cursor_shape
    set_default_cursor_shape()
    
    sprite.self_modulate = Color(
        0.4 + randf_range(0, 0.6), 
        0.4 + randf_range(0, 0.6),
        0.4 + randf_range(0, 0.6), 
        0.4)
    
    current_state = state_empty
    
    card_menu.id_pressed.connect(handle_card_menu)
    panel_menu.id_pressed.connect(handle_panel_menu)
    
    if multiplayer.get_unique_id() == name.to_int():
        DragDropServer.register_cursor(self)

func _input(event):
    if not is_multiplayer_authority():
        return
        
    var prev_hovering = hovering
    hovering = choose_dragdrop_object()
    
    # if hovering new card, emit
    if prev_hovering != hovering and hovering != null:
        on_hover.emit(hovering)

    current_state.call(event)

    if not Input.is_action_pressed("LMB"):
        if Input.is_action_just_pressed("RMB"):
            # context menu
            open_context_menu()
        elif selected_any():
            listen_for_shortcut()
        elif hovering != null:
            selecting.append(hovering)
            listen_for_shortcut()            
            selecting = []
            
    if selected_any() and hovering in selecting:
        if Input.is_action_just_released("SCROLL_UP"):
            loop_selecting_cards(true)
        elif Input.is_action_just_released("SCROLL_DOWN"):
            loop_selecting_cards(false)
    else:
        if Input.is_action_just_pressed("SCROLL_UP"):
            DragDropServer.camera.zoom_view(D_ZOOM)
        elif Input.is_action_just_pressed("SCROLL_DOWN"):
            DragDropServer.camera.zoom_view(-D_ZOOM)
        
    on_input.emit(event)

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
        sprite.global_position = original_position + offset
        sprite.scale = abs(global_position - original_position) / sprite.texture.get_size()
    elif event is InputEventMouseButton:
        # select the cards
        if Input.is_action_just_released("LMB"):
            # dragged selection area, get all objects covered
            selecting = get_all_dragdrop_objects()
            selecting.sort_custom(func(a, b): return a.get_index() < b.get_index())
            selecting.map(func(c): c.push_to_front())
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
    var pos = Vector2i(Utils.world_to_screen(global_position, DragDropServer.camera) + CONTEXT_MENU_OFFSET)
    if hovering == null:
        panel_menu.popup_on_parent(
            Rect2i(pos, Vector2.ONE))
    else:
        if not hovering in selecting:
            selecting.append(hovering)
        card_menu.set_item_text(CM_INFO, "%d cards" % get_all_dragdrop_objects().size())
        card_menu.set_item_checked(CM_PRIVATE, selecting[0].is_private)

        card_menu.popup_on_parent(
            Rect2i(pos, Vector2.ONE))

func handle_card_menu(id: int):
    if id in card_menu_func_table:
        card_menu_func_table[id].call()

func handle_panel_menu(id: int):
    if id in panel_menu_func_table:
        panel_menu_func_table[id].call()

func context_menu_flip():
    if selected_any():
        selecting.map(func(c): c.flip())
    
    #selecting = []
    #current_state = state_empty

func context_menu_private():
    card_menu.set_item_checked(CM_PRIVATE, !card_menu.is_item_checked(CM_PRIVATE))
    if selected_any():
        selecting.map(func(c): c.set_private_value(card_menu.is_item_checked(CM_PRIVATE)))
    
    #selecting = []
    #current_state = state_empty

func context_menu_delete():
    if selected_any():
        selecting.map(func(c): c.delete())
        selecting = []
        current_state = state_empty

func context_menu_gather():
    if selected_any():
        selecting.map(func(c): c.move_to(selecting[0].global_position))
    
    #selecting = []
    #current_state = state_empty

func context_menu_shuffle():
    if selected_any():
        while selecting.size() > 0:
            var c = selecting.pick_random()
            c.push_to_front()
            c.set_outline(false)
            selecting.erase(c)
    
    selecting = []
    current_state = state_empty

func context_menu_spawn_card():
    if selected_any():
        selecting = []
        current_state = state_empty
    
    var path = Database.choose_path(
        FileDialog.FILE_MODE_OPEN_FILE, ["*.png", "*.jpg", "*.jpeg"])
    if path == null: return    
    
    DragDropServer.new_card(path, global_position)

func context_menu_spawn_object():
    if selected_any():
        selecting = []
        current_state = state_empty
    
    var path = Database.choose_path(
        FileDialog.FILE_MODE_OPEN_FILE, ["*.png", "*.jpg", "*.jpeg"])
    if path == null: return    

    DragDropServer.new_object(path, global_position)

func context_menu_spawn_deck():
    if selected_any():
        selecting = []
        current_state = state_empty

    var path = Database.choose_path(FileDialog.FILE_MODE_OPEN_FILE)
    if path == null: return    

    var res = Database.load_file(path)
    if res is DeckRes:
        for key in res.cards_dict:
            var bytes: PackedByteArray = Marshalls.base64_to_raw(res.card_textures[key])
            var file_name: String = Database.file_name_from_path(key)
            Database.add_data(file_name, bytes)

            DragDropServer.new_card_wbase64.rpc(
                bytes, global_position, res.cards_dict[key])

    Input.set_default_cursor_shape(Input.CURSOR_ARROW)

func listen_for_shortcut():
    if Input.is_action_just_pressed("CM_FLIP"):
        context_menu_flip()        
    elif Input.is_action_just_pressed("CM_PRIVATE"):
        card_menu.set_item_checked(CM_PRIVATE, selecting[0].is_private)
        context_menu_private()        
    elif Input.is_action_just_pressed("CM_GATHER"):
        context_menu_gather()       
    elif Input.is_action_just_pressed("CM_DELETE"):
        context_menu_delete()

########################  HELPER FUNC  ############################

func loop_selecting_cards(forward: bool):
    if forward:
        var f = selecting.pop_front()
        selecting.append(f)
    else:
        selecting.push_front(selecting.pop_back())

    selecting[0].push_to_front()

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
    
    sprite.global_position = global_position
    sprite.scale = DEFAULT_CURSOR_SIZE

func get_all_dragdrop_objects() -> Array[DragDropObject]:
    var areas: Array[Area2D] = get_overlapping_areas().filter(
        func(c): return c is DragDropObject and not c.is_dragging and c.modulate != Color.BLACK)
    
    var cards: Array[DragDropObject] = []
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
