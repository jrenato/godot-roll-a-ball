extends Area3D


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body : Node3D) -> void:
	if body.name == "Player":
		get_tree().reload_current_scene()
