extends CharacterBody3D

@export var speed := 10
@export var jump_strength := 9.0
@export var gravity_factor := 2.0
@export var steepness_dot := 0.5
@export var rotation_trigger_length := 1.0

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity") * gravity_factor
var velocity := Vector3.ZERO
var snap_vector := Vector3.DOWN
var spring_arm_translation := Vector3.ZERO

@onready var spring_arm : SpringArm3D = $SpringArm3D
@onready var model : MeshInstance3D = $Model

func _ready():
	spring_arm_translation = spring_arm.position

func _physics_process(delta: float) -> void:
	
	var on_steep = false
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		if collision.normal.dot(Vector3.UP) < steepness_dot:
			on_steep = true
			break
		
	var move_direction := Vector3.ZERO
	
	move_direction.x = Input.get_action_strength("right") - Input.get_action_strength("left")
	move_direction.z = Input.get_action_strength("back") - Input.get_action_strength("forward")
	
	if Input.is_mouse_button_pressed(1) and Input.is_mouse_button_pressed(2):
		move_direction.z = -1
	
	move_direction = move_direction.rotated(Vector3.UP, spring_arm.rotation.y).normalized()
	
	velocity.x = move_direction.x * speed
	velocity.z = move_direction.z * speed
	velocity.y -= gravity * delta
	
	var just_landed := is_on_floor() and snap_vector == Vector3.ZERO
	var is_jumping := is_on_floor() and Input.is_action_just_pressed("jump")
	if is_jumping:
		velocity.y = jump_strength
		snap_vector = Vector3.ZERO
	elif just_landed:
		snap_vector = Vector3.DOWN
	
	if not on_steep:
		set_velocity(velocity)
		# TODOConverter40 looks that snap in Godot 4.0 is float, not vector like in Godot 3 - previous value `snap_vector`
		set_up_direction(Vector3.UP)
		set_floor_stop_on_slope_enabled(true)
		move_and_slide()
		velocity = velocity
	else:
		set_velocity(velocity)
		# TODOConverter40 looks that snap in Godot 4.0 is float, not vector like in Godot 3 - previous value `snap_vector`
		set_up_direction(Vector3.UP)
		set_floor_stop_on_slope_enabled(true)
		move_and_slide()
		var intermediate := velocity
		velocity.x = intermediate.x
		velocity.z = intermediate.z
	
	var horizontal_movement = Vector2(-velocity.z, -velocity.x)
	if horizontal_movement.length() > rotation_trigger_length:
		rotation.y = horizontal_movement.angle()

func _process(_delta: float) -> void:
	spring_arm.position = position + spring_arm_translation
