extends Node

func delay(t: float):
    return get_tree().create_timer(t).timeout

func get_texture_by_path(path: String) -> Texture:
    var img = Image.new()
    img.load(path)
    return ImageTexture.create_from_image(img)
