extends Node

const SERVER_CARD = preload("res://dragdrop_w_getter/server_card.tscn")
const CCS_W_66_001 = preload("res://assets/ccs_w66_001.png")
const DEFAULT_OBJECT_WIDTH = 200

var cards: Array[DragDropObject]

func _ready():
    for i in range(5):
        new_card(CCS_W_66_001)

func new_card(texture: Texture2D):
    var inst = SERVER_CARD.instantiate()
    add_child(inst)

func push_to_front(obj: DragDropObject):
    var i: int = get_children().find(obj)
    if i != -1:
        _push_to_front.rpc(i)

@rpc("any_peer", "call_local", "reliable")
func _push_to_front(i: int):
    get_children()[i].move_to_front()
