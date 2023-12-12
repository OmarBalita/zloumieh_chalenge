extends CharacterBody2D



@export_category("Bot Properties")

@export_group("Properties")
@export var group := "White"
@export var dmg_scale := 8.0
@export var health := 70
var SPEED := 900



@onready var health_bar = $ProgressBar
@onready var Bot_sprite = $sprites/AnimatedSprite2D
@onready var sprites = $sprites
@onready var sword_anim_player = $weappon/AnimationPlayer




enum {
	TO_CASTLE,
	TO_ENEMY,
	ATTACK,
}

var state = TO_CASTLE


var spoted_enemies := []





func _ready():
	setup_code()



func update_progress_bar(): # لتحديث قيمة صحة البوت 
	if !health_bar.visible :
		health_bar.visible = true
	health_bar.value = health


func setup_code(): # يتم استدعاء هذا الكود مرة واحدة في func ready
	$".".add_to_group(group)#اضافة البوت الى المجموعة المناسبة اما اسود أو ابيض حسب ما حددته انت في الإيديتور
	health_bar.max_value = health # اسناد القيمة العظمى لشريط عرض صحة اللاعب
	
	if group == 'Black':
		$sprites.scale.x = -1


func _physics_process(delta):
	
	
	#لتشغيل الأنميشن المناسب حسب الحركة
	
	
	# هذا الكود لتغيير حالة البوت حسب الstate
	match state:
		TO_CASTLE:
			walk_to_castle(delta)
		TO_ENEMY:
			move(delta)
		ATTACK:
			Bot_sprite.play("Idle")
			Attack(delta)
	
	
	move_and_slide()
	
	if velocity.x > 0:
		$sprites.scale.x = 1
	elif velocity.x < 0:
		$sprites.scale.x = -1












func Attack(delta : float): # هذه الفنكشن من اجل الهجوم المستمر و جعلتها هكذا حتى اذا استخدمت الوراثة بالكود لتصنع اعداء بمزايا مختلفة يمكنك تغيير وظيفة هذه الفنكشن فقط لتغيير هجوم البوت
	
	if spoted_enemies.size() == 0:
		sword_anim_player.play("RESET")
		state = TO_CASTLE
		return
	
	velocity = lerp(velocity, Vector2.ZERO, 10 * delta)
	sword_anim_player.play("Attack")


func dmg_enemy(): # يتم إستدعاء هذه الدالة في الAnimation Player 
	
	if spoted_enemies.size() > 0:
		
		var target = spoted_enemies[0]
		
		if target.health <= dmg_scale:
			Bot_sprite.play("Run")
			state = TO_ENEMY
		
		target.take_dmg(dmg_scale)


func walk_to_castle(del): # لجعل البوت الأبيض يتحرك لليسار دائما و الأسود يتحرك لليمين دائما
	
	Bot_sprite.play("Run")
	velocity.x = SPEED * (1 if group == "White" else -1)
	velocity.y = 0



func move(delta): #للتجعل البوت يتحرك نحو هدفه 
	
	# لتوجيه سيف البوت الى خصمه يعني الى الtarget
	if spoted_enemies.size() > 0:
		
		var target = spoted_enemies[0].global_position
		
		$weappon.look_at(target)
		
		var dist = target - global_position
		var desired_velocity = dist.normalized() * SPEED
		var steering = (desired_velocity - velocity) * delta * 2.5
		velocity += steering
		
		if global_position.distance_to(target) < 200:
			state = ATTACK
		
		
	else:
		$weappon.rotation_degrees = -30
		state = TO_CASTLE





















func _on_dmge_area_entered(area): # عند دخول سهم على جسم البوت يتنبه به و يتضرر و ينقص صحته بهذه الفنكشن
	
	if dmg_conditions(area):
		take_dmg(area.dmg_scale)
		area.queue_free()



# شروط أن يتم ضربي أن يكون السلاح لعدوي 
func dmg_conditions(area) -> bool:
	
	if (is_in_group("White") and area.is_in_group("BlackWeapon")) or (is_in_group("Black") and area.is_in_group("WhiteWeapon")):
		return true
	return false



func take_dmg(dmg): # تقوم بانقاص صحة اللاعب اعتمادا على بارامتر الdmg
	health -= dmg
	if health <= 0:
		die()
	update_progress_bar()


func die(): # لجعل البوت يختفي و يحذف من اللعبة
	queue_free()


















func _on_spoted_area_body_entered(body):
	if is_enemy(body):
		Bot_sprite.play("Run")
		spoted_enemies.append(body)
	
	state = TO_ENEMY

func _on_spoted_area_body_exited(body):
	if is_enemy(body):
		spoted_enemies.erase(body)


func is_enemy(body : Node2D): # وظيفة هذه الدالة التأكد لو أن الجسم الذي دخل هو عدو أم لا 
	var i_am_white = is_in_group("White")
	var body_is_black = body.is_in_group("Black")
	
	return i_am_white == body_is_black
