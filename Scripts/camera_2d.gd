extends Node2D
@onready var banhammer_housing: Node2D = $"."

@onready var burger: Node2D = $Burger
var BURGER = preload("uid://dv8o1ptspfovt")

var CameraZoom = Vector2(0.386,0.386)
var PreviousMousePos = Vector2(0,0)

var ClickingState = false
var AttemptingToPickUp = false

signal BurgerSummoned

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if ClickingState == false:
			ClickingState = true
			if AttemptingToPickUp == false:
				var MousePos = get_global_mouse_position()
				var BurgerClone = BURGER.duplicate().instantiate()
				banhammer_housing.add_child(BurgerClone)
				BurgerClone.global_position = MousePos
				BurgerSummoned.emit(BurgerClone)
			elif AttemptingToPickUp == true:
				print("dont")
		elif ClickingState == true:
			ClickingState = false

func _on_banhammer_pick_upable(State) -> void:
	AttemptingToPickUp = State
