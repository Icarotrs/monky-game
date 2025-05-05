extends Node3D

const DRAG_SPEED := 0.01
const ZOOM_MIN := 3.0
const ZOOM_MAX := 15.0
const ZOOM_STEP := 0.3

@onready var cam: Camera3D = $Camera3D
@onready var player: Node3D = get_parent().get_node("Player")  # Acessa o Player corretamente

var screen_ratio: float
var dragging: bool = false
var dragging_left: bool = false
var centering: bool = false  # Flag para centralização suave

var right_vec: Vector3
var forward_vec: Vector3

func _ready() -> void:
	screen_ratio = float(get_viewport().get_visible_rect().size.y) / float(get_viewport().get_visible_rect().size.x)
	_get_move_vectors()

func _get_move_vectors() -> void:
	var offset: Vector3 = cam.global_position - global_position
	right_vec = cam.transform.basis.x
	forward_vec = Vector3(offset.x, 0, offset.z).normalized()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var e := event as InputEventMouseButton

		if e.button_index == MOUSE_BUTTON_WHEEL_UP or e.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			if dragging:
				return
			var zoom_dir := -1.0 if e.button_index == MOUSE_BUTTON_WHEEL_UP else 1.0
			cam.size = clamp(cam.size + ZOOM_STEP * zoom_dir, ZOOM_MIN, ZOOM_MAX)

		else:
			if e.pressed:
				# Ativa o drag com CTRL + botão esquerdo
				if e.button_index == MOUSE_BUTTON_LEFT and Input.is_key_pressed(KEY_CTRL):
					dragging = true
					dragging_left = true
				# Ativa o drag com botão direito (para rotação)
				elif e.button_index == MOUSE_BUTTON_RIGHT:
					dragging = true
					dragging_left = false
			else:
				dragging = false

	elif event is InputEventMouseMotion and dragging:
		var m := event as InputEventMouseMotion

		if dragging_left:
			global_position += cam.global_transform.basis.x * -m.relative.x * DRAG_SPEED
			global_position += forward_vec * -m.relative.y * DRAG_SPEED / screen_ratio
		else:
			rotate_y(-m.relative.x * 0.5 * DRAG_SPEED)
			_get_move_vectors()

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("center_camera"):
		centering = true

	if centering and player:
		var target_position = player.global_position
		# Centraliza apenas no plano XZ
		global_position.x = move_toward(global_position.x, target_position.x, delta * 5)
		global_position.z = move_toward(global_position.z, target_position.z, delta * 5)

		if global_position.distance_to(Vector3(target_position.x, global_position.y, target_position.z)) < 0.1:
			centering = false
