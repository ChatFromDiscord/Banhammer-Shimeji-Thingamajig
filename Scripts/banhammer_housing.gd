extends Node2D

@onready var banhammer: Node2D = $Banhammer

signal Unfreeze

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var BanhammerDupe = banhammer.duplicate()
	BanhammerDupe.position = Vector2(0,-570)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_banhammer_fell() -> void:
	var BanhammerDupe = banhammer.duplicate()
	BanhammerDupe.position = Vector2(0,-570)
