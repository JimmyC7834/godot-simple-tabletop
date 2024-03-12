extends Window

@onready var texture_rect = $TextureRect

func _ready():
    close_requested.connect(hide)
    
    visibility_changed.connect(func():
        if DragDropServer.cursor != null:
            DragDropServer.cursor.on_hover.connect(
                func(obj: DragDropObject):
                    texture_rect.texture = obj.texture
            ))
