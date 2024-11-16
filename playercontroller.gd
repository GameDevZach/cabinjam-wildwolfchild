extends CharacterBody3D


const BASE_SPEED = 5.0
const SPRINT_SPEED = 20.0
var curSpeed = 5.0
const SPRINT_TIME = 5.0
var sprintTimer = 0.0
var stamina = 100.0

const JUMP_VELOCITY = 4.5
@onready var charNode: Node3D = $CharRotator
@onready var cameraRotator: Node3D = $CameraRotator
@onready var camera: Camera3D = $CameraRotator/Camera3D

func _input(event):
	if(event is InputEventMouseMotion):
		cameraRotator.rotate_y(-event.relative.x / 100)

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	if sprintTimer > 0:
		sprintTimer -= delta
		stamina -= delta * 5
		if(sprintTimer <= 0):
			curSpeed = BASE_SPEED
	elif stamina < 100:
		stamina += delta * 2

	# Handle WILD.
	if Input.is_action_just_pressed("GoWild") and stamina > 20 and sprintTimer <= 0.0:#is_on_floor():
		curSpeed = SPRINT_SPEED
		sprintTimer = SPRINT_TIME
		#velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("Left", "Right", "Up", "Down")
	var direction := (cameraRotator.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * curSpeed
		velocity.z = direction.z * curSpeed
		var dir_angle = -Vector2(direction.x,direction.z).angle()
		charNode.rotation.y = lerp_angle(charNode.rotation.y, dir_angle, 2*delta)
	else:
		velocity.x = move_toward(velocity.x, 0, curSpeed)
		velocity.z = move_toward(velocity.z, 0, curSpeed)

	move_and_slide()
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		var collider_name = collider.name

		if(collider_name != "StaticBody3D"):
			print("I collided with ", collider_name)
			if(collider_name == "MobBody"):
				collider.die()
