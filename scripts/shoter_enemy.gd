extends CharacterBody2D

@export_category("Enemy Properties")

@export_group("Properties")
@export var Enemy_helth:int = 150 
@export var dmge:int = 5
@export var SPEED:int = 120
@export var Circule_radius:int = 50


var soul:PackedScene = preload("res://seans/enemy_soul.tscn")


@export_group("shoting Properties")
@export_range(0, 3) var arch_sprite_frame:int = 0


@export var Bullet_dmg:int = 10
@export var Bullet:PackedScene = preload("res://seans/enemys/enemy_arrow.tscn")
@export var cool_down:float = 0.8

var target = null
var can_fire = true
var minimap_icon = "alert"

#@onready var Mazar_sean = preload("res://seans/enemys/mazar.tscn")
#@onready var Parcles = preload("res://seans/enemys/EnemyexplParticles.tscn")

#@onready var Spoted_mark = $spoted
@onready var health_bar = $ProgressBar
@onready var Enmy_sprite = $sprites/AnimatedSprite2D
#@onready var player = get_tree().get_first_node_in_group("player")



var randomnum

var player_spotted = false
var player_in_rang = false

enum {
	WALK,
	SURROUND,
	ATTACK,
}

var state = SURROUND


func update_brogress_bar():
	health_bar.visible = true
	health_bar.value = Enemy_helth

func _ready():
	setup_code()

func setup_code():
	health_bar.max_value = Enemy_helth
	$Enemy_arch/Arch.frame = arch_sprite_frame
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	randomnum = rng.randf()
	Spoted_mark.visible = player_spotted

func _physics_process(delta):
	
	
	if velocity != Vector2.ZERO :
		Enmy_sprite.play("run")
	elif velocity <= Vector2(20,20) :
		Enmy_sprite.play("idle")
	
	
	if velocity.x > 0 :
		Enmy_sprite.flip_h = false
	elif velocity.x < 0 :
		Enmy_sprite.flip_h = true
	
	
	if player_spotted :
		
		match state:
			WALK :
				pass
			SURROUND:
				move(get_circle_position(randomnum), delta)
			ATTACK:
				Attack()

func Attack():
	fire_arrow()

func move(target, delta):
	var direction = (target - global_position).normalized() 
	var desired_velocity =  direction * SPEED
	var steering = (desired_velocity - velocity) * delta * 2.5
	velocity += steering
	move_and_slide()

func get_circle_position(random):
	var kill_circle_centre = player.global_position
	var radius = Circule_radius
	#Distance from center to circumference of circle
	var angle = random * PI * 2;
	var x = kill_circle_centre.x + cos(angle) * radius;
	var y = kill_circle_centre.y + sin(angle) * radius;

	return Vector2(x, y)

func _process(delta):
	$Enemy_arch.look_at(player.global_position)

func fire_arrow():
	if can_fire and player_in_rang:
		var new_bullet = Bullet.instantiate()
		new_bullet.position = $Enemy_arch/Arch_tip.get_global_position()
		new_bullet.rotation_degrees = $Enemy_arch.rotation_degrees
		new_bullet.set_arrow_frame(arch_sprite_frame)
		new_bullet.arrow_dmg = Bullet_dmg
		
		get_tree().get_root().add_child(new_bullet)
		can_fire = false
		await get_tree().create_timer(cool_down).timeout
		can_fire = true


func take_dmge(dmg):
	Enemy_helth -= dmg
	player_spotted = true
	Spoted_mark.visible = player_spotted
	update_brogress_bar()
	$AnimationPlayer.play("Hit")
	#partcles


func _on_area_2d_area_entered(area):
	
	if area.is_in_group("Arrow"):
		take_dmge(Global.Arw_damge)
		area.get_parent().queue_free()
	
	if area.is_in_group("sword"):
		take_dmge(Global.sword_damge)
	
	if Enemy_helth <= 0 :
		die()



func die():
	var new_object = soul.instantiate()
	new_object.position = player.global_position
	get_tree().get_root().add_child(new_object)
	
	var new_partcles = Parcles.instantiate()
	new_partcles.position = global_position
	new_partcles.emitting = true
	get_tree().get_root().add_child(new_partcles)
	
#	var new_sean = Mazar_sean.instantiate()
#	new_sean.position = global_position
#	get_parent().add_child(new_sean)
#	#get_tree().get_root().add_child(new_sean)
	
	queue_free()


func _on_spoted_area_body_entered(body):
	if body.is_in_group("player"):
		player_in_rang = true
		player_spotted = true
		state = ATTACK
		Spoted_mark.visible = player_spotted


func _on_spoted_area_body_exited(body):
	if body.is_in_group("player"):
		player_in_rang = false
		state = SURROUND


