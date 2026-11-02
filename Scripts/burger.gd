extends Node2D
@onready var rigid_body_2d: RigidBody2D = $BurgerBody
@onready var burger: Node2D = $"."

var FoodAmount = 30

signal Eaten
signal LocationFound

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_rigid_body_2d_body_entered(body: Node) -> void:
	if body is StaticBody2D:
		var Location = rigid_body_2d.global_position
		LocationFound.emit(Location)
	if body is RigidBody2D and body.name != "BurgerBody":
		Eaten.emit(FoodAmount)
		burger.queue_free()
