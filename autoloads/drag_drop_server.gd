extends Node

const SERVER_CARD = preload("res://dragdrop_w_getter/server_card.tscn")
const DEFAULT_OBJECT_WIDTH = 200

var cards: Array[DragDropObject]

@rpc("any_peer", "call_local", "reliable")
func new_card(path: String):
    var inst = SERVER_CARD.instantiate()
    inst.texture = Utils.get_texture_by_path(path)
    add_child(inst)

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
