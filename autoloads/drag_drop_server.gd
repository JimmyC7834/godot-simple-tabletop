extends Node


const PLAY_CARD = preload("res://panel item/play_card.tscn")
const DEFAULT_OBJECT_WIDTH = 200

var camera: Camera2D
var cards: Array[DragDropObject]

@rpc("any_peer", "call_local", "reliable")
func new_card(path: String, pos: Vector2 = Vector2.ZERO) -> PlayCard:
    var inst = PLAY_CARD.instantiate()
    var texture = Database.load_file(path)
    if texture is Texture2D:
        print(get_multiplayer_authority(), " added card: ", path)
        inst.texture = texture
        inst.global_position = pos
        add_child(inst)
        return inst

    return null

#@rpc("any_peer", "call_local", "reliable")
#func new_card_pile(path: String) -> CardPile:
    #var inst = CARD_PILE.instantiate()
    #var res = Database.load_file(path)
    #if res is DeckRes:
        #inst.load_deck(res)
        #add_child(inst)
        #return inst
#
    #return null

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
