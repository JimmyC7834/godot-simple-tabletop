extends Node

func delay(t: float):
    return get_tree().create_timer(t).timeout

func get_texture_by_path(path: String) -> Texture:
    var img = Image.new()
    var error = img.load(path)
    print(img)
    if error:
        print("client missing texture: ", path)
        return null
    return ImageTexture.create_from_image(img)

func get_bytes_by_path(path: String) -> Texture:
    var img = Image.new()
    var error = img.load(path)
    print(img)
    if error != OK:
        print("client missing texture: ", path)
        return null
    return ImageTexture.create_from_image(img)
    
func screen_to_world(pos: Vector2, camera: Camera2D) -> Vector2:
    var v = camera.get_viewport().get_canvas_transform().affine_inverse()
    v *= pos
    return v

func world_to_screen(pos: Vector2, camera: Camera2D) -> Vector2:
    var v = camera.get_viewport().get_canvas_transform()
    v *= pos
    return v
