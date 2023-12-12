extends Camera2D


@export var zoom_force := Vector2.ONE * .05

var zoom_min := .2
var zoom_max := 3.0

var zoom_val := Vector2()
var pos_val := Vector2()


func _input(event : InputEvent):
	
	
	if event is InputEventMouseMotion:
		
		# تحريك الكاميرا باستخدام الماوس 
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		if Input.is_action_pressed("move_cam"):
			pos_val -= event.relative / zoom
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	var lim := Vector2(5000, 1500) * zoom
	pos_val.x = clamp(pos_val.x, -lim.x, lim.x)
	pos_val.y = clamp(pos_val.y, -lim.y, lim.y)
	
	
	
	if event is InputEventMouseButton:
		
		# zoom in و zoom out
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			zoom_val += zoom_force
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			zoom_val -= zoom_force
	
	zoom_val = clamp(zoom_val, Vector2.ONE * .2, Vector2.ONE * 1.0)


func _physics_process(delta):
	
	position = lerp(position, pos_val, 20.0 * delta)
	zoom = lerp(zoom, zoom_val, 20.0 * delta)























