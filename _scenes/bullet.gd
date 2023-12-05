extends KinematicBody2D

var velocity = Vector2()

func _ready():
	pass


func _process(delta):
	velocity = move_and_slide(velocity)


func _on_Area2D_body_entered(body):
	queue_free()


func _on_VisibilityNotifier2D_screen_exited():
	queue_free()
