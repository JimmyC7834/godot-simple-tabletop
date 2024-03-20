extends Window

@export var texture_rect: TextureRect
@export var checkbox: CheckBox
var registered: bool = false
var size_y: int

func _ready():
    get_viewport().set_embedding_subwindows(false)
    get_viewport().transparent = true
    get_viewport().transparent_bg = true
    get_viewport().always_on_top = true

    close_requested.connect(hide)
    
    size_y = size.y
    checkbox.pressed.connect(func():
        if checkbox.button_pressed:
            size = Vector2(size.x, size_y)
        else:
            size_y = size.y
            size = Vector2(size.x, 25))
    
    visibility_changed.connect(func():
        if DragDropServer.cursor != null and !registered:
            registered = true
            DragDropServer.cursor.on_hover.connect(
                func(obj: RPCDragDrop):
                    if !obj.back.visible:
                        texture_rect.texture = obj.front_texture
                    else:
                        texture_rect.texture = null
            ))
