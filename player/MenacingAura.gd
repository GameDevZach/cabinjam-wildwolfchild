extends Area3D

var isWild: bool = false

func _on_body_entered(body: Node3D) -> void:
	if(body.name == "MobBody" and isWild):
		body.flee(global_position);
		
func _on_body_exited(body: Node3D) -> void:
	if(body.name == "MobBody"):
		body.stopFleeing();
