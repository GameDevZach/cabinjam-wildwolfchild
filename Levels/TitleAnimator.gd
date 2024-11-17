extends AnimationPlayer

var started: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("GoWild") and started == false:
		started = true
		play("Title|Begin")

func startGame() -> void:
	get_tree().change_scene_to_file("res://Levels/WolfLore.tscn")
