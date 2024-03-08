extends Camera2D

const D_ZOOM: float = 0.01

func _ready():
    DragDropServer.camera = self    

func _input(event):
    if event is InputEventMouseMotion:
        if Input.is_action_pressed("CAMERA_DRAG"):
            global_position -= event.relative
    
    if Input.is_action_just_pressed("SCROLL_UP"):
        zoom += Vector2.ONE * D_ZOOM
    elif Input.is_action_just_pressed("SCROLL_DOWN"):
        zoom -= Vector2.ONE * D_ZOOM
