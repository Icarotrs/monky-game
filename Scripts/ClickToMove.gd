extends CharacterBody3D

@onready var navigationAgent := $NavigationAgent3D
@onready var animationPlayer := $AnimationPlayer

var Speed = 1.5

func _process(delta):
	if navigationAgent.is_navigation_finished():
		velocity = Vector3.ZERO
		move_and_slide()
		play_animation("MonkyIdle")
		return
	
	if Input.is_key_pressed(KEY_CTRL):
		velocity = Vector3.ZERO
		move_and_slide()
		play_animation("MonkyIdle")
		return
	
	moveToPoint(delta, Speed)

func moveToPoint(delta, speed):
	var targetPos = navigationAgent.get_next_path_position()
	var direction = global_position.direction_to(targetPos)
	faceDirection(targetPos)
	
	velocity = direction * speed
	move_and_slide()
	play_animation("MonkyWalk")

func faceDirection(direction):
	look_at(Vector3(direction.x, global_position.y, direction.z), Vector3.UP)

func _input(event):
	if Input.is_action_just_pressed("LeftMouse"):
		var camera = $"../CameraAnchor/Camera3D"
		var mousePos = get_viewport().get_mouse_position()
		var rayLenght = 100
		var from = camera.project_ray_origin(mousePos)
		var to = from + camera.project_ray_normal(mousePos) * rayLenght
		var space = get_world_3d().direct_space_state
		var rayQuery = PhysicsRayQueryParameters3D.new()
		rayQuery.from = from
		rayQuery.to = to
		var result = space.intersect_ray(rayQuery)

		if result:
			navigationAgent.target_position = result.position

func play_animation(name: String) -> void:
	if animationPlayer.current_animation != name:
		animationPlayer.play(name)
