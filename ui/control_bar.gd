extends Control

@onready var spawn_card = $VBoxContainer/SpawnCard
@onready var spawn_object = $VBoxContainer/SpawnObject

@onready var card_selection = $CardSelection

func _ready():
    spawn_card.pressed.connect(
        func():
            card_selection.show()
            var path = await card_selection.on_card_clicked
            DragDropServer.new_card.rpc(path)
            card_selection.hide())
