extends CharacterBody3D

#MovementSpeed
var speed
const SPRINT_SPEED = WALK_SPEED * 1.4
var is_sprinting : bool = false
const WALK_SPEED = 5.0
const CROUCH_SPEED = WALK_SPEED * 0.6
var is_crouching : bool = false
const SLIDE_SPEED = WALK_SPEED * 2
var is_sliding : bool = false

#Jumping
const JUMP_VELOCITY = 4.5
var jump_count = max_jumps
var max_jumps = 1 #scaleable
var jump_available : bool = true

const SENSITIVITY = 0.004

@onready var head: Node3D = %Head
@onready var camera_3d: Camera3D = %Camera3D
@onready var player: CharacterBody3D = $"."


#Head bobbing via Sinewave
const BOB_FREQ = 2.0
const BOB_AMP = 0.08
var t_bob = 0.0


#Wanted features 
#-wall jumping(different basis than normal jumping cuz instead of jumping up i wanna kick off of 
# a wall and be send the other direction (need a wall made for jumping off of)
# could either do it by making a actual wall jump or by kicking, if kicking i could use the get function
# method go recive how much knockback there should be so i can use it for enemies, walls and jumping walls
#-Sliding
#-Bunny Hopping




func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * SENSITIVITY)
		camera_3d.rotate_x(-event.relative.y * SENSITIVITY)
		camera_3d.rotation.x = clamp(camera_3d.rotation.x, deg_to_rad(-40), deg_to_rad(60))
		

func _physics_process(delta: float) -> void:
	print(speed)
	# Handle jump.
	if !is_on_floor():
		velocity += get_gravity() * delta
		jump_available = false
	if is_on_floor():
		jump_available = true
		jump_count = max_jumps
		
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		_jump()
		
	if is_on_wall_only() && Input.is_action_just_pressed("ui_accept"):
		print("wall jump")
	
	#Sprinting
	if Input.is_action_pressed("ui_sprint") && is_on_floor():
		speed = SPRINT_SPEED
		is_sprinting = true
	else:
		speed = WALK_SPEED
		is_sprinting = false
	#Crouching
	if Input.is_action_pressed("ui_crouch") && !is_sprinting:
		$CollisionShape3D.scale = Vector3(1, 0.5, 1)
		speed = CROUCH_SPEED
		is_crouching = true
	if Input.is_action_just_released("ui_crouch"):
		$CollisionShape3D.scale = Vector3(1, 1, 1)
		speed = WALK_SPEED
		is_crouching = false
	#Sliding (need to make it move forward constantly)
	#if Input.is_action_pressed("ui_crouch") && is_sprinting :
		#$CollisionShape3D.scale = Vector3(1, 0.3, 1)
		#speed = SLIDE_SPEED
		#is_sliding = true
	#if Input.is_action_just_released("ui_crouch") && is_sliding:
		#is_sliding = false
		#speed = WALK_SPEED
		#$CollisionShape3D.scale = Vector3(1, 1, 1)
	#Movement Inputs
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction := (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if is_on_floor():
		if direction:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
		else:
			#stopping mid air
			velocity.x = lerp(velocity.x, direction.x * speed, delta * 7.0)
			velocity.z = lerp(velocity.z, direction.z * speed, delta * 7.0)
	else:#need to add bhopping
		velocity.x = lerp(velocity.x, direction.x * speed, delta * 2.0)
		velocity.z = lerp(velocity.z, direction.z * speed, delta * 2.0)
	
	#Head Bobbing
	t_bob += delta * velocity.length() * float(is_on_floor())
	camera_3d.transform.origin = _headbob(t_bob)
	
	move_and_slide()
	

func _headbob(time) -> Vector3:
	var pos  = Vector3.ZERO
	pos.y = sin(time * BOB_FREQ) * BOB_AMP
	pos.x = sin(time * BOB_FREQ / 2) * BOB_AMP
	return pos


func _jump():
	if jump_count != 0:
		velocity.y = JUMP_VELOCITY
		jump_count -= 1
	else:
		jump_available = false
