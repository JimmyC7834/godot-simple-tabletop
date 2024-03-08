extends Panel

const WS_SAKURA: CardCollectionRes = preload("res://res/ws_sakura.tres")

const IMG_SCALE: float = 0.5
const FOCUS_HOVER_SPAN: float = 1.0

@export var label: RichTextLabel
@export var card_display: TextureRect
var hovering: bool = false

signal on_card_clicked(texture: Texture2D)

func _ready():
    show_cards(WS_SAKURA.cards)
    
    label.meta_clicked.connect(handle_card_click)
    label.meta_hover_started.connect(hovering_card)
    label.meta_hover_ended.connect(cancel_card_focus.unbind(1))

func hovering_card(path: String):
    hovering = true
    print("focusing")
    await Utils.delay(FOCUS_HOVER_SPAN)
    if hovering:
        print("focused ", path)
        card_display.visible = true
        card_display.texture = Utils.get_texture_by_path(path)

func cancel_card_focus():
    print("cancel focus ")
    hovering = false
    card_display.visible = false    

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
