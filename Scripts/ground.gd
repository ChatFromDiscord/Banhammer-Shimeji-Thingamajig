extends Node2D

@onready var static_body_2d: StaticBody2D = $StaticBody2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	static_body_2d.physics_material_override.friction = 1
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_banhammer_changing_movement(amount) -> void:
	static_body_2d.physics_material_override.friction = amount
