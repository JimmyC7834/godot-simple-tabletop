extends Node

const PANEL_OBJECT = preload("res://panel item/panel_object.tscn")
const PLAY_CARD = preload("res://panel item/play_card.tscn")

const DEFAULT_OBJECT_WIDTH = 200

var camera: Camera2D
var cursor: DragDropCursor
var cards: Array[PlayCard]

var tex_square_base64: String

func _ready():
    tex_square_base64 = Utils.read_file_as_base64("res://assets/texture/square.png")

@rpc("any_peer", "call_remote", "reliable")
func new_object(file_names: PackedStringArray, pos: Vector2 = Vector2.ZERO, count: int = 1):
    var arr: Array[PlayCard] = []
    for i in range(count):
        print(get_multiplayer_authority(), " added object: ", file_names)
        var inst = generate_dragdrop_object(file_names)
        add_child(inst)
        inst.move_to(pos)
        arr.append(inst)
        cards.append(inst)
    return arr

func generate_dragdrop_object(file_names: PackedStringArray):
    var img = Image.new()
    img.load_png_from_buffer(Database.data[file_names[0]])
    var texture = ImageTexture.create_from_image(img)

    img = Image.new()
    if file_names.size() < 2 or file_names[1].length() == 0:
        img.load_png_from_buffer(Marshalls.base64_to_raw(tex_square_base64))
    else:
        img.load_png_from_buffer(Database.data[file_names[1]])
    var back_texture = ImageTexture.create_from_image(img)

    var inst = PLAY_CARD.instantiate()
    inst.front_texture = texture
    inst.back_texture = back_texture
    inst.file_names = file_names
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
