extends Node

const PANEL_OBJECT = preload("res://panel item/panel_object.tscn")
const PLAY_CARD = preload("res://panel item/play_card.tscn")

const DEFAULT_OBJECT_WIDTH = 200

var camera: Camera2D
var cursor: DragDropCursor
var cards: Array[DragDropObject]

func new_card(path: String, pos: Vector2 = Vector2.ZERO, count: int = 1):
    new_card_wtex(Utils.get_img_bytes_by_path(path), pos, count)

# old new_card, read from path instead of sending texture
@rpc("any_peer", "call_local", "reliable")
func _new_card(path: String, pos: Vector2 = Vector2.ZERO) -> PlayCard:
    var inst = PLAY_CARD.instantiate()
    var texture: Texture2D = Utils.get_texture_by_path(path)
    if texture is Texture2D:
        print(get_multiplayer_authority(), " added card: ", path)
        inst.texture = texture
        add_child(inst)
        inst.move_to(pos)
        return inst

    return null

@rpc("any_peer", "call_local", "reliable")
func new_card_wbase64(base64_str: String, card_back_base64: String = "", pos: Vector2 = Vector2.ZERO, count: int = 1):
    var img = Image.new()
    img.load_png_from_buffer(Marshalls.base64_to_raw(base64_str))
    var texture = ImageTexture.create_from_image(img)
    
    img = Image.new()
    if card_back_base64 == "":
        img.load_png_from_buffer(
            Marshalls.base64_to_raw(Utils.read_file_as_base64("res://assets/texture/square.png")))
    else:
        img.load_png_from_buffer(Marshalls.base64_to_raw(card_back_base64))
    var back_texture = ImageTexture.create_from_image(img)
   
    if texture is Texture2D:
        var arr: Array[PlayCard] = []
        for i in range(count):
            print(get_multiplayer_authority(), " added card_wtex: ", texture)
            var inst = card_from_texture(texture)
            inst.back_texture = back_texture
            inst.move_to(pos)
            arr.append(inst)
        return arr

# old rpc for trasnferring cards texture with array of bytes
@rpc("any_peer", "call_local", "reliable")
func new_card_wtex(color_arr: PackedByteArray, pos: Vector2 = Vector2.ZERO, count: int = 1):
    var img = Image.new()
    img.load_png_from_buffer(color_arr)
    var texture = ImageTexture.create_from_image(img)
    if texture is Texture2D:
        var arr: Array[PlayCard] = []
        for i in range(count):
            print(get_multiplayer_authority(), " added card_wtex: ", texture)
            var inst = card_from_texture(texture)
            inst.move_to(pos)
            arr.append(inst)
        return arr

    return null

func card_from_texture(texture: Texture2D) -> PlayCard:
    var inst = PLAY_CARD.instantiate()
    inst.texture = texture
    add_child(inst)
    return inst

func new_object(path: String, pos: Vector2 = Vector2.ZERO):
    new_object_wtex(Utils.get_img_bytes_by_path(path), pos)

@rpc("any_peer", "call_local", "reliable")
func new_object_wtex(color_arr: PackedByteArray, pos: Vector2 = Vector2.ZERO):
    var img = Image.new()
    img.load_png_from_buffer(color_arr)
    var texture = ImageTexture.create_from_image(img)
    if texture is Texture2D:
        print(get_multiplayer_authority(), " added card_wtex: ", texture)
        var inst = PANEL_OBJECT.instantiate()
        inst.texture = texture
        add_child(inst)
        inst.move_to(pos)

func register_cursor(c: DragDropCursor):
    cursor = c

func clear_all_card():
    for c in get_children():
        c.queue_free()

func push_to_front(obj: DragDropObject):
    var i: int = get_children().find(obj)
    if i != -1:
        _push_to_front.rpc(i)

@rpc("any_peer", "call_local", "reliable")
func _push_to_front(i: int):
    get_children()[i].move_to_front()
