class_name PlayCard
extends ServerCard

@onready var multiplayer_synchronizer = $MultiplayerSynchronizer

#func _ready():
    #multiplayer_synchronizer.set_visibility_for(multiplayer.get_unique_id(), true)
#
#func set_personal_view(value: bool):
    #_set_personal_view.rpc(value)
#
#@rpc("any_peer", "call_local", "reliable")
#func _set_personal_view(value: bool):
    #multiplayer_synchronizer.public_visibility = value
#
#func personal_view_filter(id: int):
    #return id == name.to_int()
