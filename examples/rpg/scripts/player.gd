class_name Player extends CharacterBody2D

@export var speed: float = 60.0

@onready var sprite: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var current_location : PPLocationEntity
var current_direction: Vector2 = Vector2.DOWN
var is_moving: bool = false
var last_npc : NPC = null

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept") and last_npc:
		last_npc.interact()

func _physics_process(_delta: float) -> void:
	# Get input direction
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")

	# Update velocity
	velocity = input_dir * speed

	# Update animation based on movement
	if input_dir != Vector2.ZERO:
		is_moving = true
		current_direction = input_dir
		update_animation()
	else:
		is_moving = false
		set_idle_frame()

	# Move the character
	move_and_slide()

func update_animation() -> void:
	# Determine which direction the player is facing
	if abs(current_direction.x) > abs(current_direction.y):
		# Moving horizontally
		if current_direction.x > 0:
			animation_player.play("right")
		else:
			animation_player.play("left")
	else:
		# Moving vertically
		if current_direction.y > 0:
			animation_player.play("down")
		else:
			animation_player.play("up")

func set_idle_frame() -> void:
	# Set idle frame based on last direction
	animation_player.stop()

	if abs(current_direction.x) > abs(current_direction.y):
		if current_direction.x > 0:
			sprite.frame = 3
		else:
			sprite.frame = 2
	else:
		if current_direction.y > 0:
			sprite.frame = 0
		else:
			sprite.frame = 1

func _on_interactable_area_body_entered(body: Node2D) -> void:
	if body is NPC:
		last_npc = body

func _on_interactable_area_body_exited(body: Node2D) -> void:
	if body is NPC:
		last_npc = null
