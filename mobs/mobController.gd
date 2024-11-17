extends RigidBody3D

@export var particles_scene: PackedScene
var isDead: bool = false
var isFleeing: bool = false
var fleeVector: Vector3
var fleeSpd: float = 60

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _physics_process(delta: float) -> void:
	if(isFleeing):
		apply_central_impulse(fleeSpd * randf() * fleeVector * delta)

func die() -> void:
	if(isDead):
		return

	var explosion = particles_scene.instantiate()
	#explosion.position = position + Vector2(200,200)
	get_parent_node_3d().get_parent_node_3d().add_child(explosion)
	explosion.position = global_position
	queue_free()
	isDead = true
	
func flee(auraPosition: Vector3) -> void:
	isFleeing = true
	fleeVector = (global_position - auraPosition).normalized()
	
func stopFleeing() -> void:
	isFleeing = false
