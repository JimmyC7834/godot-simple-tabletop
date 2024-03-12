extends Window

@onready var texture_rect = $TextureRect
var registered: bool = false

func _ready():
    close_requested.connect(hide)
    
    visibility_changed.connect(func():
        if DragDropServer.cursor != null and !registered:
            registered = true
            DragDropServer.cursor.on_hover.connect(
                func(obj: DragDropObject):
                    texture_rect.texture = obj.texture
            ))
