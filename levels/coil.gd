extends Area3D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

@export var force: int = 800


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node3D) -> void:
	if body.name == "Player":
		body.apply_central_force(Vector3.UP * force)
		animation_player.play("trigger")
		animation_player.queue("rearm")
