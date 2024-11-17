extends Node3D

var deleteTimer = 10.0
@onready var bloodSplosion: GPUParticles3D = $BloodSplosion
@onready var bloodSploosh: GPUParticles3D = $BloodSploosh
@onready var bonez: GPUParticles3D = $Bonez

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	bloodSplosion.emitting = true
	bloodSploosh.emitting = true
	bonez.emitting = true
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	deleteTimer -= delta
	if(deleteTimer <= 0):
		queue_free()
		deleteTimer = 9999.0 #only queue deletion once
		
