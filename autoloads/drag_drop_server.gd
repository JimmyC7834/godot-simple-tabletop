extends Node

const PANEL_OBJECT = preload("res://panel item/panel_object.tscn")
const PLAY_CARD = preload("res://panel item/play_card.tscn")

const DEFAULT_OBJECT_WIDTH = 200

var camera: Camera2D
var cursor: DragDropCursor
var cards: Array[DragDropObject]

var tex_square_base64: String

func _ready():
    tex_square_base64 = Utils.read_file_as_base64("res://assets/texture/square.png")

func new_card(path: String, pos: Vector2 = Vector2.ZERO, count: int = 1):
    new_card_wbase64.rpc(Utils.read_file_as_base64(path), pos, count)

@rpc("any_peer", "call_local", "reliable")
func prepare_new_object(file_name: String, pos: Vector2 = Vector2.ZERO, count: int = 1):
    Database.get_data(file_name, func(bytes): 
        new_card_wbase64(bytes, pos, count))

    #new_card_wbase64(Database.data[file_name], pos, count)

@rpc("any_peer", "call_local", "reliable")
func new_card_wbase64(data_bytes: PackedByteArray, pos: Vector2 = Vector2.ZERO, count: int = 1):
    var img = Image.new()
    img.load_png_from_buffer(data_bytes)
    var texture = ImageTexture.create_from_image(img)

    #img = Image.new()
    #if base64_str.size() < 2 or base64_str[1].length() == 0:
        #img.load_png_from_buffer(Marshalls.base64_to_raw(tex_square_base64))
    #else:
        #img.load_png_from_buffer(Marshalls.base64_to_raw(base64_str[1]))
    var back_texture = ImageTexture.create_from_image(img)
   
    if texture is Texture2D:
        var arr: Array[PlayCard] = []
        for i in range(count):
            print(get_multiplayer_authority(), " added card_wtex: ", texture)
            var inst = card_from_texture(texture)
            inst.back_texture = back_texture
            add_child(inst)
            inst.move_to(pos)
            arr.append(inst)
        return arr

@rpc("any_peer", "call_local", "reliable")
func new_object(file_names: PackedStringArray, pos: Vector2 = Vector2.ZERO, count: int = 1):
    var img = Image.new()
    img.load_png_from_buffer(Database.data[file_names[0]])
    var texture = ImageTexture.create_from_image(img)

    img = Image.new()
    if file_names.size() < 2 or file_names[1].length() == 0:
        img.load_png_from_buffer(Marshalls.base64_to_raw(tex_square_base64))
    else:
        img.load_png_from_buffer(Database.data[file_names[1]])
    var back_texture = ImageTexture.create_from_image(img)
   
    if texture is Texture2D:
        var arr: Array[PlayCard] = []
        for i in range(count):
            print(get_multiplayer_authority(), " added object: ", texture)
            var inst = card_from_texture(texture)
            inst.back_texture = back_texture
            add_child(inst)
            inst.move_to(pos)
            arr.append(inst)
        return arr

func card_from_texture(texture: Texture2D) -> PlayCard:
    var inst = PLAY_CARD.instantiate()
    inst.front_texture = texture
    return inst

#func new_object(path: String, pos: Vector2 = Vector2.ZERO):
    #new_object_wtex.rpc(Utils.read_file_as_base64(path), tex_square_base64, pos)

@rpc("any_peer", "call_local", "reliable")
func new_object_wtex(base64_str: String, card_back_base64: String = tex_square_base64, 
                        pos: Vector2 = Vector2.ZERO):
    var img = Image.new()
    img.load_png_from_buffer(Marshalls.base64_to_raw(base64_str))
    var texture = ImageTexture.create_from_image(img)
    
    img = Image.new()
    if card_back_base64 == "":
        card_back_base64 = tex_square_base64
    img.load_png_from_buffer(Marshalls.base64_to_raw(card_back_base64))
    var back_texture = ImageTexture.create_from_image(img)
   
    if texture is Texture2D:
        print(get_multiplayer_authority(), " added object: ", texture)
        var inst = card_from_texture(texture)
        inst.back_texture = back_texture
        add_child(inst)
        inst.move_to(pos)
        return inst

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
