extends Camera2D

const ZOOM_MIN: float = .25

@export var label: Label

var degree: int = 0
var rotate_span: float = 0.1

func _ready():
    DragDropServer.camera = self

func _input(event):
    if event is InputEventMouseMotion:
        if Input.is_action_pressed("CAMERA_DRAG"):
            global_position -= event.relative.rotated(deg_to_rad(degree)) * (1.0 / zoom.x)
    
    if Input.is_action_pressed("CAMERA_DRAG"):
        if Input.is_action_just_pressed("ROTATE_LEFT"):
            degree -= 45
            rotate_camera_to(degree)
        elif Input.is_action_just_pressed("ROTATE_RIGHT"):
            degree += 45
            rotate_camera_to(degree)
    
    update_label()

func zoom_view(d_zoom: float):
    zoom += Vector2.ONE * d_zoom
    zoom = max(ZOOM_MIN, zoom.x) * Vector2.ONE

func update_label():
    label.text = "POSITION: %s, ROTATION: %d" % [global_position, degree]

func rotate_camera_to(d: int):
    var t = create_tween().set_ease(Tween.EASE_OUT)
    t.tween_property(self, "rotation", deg_to_rad(d), rotate_span)

# [ext_resource type="Script" path="res://ui/login_screen.gd" id="1_km8ey"]
