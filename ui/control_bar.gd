extends Control

@onready var spawn_card = $VBoxContainer/SpawnCard
@onready var spawn_object = $VBoxContainer/SpawnObject
@onready var spawn_card_pile = $VBoxContainer/SpawnCardPile
@onready var spawn_deck = $VBoxContainer/SpawnDeck

@onready var card_selection = $CardSelection

func _ready():
    spawn_card.pressed.connect(
        func():
            card_selection.show()
            var path = await card_selection.on_card_clicked
            DragDropServer.new_card.rpc(path)
            card_selection.hide())

    spawn_deck.pressed.connect(
        func():
            var path = await Database.choose_path(FileDialog.FILE_MODE_OPEN_FILE)
            DragDropServer.new_card_pile.rpc(path))
