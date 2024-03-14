class_name RPCDragDrop
extends DragDropObject

@export var is_private: bool = false

func start_dragging():
    _start_dragging.rpc()

@rpc("any_peer", "call_local", "reliable")
func _start_dragging():
    super.start_dragging()

func end_dragging():
    _end_dragging.rpc()

@rpc("any_peer", "call_local", "reliable")
func _end_dragging():
    super.end_dragging()

func drag(d_pos: Vector2):
    _drag.rpc(d_pos)

@rpc("any_peer", "call_local", "reliable")
func _drag(d_pos: Vector2):
    super.drag(d_pos)

func move_to(pos: Vector2):
    _move_to.rpc(pos)

@rpc("any_peer", "call_local", "reliable")
func _move_to(pos: Vector2):
    super.move_to(pos)

func flip():
    _flip.rpc()

@rpc("any_peer", "call_local", "reliable")
func _flip():
    super.flip()

func rotate_object(d: int):
    _rotate_object.rpc(d)

@rpc("any_peer", "call_local", "reliable")
func _rotate_object(d: int):
    super.rotate_object(d)

func set_is_hovering(value: bool):
    _set_is_hovering.rpc(value)

@rpc("any_peer", "call_local", "reliable")
func _set_is_hovering(value: bool):
    super.set_is_hovering(value)

func delete():
    _delete.rpc()

@rpc("any_peer", "call_local", "reliable")
func _delete():
    if multiplayer.is_server():
        _delete_client.rpc()

@rpc("authority", "call_local", "reliable")
func _delete_client():
    queue_free()

func set_private_value(value: bool):
    is_private = value
    _set_private_value.rpc(value)

@rpc("any_peer", "call_remote", "reliable")
func _set_private_value(value: bool):
    is_private = value
    modulate = Color.BLACK if value else Color.WHITE
