extends SpringArm3D

@export var mouse_sensitivity := 0.05
@export var joystick_y_sensitivity := 2.5
@export var joystick_x_sensitivity := 1

var mouse_position = Vector2.ZERO

var using_controller = false

func _ready() -> void:
	set_as_top_level(true)
	
func _unhandled_input(event):
	# Mouse camera toggle
	if event is InputEventMouseButton:
		if event.get_button_index() == 2:
			if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
				Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
				Input.warp_mouse(mouse_position)
			else:
				mouse_position = event.position
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		# Mouse scroll zoom:
		if event.get_button_index() == MOUSE_BUTTON_WHEEL_UP:
			spring_length -= 0.5
		if event.get_button_index() == MOUSE_BUTTON_WHEEL_DOWN:
			spring_length += 0.5
		
		spring_length = clamp(spring_length, 2, 20)
	
	# Mouse camera movement:
	if event is InputEventMouseMotion and using_controller == true:
		using_controller = false
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		Input.warp_mouse(mouse_position)
		
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotation_degrees.x -= event.relative.y * mouse_sensitivity
		rotation_degrees.y -= event.relative.x * mouse_sensitivity
		
		rotation_degrees.x = clamp(rotation_degrees.x, -90, 30)
		rotation_degrees.y = wrapf(rotation_degrees.y, 0, 360)
	
func _physics_process(_delta):
	# Gamepad Zoom:
	if Input.is_action_pressed("zoom_on_joypad"):
		spring_length += Input.get_action_strength("look_down") - Input.get_action_strength("look_up")
		spring_length = clamp(spring_length, 2, 20)
	else:
	# Gamepad camera movement:
		var joystick_camera_activity = Input.get_action_strength("look_down") + Input.get_action_strength("look_up") + Input.get_action_strength("look_left") + Input.get_action_strength("look_right")
		
		if joystick_camera_activity > 0.25 and Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
			using_controller = true
			mouse_position = get_viewport().get_mouse_position()
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		
		rotation_degrees.x -= (Input.get_action_strength("look_down") - Input.get_action_strength("look_up")) * joystick_x_sensitivity
		rotation_degrees.y -= (Input.get_action_strength("look_right") - Input.get_action_strength("look_left")) * joystick_y_sensitivity
		
		rotation_degrees.x = clamp(rotation_degrees.x, -90, 30)
		rotation_degrees.y = wrapf(rotation_degrees.y, 0, 360)

