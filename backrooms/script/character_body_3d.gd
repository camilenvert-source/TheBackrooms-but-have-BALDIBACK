extends CharacterBody3D

@onready var camera_3d: Camera3D = $Head/Camera3D
@onready var stamina_bar: ProgressBar = $"../CanvasLayer/StaminaBar"  # ← yol sahnene göre değişebilir

const WALK_SPEED = 3.0
const SPRINT_SPEED = 6.0

const JUMP_VELOCITY = 4.5
var mouse_sensitivity: float = 0.002

const MAX_STAMINA = 100.0
const STAMINA_DRAIN_RATE = 25.0   # saniyede ne kadar azalır
const STAMINA_REGEN_RATE = 15.0   # saniyede ne kadar dolar
const STAMINA_REGEN_DELAY = 1.0   # koşmayı bırakınca dolmaya başlama gecikmesi

var stamina: float = MAX_STAMINA
var regen_timer: float = 0.0
var can_sprint: bool = true

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if stamina_bar:
		stamina_bar.max_value = MAX_STAMINA
		stamina_bar.value = stamina

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * mouse_sensitivity)
		camera_3d.rotate_x(-event.relative.y * mouse_sensitivity)
		camera_3d.rotation.x = clamp(camera_3d.rotation.x, deg_to_rad(-89), deg_to_rad(89))

	if event.is_action_pressed("ui_cancel"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var input_dir := Input.get_vector("a", "d", "w", "s")
	var is_moving = input_dir.length() > 0.1
	var wants_sprint = Input.is_action_pressed("sprint") and is_moving

	var current_speed = WALK_SPEED

	if wants_sprint and stamina > 0 and can_sprint:
		current_speed = SPRINT_SPEED
		stamina -= STAMINA_DRAIN_RATE * delta
		regen_timer = STAMINA_REGEN_DELAY
		if stamina <= 0:
			stamina = 0
			can_sprint = false  # stamina bitti, kısa süre koşamaz
	else:
		if regen_timer > 0:
			regen_timer -= delta
		else:
			stamina += STAMINA_REGEN_RATE * delta
			stamina = min(stamina, MAX_STAMINA)
			if stamina > MAX_STAMINA * 0.2:  # %20 dolunca tekrar koşabilir
				can_sprint = true

	if stamina_bar:
		stamina_bar.value = stamina

	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)

	move_and_slide()
	move_and_slide()
