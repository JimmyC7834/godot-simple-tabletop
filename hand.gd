class_name Hand
extends Node2D

@onready var hand = $Hand


@export_category("Curves")

@export var spread_curve : Curve
@export var scale_curve : Curve
@export var y_curve : Curve
@export var rotation_curve : Curve
@export var tint_gradient : Gradient

@export var selection_offset: int
@export var selection_scale: Vector2
@export var spread: int
@export var y_spread: int
@export var card_rotation: float
@export var tween_duration: float

func _ready():
    register_cards()
    process_all_card()

func _process(_delta):
    #if Input.is_action_just_pressed("ScrollUp") && hand.get_child_count() > 0:
        #hand.move_child(hand.get_children().pop_front(), hand.get_child_count() - 1)
        #process_all_card()
    #elif Input.is_action_just_pressed("ScrollDown") && hand.get_child_count() > 0:
        #hand.move_child(hand.get_children().pop_back(), 0)
        #process_all_card()
    pass

func register_cards():
    for c in hand.get_children():
        register_card(c)
        #c.set_personal_view(true)

func register_card(c: Node2D):
    if c is DragDropObject:
        #c.on_cursor_exited.connect(process_all_card)
        c.on_cursor_hovered.connect(process_all_card)
        #c.mouse_exited.connect(process_all_card)
        #c.on_dropped.connect(func(_x): process_all_card())

func add_card(c: Node2D):
    hand.add_child(c)
    hand.move_child(c, hand.get_children().size() / 2)
    register_card(c)
    process_all_card()

func remove_card(c: Node2D):
    hand.remove_child(c)
    process_all_card()

func process_all_card():
    for c in hand.get_children().filter(func(x): return x is Node2D):
        process_card(c)

func process_card(card: Node2D):
    var card_index = hand.get_children().find(card)
    #if picking(card_index): return
    
    var _rotation: float = cal_card_rotation(card_index)
    var _position: Vector2 = cal_card_position(card_index)
    var _scale: Vector2 = cal_card_scale(card_index)
    var _color: Color = cal_card_tint(card_index)
    
    var span: float = tween_duration
    #if hovering(card_index):
        #card.z_index = 10
    #else:
        #card.z_index = 0
    
    var tween = card.create_tween().set_parallel(true).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
    if hand.get_child_count() > 1:
        tween.tween_property(card, "rotation", _rotation, span)
    tween.tween_property(card, "position", _position, span)
    tween.tween_property(card, "scale", _scale, span)
    tween.tween_property(card, "modulate", _color, span)

    #card.on_hovered.connect(func():
        #tween.pause()
        #tween.custom_step(1.0))
    #card.on_mouse_pressed.connect(func():
        #tween.pause()
        #tween.custom_step(1.0))

func cal_card_position(i: int) -> Vector2:
    if hand.get_child_count() == 1:
        return Vector2(0, 0)
    var card_count: int = hand.get_child_count() - 1
    var ratio: float = float(i) / card_count
    var x: float = spread_curve.sample(ratio) * spread * card_count
    var y: float = y_curve.sample(ratio) * y_spread * card_count
    #if hovering(i):
        #y += selection_offset
    return Vector2(x, -y)

func cal_card_scale(i: int) -> Vector2:
    #if hovering(i):
        #return selection_scale
    var card_count: int = hand.get_child_count() - 1
    var ratio: float = float(i) / card_count
    var s: float = scale_curve.sample(ratio)
    return Vector2(s, s)

func cal_card_tint(i: int) -> Color:
    #if hovering(i):
        #return Color.WHITE
    var card_count: int = hand.get_child_count() - 1
    var ratio: float = abs(0.5 - (float(i) / card_count)) / 0.5
    var c: Color = tint_gradient.sample(ratio)
    return c

func cal_card_rotation(i: int) -> float:
    #if hovering(i): return 0
    
    var card_count: int = hand.get_child_count() - 1
    var ratio: float = float(i) / card_count
    var r: float = rotation_curve.sample(ratio) * card_rotation * card_count
    return r

#func hovering(i: int):
    #return DragDrop.hovering == hand.get_child(i)
#
#func picking(i: int):
    #return DragDrop.picking == hand.get_child(i)
