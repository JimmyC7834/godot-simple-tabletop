extends Node

func delay(t: float):
    return get_tree().create_timer(t).timeout

func get_texture_by_path(path: String) -> Texture:
    var img = Image.new()
    var error = img.load(path)
    if error:
        print("client missing texture: ", path)
    return ImageTexture.create_from_image(img)
