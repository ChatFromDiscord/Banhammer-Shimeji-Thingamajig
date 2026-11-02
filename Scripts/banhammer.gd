extends Node2D

@onready var move_timer: Timer = $MoveTimer
@onready var move_chance_timer: Timer = $MoveChanceTimer
@onready var drag_timer: Timer = $DragTimer
@onready var air_checker: Timer = $AirChecker
@onready var stable_timer: Timer = $StableTimer
@onready var hunger_timer: Timer = $HungerTimer
@onready var eating_timer: Timer = $EatingTimer

@onready var Banhammer: Node2D = $"."
@onready var rigid_body_2d: RigidBody2D = $RigidBody2D
@onready var sprite_2d: Sprite2D = $RigidBody2D/Sprite2D
@onready var checker: Timer = $Checker
@onready var timer: Timer = $Timer
@onready var sleep_timer: Timer = $SleepTimer
@onready var SleepAmountTimer: Timer = $SleepAmount
@onready var Rope: Sprite2D = $Rope

const SITTING = preload("uid://bwdb1mhv1c65g")
const WALKING = preload("uid://5c7561hw8bqy")
const SLEEPING = preload("uid://ctmx1yqfob5fq")
const RELAXING = preload("uid://dd8t7dh1nqdl8")

var CurrentState = "Sitting"
var WalkingSize = Vector2(0.092,0.088)
var SittingSize = Vector2(1.773,1.733)
var SleepingSize = Vector2(0.165,0.141)
var SleepingPosition = Vector2(0,38)
var RelaxingSize = Vector2(0.398,0.433)

var Fallen = false
var Stable = true

var RNG = RandomNumberGenerator.new()
var MaxSleep = 100
var Sleep = MaxSleep
var CanSleep = true

var MaxFood =  150
var DefaultFood = 100
var Food = DefaultFood
var MinimumFood = -50

var ChanceToMove = 20
var ChanceToJump = 70
var CanMove = true

var MouseState = false
var PickUp = false
var PickedUp = false
var CurrentlyBeingFlung = false

signal ChangingMovement
signal PickUpable

@warning_ignore("unused_parameter")
func _process(delta: float) -> void:
	if CurrentState != "Sleeping":
		sprite_2d.position = Vector2(0,0)
	pass

func SleepingSpriteChange():
	CurrentState = "Sleeping"
	sprite_2d.texture = SLEEPING
	sprite_2d.scale = SleepingSize
	sprite_2d.position = SleepingPosition

func RelaxingSpriteChange():
	CurrentState = "Being Grabbed"
	sprite_2d.texture = RELAXING
	sprite_2d.scale = RelaxingSize

func EatingSpriteChange():
	CurrentState = "Eating"
	sprite_2d.texture = RELAXING
	sprite_2d.scale = RelaxingSize

func SillyJump():
	var Speed = RNG.randi_range(50,100)
	rigid_body_2d.linear_velocity = Vector2(0,Speed*(-5))
	Food -= 5

func RandomDirection():
	var Direction = RNG.randi_range(1,2) ## 1 = left, 2 = Right
	var Amount = RNG.randi_range(1,5) ## seconds
	var Speed = RNG.randi_range(50,200)
	move_timer.wait_time = Amount
	move_timer.start()
	Food -= (Amount*Speed)/50
	Speed = Speed*(float(Food)/float(DefaultFood))
	if Food < 0:
		Speed = Speed*float(0.01)
	if Direction == 1:
		_on_ground_moving(false)
		rigid_body_2d.linear_velocity = Vector2(Speed,0)
	else:
		_on_ground_moving(true)
		rigid_body_2d.linear_velocity = Vector2(Speed*(-1),0)
	move_chance_timer.stop()
	ChangingMovement.emit(0)

func _on_move_timer_timeout() -> void:
	move_timer.stop()
	move_chance_timer.start()
	_on_ground_stopping()
	ChangingMovement.emit(1)

func _on_move_chance_timer_timeout() -> void:
	var RandomChance = RNG.randi_range(1,100)
	if RandomChance <= ChanceToMove and CanMove == true:
		ChanceToMove = 20
		RandomDirection()
	elif RandomChance > ChanceToJump and CanMove == true:
		if Food > 50:
			SillyJump()
	elif RandomChance > ChanceToMove and CanMove == true:
		ChanceToMove += 10
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	CurrentState = "Sitting"
	sprite_2d.texture = SITTING
	sprite_2d.scale = SittingSize
	sprite_2d.position = Vector2(0,0)

func _integrated_forces(state) -> void:
	state.transform.origin = Vector2(0,0)

func _on_ground_moving(Direction) -> void:
	CurrentState = "Moving"
	if Direction == true:
		sprite_2d.flip_h = true
	else:
		sprite_2d.flip_h = false
	sprite_2d.texture = WALKING
	sprite_2d.scale = WalkingSize
	sprite_2d.position = Vector2(0,0)

func _on_ground_stopping() -> void:
	CurrentState = "Sitting"
	if sprite_2d.flip_h == true:
		sprite_2d.flip_h = false
	elif sprite_2d.flip_h == false:
		sprite_2d.flip_h = true
	sprite_2d.texture = SITTING
	sprite_2d.scale = SittingSize
	sprite_2d.position = Vector2(0,0)


@warning_ignore("unused_parameter")
func _on_rigid_body_2d_body_exited(body: Node) -> void: ######################################################
	CanSleep = false
	stable_timer.stop()
	if Fallen == false and PickedUp == false and body.name != "BurgerBody":
		CanMove = false
		checker.wait_time = 2
		Fallen = true
		checker.start()

@warning_ignore("unused_parameter")
func _on_rigid_body_2d_body_entered(body: Node) -> void: 
	if Stable == false and PickedUp == false and body.name != "BurgerBody":
		stable_timer.start()
	elif Stable == true:
		checker.wait_time = 2
		Fallen = false
		checker.start()

func _on_stable_timer_timeout() -> void:
	stable_timer.stop()
	Stable = true
	checker.wait_time = 2
	Fallen = false
	CurrentlyBeingFlung = false
	checker.start()
	_on_ground_stopping()
	print("Stabilised")

func _on_checker_timeout() -> void:
	if Stable == true:
		checker.stop()
		if Fallen == true:
			if timer.is_stopped() != true:
				timer.stop()
			CanMove = false
			rigid_body_2d.linear_velocity.y = (rigid_body_2d.linear_velocity.y) * -1.5
			rigid_body_2d.linear_velocity.x = (rigid_body_2d.linear_velocity.x) * -1.5
			CurrentlyBeingFlung = true
		elif Fallen == false:
			timer.start()

func _on_timer_timeout() -> void:
	if round(rigid_body_2d.rotation_degrees) == 0:
		rigid_body_2d.angular_velocity = 0
		timer.stop()
		CanMove = true
		CanSleep = true
		if Sleep <= 0:
			SleepAmountTimer.start()
			SleepingSpriteChange()
			CanMove = false
	if round(rigid_body_2d.rotation_degrees) != 0:
		if rigid_body_2d.position.x > 0:
			rigid_body_2d.angular_velocity = -10
		elif rigid_body_2d.position.x < 0:
			rigid_body_2d.angular_velocity = 10 ########################################################


func _on_sleep_timer_timeout() -> void:
	var TirednessChance = RNG.randi_range(1,100)
	if TirednessChance > 30:
		var TiredAmount = RNG.randi_range(1,5)
		Sleep -= TiredAmount
	if Sleep <= 0 and CanSleep == true:
		_on_move_timer_timeout()
		SleepingSpriteChange()
		sleep_timer.stop()
		CanMove = false
		SleepAmountTimer.start()
		print("Going to Sleep")

func _on_sleep_amount_timeout() -> void:
	CanMove = false
	print("Attempted to Sleep")
	if CanSleep == true:
		Sleep = MaxSleep
		CanMove = true
		sleep_timer.start()
		SleepAmountTimer.stop()
		_on_ground_stopping()
		print("Fully Rested")

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if MouseState == false:
			MouseState = true
			if PickUp == true:
				Stable = false
				PickedUp = true
				CanMove = false
				
				Rope.visible = true
				
				rigid_body_2d.angular_velocity = 0
				timer.stop()
				
				move_timer.stop()
				move_chance_timer.start()
				RelaxingSpriteChange()
				ChangingMovement.emit(1)
				drag_timer.start()
		elif MouseState == true and event.button_mask == 0:
			MouseState = false
			if PickedUp == true:
				Rope.visible = false
				PickedUp = false
				drag_timer.stop()

func _on_drag_timer_timeout() -> void:
	CanMove = false
	var MousePos = get_global_mouse_position()
	rigid_body_2d.linear_velocity = MousePos - rigid_body_2d.position
	Rope.look_at(MousePos)
	Rope.global_position = (MousePos + rigid_body_2d.global_position)/2
	var test = rigid_body_2d.global_position.distance_to(MousePos)
	Rope.scale.x = test/800

func _on_rigid_body_2d_mouse_entered() -> void:
	PickUp = true
	PickUpable.emit(true)

func _on_rigid_body_2d_mouse_exited() -> void:
	PickUp = false
	PickUpable.emit(false)

func _on_air_checker_timeout() -> void:
	if rigid_body_2d.position.x < -2000 or rigid_body_2d.position.x > 2000:
		rigid_body_2d.linear_velocity.y = (rigid_body_2d.position.y) * -0.1
		rigid_body_2d.linear_velocity.x = (rigid_body_2d.position.x) * -1
	if rigid_body_2d.position.y > 2000:
		rigid_body_2d.linear_velocity.y = (rigid_body_2d.position.y) * -1
		rigid_body_2d.linear_velocity.x = (rigid_body_2d.position.x) * -0.1
		print(rigid_body_2d.position)

func _on_hunger_timer_timeout() -> void:
	var RandomChance = RNG.randi_range(1,100)
	if RandomChance > 40:
		var RandomFoodLoss = RNG.randi_range(1,3)
		Food -= RandomFoodLoss
		if Food < MinimumFood:
			Food = MinimumFood

func FoodAdded(AmountAdded):
	Food += AmountAdded
	if Food > MaxFood:
		Food = MaxFood

func _on_burger_eaten(AmountAdded) -> void:
	FoodAdded(AmountAdded)
	SleepingSpriteChange()
	ChangingMovement.emit(1)
	move_timer.stop()
	move_chance_timer.start()
	eating_timer.start()
	CanMove = false

func _on_eating_timer_timeout() -> void:
	eating_timer.stop()
	_on_ground_stopping()

func _on_banhammer_housing_burger_summoned(Burger) -> void:
	Burger.Eaten.connect(_on_burger_eaten)
