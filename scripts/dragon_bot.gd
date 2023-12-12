extends CharacterBody2D


var speed := 1500.0
var fire_dist := 800.0
@export var Group := "White"



var spoted_enemies : Array

enum
{
	move_to_castle,
	move_to_enemy,
	attack
}

var state = 0

var health : float = 160

@onready var health_bar = %ProgressBar
@onready var sprites = %Sprites
@onready var shot_spawner = %ShotSpawner


func _ready():
	setup_code()

func setup_code():
	add_to_group(Group)
	flip_by_group()








func _physics_process(delta):
	
	match state:
		
		move_to_castle:
			to_castle(delta * 20.0)
			stop_motion(delta)
			
		move_to_enemy:
			if spoted_enemies.size() > 0:
				to_enemy(delta * 20.0)
			else:
				state = move_to_castle
				
		attack:
			fire()
			stop_motion(delta * 10.0)
	
	
	
	move_and_slide()













func to_castle(delta : float):
	
	velocity.x = speed * delta * (1 if Group == "White" else -1)
	velocity.y = move_toward(velocity.y, .0, delta * 10.0)
	flip_by_group()


func to_enemy(delta : float):
	
	var pos_delta = spoted_enemies[0].global_position - global_position
	sprites.scale.x = .7 if pos_delta.x > 0 else -.7
	
	if abs(pos_delta.length()) <= fire_dist: # لو كانت المسافة بيني وبين العدو أقل من المدى المجدي يمكن إطلاق النار 
		state = attack
		return
	
	var dir = pos_delta.normalized() * speed * delta
	velocity = dir




@export var fire_ball := preload("res://Scenes/fire_ball.tscn")
var fire_rate := .8
var can_shot = 1.0

func fire():
	
	if spoted_enemies.size() == 0:
		state = move_to_castle
		return
	
	if can_shot:
		shot_spawner.look_at(spoted_enemies[0].global_position)
		
		var FireBall = fire_ball.instantiate()
		FireBall.global_position = shot_spawner.global_position
		FireBall.rotation_degrees = shot_spawner.rotation_degrees
		get_tree().get_root().add_child(FireBall)
		
		# not sus animation
		Global.sus_tween_anim(self, "scale")
		
		can_shot = false
		await get_tree().create_timer(fire_rate).timeout
		can_shot = true















func stop_motion(delta : float):
	velocity = lerp(velocity, Vector2.ZERO, delta)

func take_dmg(dmg : float): # تقوم بانقاص صحة اللاعب اعتمادا على بارامتر الdmg
	
	health -= dmg
	if health <= 0:
		queue_free()
	
	update_progress_bar()


func update_progress_bar(): # لتحديث قيمة صحة البوت 
	if !health_bar.visible:
		health_bar.visible = true
	health_bar.value = health


func flip_by_group(): # يغير إتجاه التنين بناءا على نوعه أبيض أو أسود 
	sprites.scale.x = .7 * (1 if Group == "White" else -1)
















func _on_spoting_area_body_entered(body):
	
	if is_enemy(body):
		spoted_enemies.append(body)
	
	state = move_to_enemy


func _on_spoting_area_body_exited(body):
	
	if is_enemy(body):
		spoted_enemies.erase(body)
	
	if spoted_enemies.size() == 0:
		state = move_to_castle


func is_enemy(body : Node2D): # وظيفة هذه الدالة التأكد لو أن الجسم الذي دخل هو عدو أم لا 
	var i_am_white = is_in_group("White")
	var body_is_black = body.is_in_group("Black")
	
	return i_am_white == body_is_black













func _on_dmge_area_entered(area):
	
	if dmg_conditions(area):
		take_dmg(area.dmg_scale)
		area.queue_free()


# شروط أن يتم ضربي أن يكون السلاح لعدوي 
func dmg_conditions(area) -> bool:
	
	if (is_in_group("White") and area.is_in_group("BlackWeapon")) or (is_in_group("Black") and area.is_in_group("WhiteWeapon")):
		return true
	return false













