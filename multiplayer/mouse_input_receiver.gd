extends Node

func _input(event):
    if multiplayer.is_server():
        #if event is InputEventMouseMotion:
            #print("input received ", event)
        pass
    else:
        if event is InputEventMouseMotion:
            MouseInputReceiver.mouse_move.rpc(
                event.position, event.relative, event.velocity)
        elif event is InputEventMouseButton:
            MouseInputReceiver.mouse_button.rpc(
                event.position, event.button_index, event.canceled, event.pressed, event.double_click)

@rpc("any_peer", "reliable")
func mouse_button(position: Vector2, button_index: MouseButton, canceled: bool, pressed: bool, double_click: bool):
    var e = InputEventMouseButton.new()
    e.global_position = position
    e.position = position
    e.button_index = button_index
    e.canceled = canceled
    e.pressed = pressed
    e.double_click = double_click
    #print("pushed mouse event ", e)
    Input.parse_input_event(e)

@rpc("any_peer", "reliable")
func mouse_move(position: Vector2, relative: Vector2, velocity: Vector2):
    var e = InputEventMouseMotion.new()
    e.global_position = position
    e.position = position
    e.relative = relative
    e.velocity = velocity
    #print("pushed mouse event ", e)
    Input.parse_input_event(e)
