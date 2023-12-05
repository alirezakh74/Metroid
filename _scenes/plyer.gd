extends KinematicBody2D

export var run_speed = 100
export var jump_speed = -400
export var fall_speed = 5

var velocity = Vector2()
var jumping = false
var shooting = false
var can_shoot = true
var player_gravity : gravity

var facing_right = true

onready var animation = $AnimatedSprite
onready var ground = $CheckGroundRayCast
onready var ground2 = $CheckGroundRayCast2

export (PackedScene) var bullet


func _ready():
	$AnimatedSprite.play("shoot")
	player_gravity = gravity.new()


func _physics_process(delta):
	move()
	animtion_player()
	
	velocity.y += player_gravity.gravity * delta
	
	if (ground.is_colliding() or ground2.is_colliding()) and velocity.y > 0:
		velocity.y = 0
	if animation.animation == "shoot" or animation.animation == "run_shoot":
		if animation.get_frame() == (animation.frames.get_frame_count("shoot") - 1):
			shooting = false
	move_and_slide(velocity, Vector2(0, -1))


func move():
	velocity.x = 0
	var left = Input.is_action_pressed("ui_left")
	var right = Input.is_action_pressed("ui_right")
	var jump = Input.is_action_just_pressed("ui_accept")
	var shoot = Input.is_action_pressed("shoot")
	
	if jump and (ground.is_colliding() or ground2.is_colliding()):
		jumping = true
		velocity.y = jump_speed
	else:
		jumping = false
	if right:
		velocity.x += run_speed
		facing_right = true
	if left:
		velocity.x -= run_speed
		facing_right = false
		
	if shoot:
		if velocity.y == 0:
			shooting = true
			if can_shoot:
				fire_weapon()



func animtion_player():
	if !jumping and !shooting and velocity.y == 0:
		if velocity.x != 0:
			animation.play("run")
		else:
			animation.play("idle")
		# active stand collision shape
		$StandCollisionShape.set_deferred("disabled", false)
		$JumpCollisionShape.set_deferred("disabled", true)
		
	if animation.animation == "run" and velocity.y > 0:
		animation.stop()
	
	if jumping:
		animation.play("jump")
		$JumpCollisionShape.set_deferred("disabled", false)
		$StandCollisionShape.set_deferred("disabled", true)
	
	if shooting and velocity.y == 0:
		if  velocity.x == 0:
			animation.play("shoot")
		else:
			animation.play("run_shoot")
	
	# set current direction of player(left or right dir)
	animation.flip_h = !facing_right


func fire_weapon():
	if can_shoot:
		var b = bullet.instance()
		if facing_right:
			b.position = $MuzzleGunPos.global_position
			b.velocity.x = 400
		else:
			b.position = Vector2(($MuzzleGunPos.global_position.x - ($MuzzleGunPos.position.x * 2)), $MuzzleGunPos.global_position.y)
			b.velocity.x = -400
		owner.add_child(b)
		can_shoot = false
		$FireRateTimer.start()



func _on_FireRateTimer_timeout():
	can_shoot = true
