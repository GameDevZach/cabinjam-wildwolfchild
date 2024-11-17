extends CharacterBody3D


const BASE_SPEED = 5.0
const SPRINT_SPEED = 20.0
var curSpeed = 5.0
const SPRINT_TIME = 5.0
var sprintTimer = 0.0
var stamina = 100.0
var animState = "Idle"
var actualScore = 0
var displayScore = -1
var capturingMouse: bool = true
var timeRemaining: float = 68.0
var isStopped: bool = false

const JUMP_VELOCITY = 4.5
@onready var charNode: Node3D = $CharRotator
@onready var cameraRotator: Node3D = $CameraRotator
@onready var camera: Camera3D = $CameraRotator/CamAdjustor/Camera3D
@onready var playerAnimator: AnimationPlayer = $CharRotator/player/AnimationPlayer
@onready var cameraAnimator: AnimationPlayer = $CameraRotator/CamAdjustor/Camera3D/AnimationPlayer
@onready var BaseMusicStream: AudioStreamPlayer = $CameraRotator/CamAdjustor/Camera3D/BaseMusicStream
@onready var WildMusicStream: AudioStreamPlayer = $CameraRotator/CamAdjustor/Camera3D/WildMusicStream
@onready var MenacingAura: Area3D = $Area3D
@onready var StaminaBar: ProgressBar = $Control/ProgressBar
@onready var ScoreLabel: Label = $Control/ScoreLabel
@onready var TimeLabel: Label = $Control/TimeLabel

func _ready() -> void: 
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	cameraAnimator.speed_scale = 0.75
	playerAnimator.play("PlayerArmature|Idle")

func _input(event):
	if(event is InputEventMouseMotion):
		cameraRotator.rotate_y(-event.relative.x / 100)

func _physics_process(delta: float) -> void:
	if(isStopped):
		return
	StaminaBar.value = stamina
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	if displayScore < actualScore:
		displayScore += 1
		ScoreLabel.text = str(displayScore)
	timeRemaining -= delta
	if(timeRemaining <= 60):
		if(timeRemaining >= 0):
			TimeLabel.text = str(round(timeRemaining))
		else:
			StopFunc()
			isStopped = true
		

	if sprintTimer > 0:
		sprintTimer -= delta
		stamina -= delta * 5
		if(sprintTimer <= 0 or stamina <= 0):
			sprintTimer = 0
			curSpeed = BASE_SPEED
			cameraAnimator.speed_scale = 0.75
			#WildMusicStream.volume_db = -80.0
			#BaseMusicStream.volume_db = 0.0
			BaseMusicStream.pitch_scale = 1
			MenacingAura.isWild = false
			if(animState == "Frenzy"):
				if(velocity.length() <= 0.01):
					animState = "Idle"
					playerAnimator.play("PlayerArmature|Idle",0.2)
				else:
					animState = "Run"
					playerAnimator.play("PlayerArmature|Run",0.2,1.55)
	elif stamina < 100:
		stamina += delta * 2

	# Handl mouse capture
	if Input.is_action_just_pressed("Esc"):
		if(capturingMouse):
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			capturingMouse = false
		else:
			capturingMouse = true
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	# Handle WILD.
	if Input.is_action_just_pressed("GoWild") and stamina > 20 and sprintTimer <= 0.0:#is_on_floor():
		curSpeed = SPRINT_SPEED
		sprintTimer = SPRINT_TIME
		cameraAnimator.speed_scale = 1.5
		#WildMusicStream.volume_db = 0.0
		#BaseMusicStream.volume_db = -80.0
		BaseMusicStream.pitch_scale = 2
		MenacingAura.isWild = true
		playerAnimator.play("PlayerArmature|Frenzy1",0.25,2)
		animState = "Frenzy"
		#velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("Left", "Right", "Up", "Down")
	var direction := (cameraRotator.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		if(animState == "Idle"):
			playerAnimator.play("PlayerArmature|Run",0.25,1.55)
			animState = "Run"
		velocity.x = direction.x * curSpeed
		velocity.z = direction.z * curSpeed
		var _theta = wrapf(atan2(direction.x, direction.z) - charNode.rotation.y, -PI, PI)
		charNode.rotation.y += clamp(max(5,curSpeed * 0.5) * delta, 0, abs(_theta)) * sign(_theta)
		#charNode.rotation.y = lerp_angle(charNode.global_rotation.y, dir_angle, (curSpeed * 0.5)*delta)
	else:
		velocity.x = move_toward(velocity.x, 0, curSpeed)
		velocity.z = move_toward(velocity.z, 0, curSpeed)
		if(sprintTimer <= 0 and animState != "Idle" and sprintTimer <= 0):
			playerAnimator.play("PlayerArmature|Idle",0.3)
			animState = "Idle"

	move_and_slide()
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		var collider_name = collider.name

		if(sprintTimer > 0 and collider_name != "StaticBody3D"):
			if(collider_name == "MobBody"):
				if(collider.die()):
					stamina = min(100,stamina + 10)
					actualScore += 20
					cameraAnimator.play("cam_kill")
					cameraAnimator.queue("cam_idle")
					
func StopFunc() -> void:
	cameraAnimator.play("finish")
	if(animState == "Frenzy" or animState == "Run"):
		animState = "Idle"
		playerAnimator.play("PlayerArmature|Idle",0.2)
