extends Node

const SQUARE_PATH = "res://assets/square.png"

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

func get_img_bytes_by_path(path: String, compression: Image.CompressMode = Image.COMPRESS_ASTC) -> PackedByteArray:
    var img = Image.new()
    var error = img.load(path)
    print(img)
    if error != OK:
        return get_img_bytes_by_path(SQUARE_PATH)
    img.compress(compression, Image.COMPRESS_SOURCE_GENERIC, Image.ASTC_FORMAT_8x8)
    return img.save_png_to_buffer()

func screen_to_world(pos: Vector2, camera: Camera2D) -> Vector2:
    var v = camera.get_viewport().get_canvas_transform().affine_inverse()
    v *= pos
    return v

func world_to_screen(pos: Vector2, camera: Camera2D) -> Vector2:
    var v = camera.get_viewport().get_canvas_transform()
    v *= pos
    return v
