extends RigidBody3D

@export var particles_scene: PackedScene
var isDead: bool = false
var isFleeing: bool = false
var fleeVector: Vector3
var fleeSpd: float = 60

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	rotation.y = randf_range(0,360)
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	

func die() -> bool:
	if(isDead):
		return false

	var explosion = particles_scene.instantiate()
	get_parent_node_3d().get_parent_node_3d().add_child(explosion)
	explosion.position = global_position
	queue_free()
	isDead = true
	return false
	
func flee(auraPosition: Vector3) -> void:
	pass
	
func stopFleeing() -> void:
	pass
