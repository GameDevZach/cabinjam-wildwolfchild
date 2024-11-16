extends RigidBody3D

@export var particles_scene: PackedScene
var isDead: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func die() -> void:
	if(isDead):
		return

	var explosion = particles_scene.instantiate()
	#explosion.position = position + Vector2(200,200)
	get_parent_node_3d().add_child(explosion)
	queue_free()
	isDead = true
