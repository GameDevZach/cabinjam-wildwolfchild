extends CharacterBody3D


const BASE_SPEED = 5.0
const SPRINT_SPEED = 20.0
var curSpeed = 5.0
const SPRINT_TIME = 5.0
var sprintTimer = 0.0
var stamina = 100.0
var animState = "Idle"

const JUMP_VELOCITY = 4.5
@onready var charNode: Node3D = $CharRotator
@onready var cameraRotator: Node3D = $CameraRotator
@onready var camera: Camera3D = $CameraRotator/Camera3D
@onready var playerAnimator: AnimationPlayer = $CharRotator/player/AnimationPlayer
@onready var cameraAnimator: AnimationPlayer = $CameraRotator/Camera3D/AnimationPlayer
@onready var BaseMusicStream: AudioStreamPlayer = $CameraRotator/Camera3D/BaseMusicStream
@onready var WildMusicStream: AudioStreamPlayer = $CameraRotator/Camera3D/WildMusicStream
@onready var MenacingAura: Area3D = $Area3D
@onready var StaminaBar: ProgressBar = $Control/ProgressBar

func _ready() -> void: 
	cameraAnimator.speed_scale = 0.75
	playerAnimator.play("PlayerArmature|Idle")

func _input(event):
	if(event is InputEventMouseMotion):
		cameraRotator.rotate_y(-event.relative.x / 100)

func _physics_process(delta: float) -> void:
	StaminaBar.value = stamina
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	if sprintTimer > 0:
		sprintTimer -= delta
		stamina -= delta * 5
		if(sprintTimer <= 0 or stamina <= 0):
			sprintTimer = 0
			curSpeed = BASE_SPEED
			cameraAnimator.speed_scale = 0.75
			WildMusicStream.volume_db = -80.0
			BaseMusicStream.volume_db = 0.0
			MenacingAura.isWild = false
	elif stamina < 100:
		stamina += delta * 2

	# Handle WILD.
	if Input.is_action_just_pressed("GoWild") and stamina > 20 and sprintTimer <= 0.0:#is_on_floor():
		curSpeed = SPRINT_SPEED
		sprintTimer = SPRINT_TIME
		cameraAnimator.speed_scale = 1.5
		WildMusicStream.volume_db = 0.0
		BaseMusicStream.volume_db = -80.0
		MenacingAura.isWild = true
		#velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("Left", "Right", "Up", "Down")
	var direction := (cameraRotator.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		if(animState == "Idle"):
			playerAnimator.play("PlayerArmature|Run",0.5,2)
			animState = "Run"
		velocity.x = direction.x * curSpeed
		velocity.z = direction.z * curSpeed
		var dir_angle = -Vector2(direction.x,direction.z).angle()
		charNode.rotation.y = lerp_angle(charNode.rotation.y, dir_angle, (curSpeed * 0.5)*delta)
	else:
		velocity.x = move_toward(velocity.x, 0, curSpeed)
		velocity.z = move_toward(velocity.z, 0, curSpeed)
		if(sprintTimer <= 0 and animState == "Run"):
			playerAnimator.play("PlayerArmature|Idle",0.3)
			animState = "Idle"

	move_and_slide()
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		var collider_name = collider.name

		if(sprintTimer > 0 and collider_name != "StaticBody3D"):
			if(collider_name == "MobBody"):
				collider.die()
