extends RigidBody3D

@export var particles_scene: PackedScene
@export var idleAnimation: String
@export var runAnimation: String
@onready var animPlayer: AnimationPlayer = $MobMesh/AnimationPlayer
var isDead: bool = false
var isFleeing: bool = false
var fleeVector: Vector3
var fleeSpd: float = 80

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	animPlayer.play(idleAnimation)
	animPlayer.speed_scale = randf_range(0.8,1.2)
	rotation.y = randf_range(0,360)
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _physics_process(delta: float) -> void:
	if(isFleeing):
		apply_central_impulse(fleeSpd * randf() * fleeVector * delta)
		var _theta = wrapf(atan2(linear_velocity.x, linear_velocity.z) - rotation.y, -PI, PI)
		rotation.y += clamp(5 * delta, 0, abs(_theta)) * sign(_theta)

func die() -> bool:
	if(isDead):
		return false

	var explosion = particles_scene.instantiate()
	#explosion.position = position + Vector2(200,200)
	get_parent_node_3d().get_parent_node_3d().add_child(explosion)
	explosion.position = global_position
	queue_free()
	isDead = true
	return true
	
func flee(auraPosition: Vector3) -> void:
	isFleeing = true
	animPlayer.play(runAnimation,0.2)
	fleeVector = (global_position - auraPosition).normalized()
	apply_central_impulse(fleeSpd * randf() * fleeVector * 0.1)
	
func stopFleeing() -> void:
	animPlayer.play(idleAnimation,0.1)
	isFleeing = false
