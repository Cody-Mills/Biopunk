extends CharacterBody3D

#MovementSpeed
var speed = 5.0
var sprintSpeed = speed * 1.4
var crouchSpeed = speed * 0.6
var slideSpeed = speed * 2.0
var acceleration = 0.1
#Doubles as the is sprinting check aswell as sliding
var can_slide : bool = false
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

#States
enum {MOVE, CROTCH, SLIDE, JUMP, AIR}
var state

#Head bobbing via Sinewave
const BOB_FREQ = 2.0
const BOB_AMP = 0.08
var t_bob = 0.0

#First Person Looking
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * SENSITIVITY)
		camera_3d.rotate_x(-event.relative.y * SENSITIVITY)
		camera_3d.rotation.x = clamp(camera_3d.rotation.x, deg_to_rad(-40), deg_to_rad(60))

func _headbob(time) -> Vector3:
	var pos  = Vector3.ZERO
	pos.y = sin(time * BOB_FREQ) * BOB_AMP
	pos.x = sin(time * BOB_FREQ / 2) * BOB_AMP
	#could add extra bobs while sprinting
	return pos

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	state = MOVE

func _process(delta: float) -> void:
	print(speed)
	match state:
		MOVE:
			MoveState(delta)

func MoveState(delta):
	jump_available = true
	jump_count = max_jumps
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction := (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	#Walking
	if is_on_floor():
		if direction :
			lerp((speed * sprintSpeed), speed, acceleration)
			can_slide = false
			speed = speed
			velocity.x = direction.x * speed * 10 
			velocity.z = direction.z * speed * 10
		else:
			#Stopping mid air
			velocity.x = lerp(velocity.x, direction.x * speed, delta * 7.0)
			velocity.z = lerp(velocity.z, direction.z * speed, delta * 7.0)
	else:#need to add bhopping
		velocity.x = lerp(velocity.x, direction.x * speed, delta * 2.0)
		velocity.z = lerp(velocity.z, direction.z * speed, delta * 2.0)
	
	#Head Bobbing
	t_bob += delta * velocity.length() * float(is_on_floor())
	camera_3d.transform.origin = _headbob(t_bob)
		
	#if Input.is_action_just_released("ui_sprint"):
		##Adds a slowing down effect
		#lerp((speed * sprintSpeed), speed, acceleration)
		#can_slide = false
	
	move_and_slide()
