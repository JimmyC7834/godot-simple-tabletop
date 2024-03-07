class_name Lobby
extends Control

const PORT = 135
@onready var ip_text = $HBoxContainer/IP
@onready var port_text = $HBoxContainer/Port

var peer: ENetMultiplayerPeer = ENetMultiplayerPeer.new()

signal on_player_added(id: int)
signal on_server_created()

func _on_host_pressed():
    if port_text.text == "":
        port_text.text = str(PORT)
    peer.create_server(port_text.text.to_int())
    multiplayer.multiplayer_peer = peer
    on_server_created.emit()
    peer.peer_connected.connect(func(id): on_player_added.emit(id))

func _on_join_button_down():
    if port_text.text == "":
        port_text.text = str(PORT)
    peer.create_client(ip_text.text, port_text.text.to_int())
    multiplayer.multiplayer_peer = peer
