extends CharacterBody3D

@export var speed: float = 5.0
var player: Node3D = null
var caught: bool = false

@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D

func _ready():
	var players = get_tree().get_nodes_in_group("player")
	print("Bulunan oyuncu sayısı: ", players.size())
	if players.size() > 0:
		player = players[0]
		print("Oyuncu atandı: ", player.name)
	nav_agent.path_desired_distance = 0.5
	nav_agent.target_desired_distance = 0.5

func _physics_process(delta):
	if not player or caught:
		return

	if not is_on_floor():
		velocity.y -= 9.8 * delta
	else:
		velocity.y = 0.0

	nav_agent.target_position = player.global_position

	print("nav_finished: ", nav_agent.is_navigation_finished())  # ← ekle

	if nav_agent.is_navigation_finished():
		velocity.x = 0.0
		velocity.z = 0.0
		move_and_slide()
		return

	var next_path_pos = nav_agent.get_next_path_position()
	var direction = next_path_pos - global_position
	direction.y = 0.0

	print("next_path_pos: ", next_path_pos, " | kendi pos: ", global_position, " | direction uzunluk: ", direction.length())  # ← ekle

	if direction.length() > 0.05:
		direction = direction.normalized()
		look_at(global_position + direction, Vector3.UP)
		rotate_y(deg_to_rad(180))
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = 0.0
		velocity.z = 0.0

	move_and_slide()

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("player") and not caught:
		caught = true
		velocity = Vector3.ZERO
		print("YAKALANDI!")
		get_tree().call_deferred("reload_current_scene")  # ← değişiklik burada
