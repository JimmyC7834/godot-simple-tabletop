extends Panel

const WS_SAKURA: CardCollectionRes = preload("res://res/ws_sakura.tres")

const IMG_SCALE: float = 0.5

@export var label: RichTextLabel

signal on_card_clicked(texture: Texture2D)

func _ready():
    show_cards(WS_SAKURA.cards)
    
    label.meta_clicked.connect(handle_card_click)

func show_cards(textures: Array[Texture2D]):
    if len(textures) == 0: return
    
    var img_size = textures[0].get_size() * IMG_SCALE
    var img_size_text = "%dx%d" % [img_size.x, img_size.y]
    label.text = ""
    for t in textures:
        var p = t.resource_path
        label.text += "[url=%s][img=%s]%s[/img][/url]" % [p, img_size_text, p]

func handle_card_click(meta):
    print("selected ", meta)
    on_card_clicked.emit(meta)
