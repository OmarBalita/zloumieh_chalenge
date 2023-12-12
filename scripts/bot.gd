extends CharacterBody2D


@export_category("Bot Properties")

@export_group("Properties")
@export var health:int = 100 
@export var SPEED:int = 700
@export var Circule_radius:int = 50
@export var Group:String = "White"



@export_group("shoting Properties")

@export var Bullet:PackedScene = preload("res://Scenes/arow.tscn")
@export var cool_down:float = .4



var target = null
var can_fire:bool = true
var mate_in:bool = false


@onready var health_bar = $ProgressBar
@onready var Bot_sprite = $sprites/AnimatedSprite2D
@onready var sprites = $sprites





enum {
	WALK,
	SURROUND,
	ATTACK,
}

var state = WALK
var randomnum




func _ready():
	setup_code()



func update_brogress_bar(): # لتحديث قيمة صحة البوت 
	if !health_bar.visible :
		health_bar.visible = true
	health_bar.value = health


func setup_code(): # يتم استدعاء هذا الكود مرة واحدة في func ready
	$".".add_to_group(Group)#اضافة البوت الى المجموعة المناسبة اما اسود أو ابيض حسب ما حددته انت في الإيديتور
	health_bar.max_value = health # اسناد القيمة العظمى لشريط عرض صحة اللاعب
	
	#انشاء ارقام عشوائية من اجل فنكشن الدائرة 
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	randomnum = rng.randf()
	
	if Group == 'Black':
		$sprites.scale.x = -1


func _physics_process(delta):
	
	
	# لتوجيه سهم البوت الى خصمه يعني الى الtarget
	if target != null :
		$weappon.look_at(target.global_position)
	else :
		$weappon.rotation_degrees = 0
	
	
	
	#لتشغيل الأنميشن المناسب حسب الحركة
	if velocity != Vector2.ZERO :
		Bot_sprite.play("Run")
	elif velocity <= Vector2(20,20) :
		Bot_sprite.play("Idle")
	
	
	
	# هذا الكود لتغيير حالة البوت حسب الstate
	match state:
		WALK :
			walk_to_castle(delta)
		SURROUND:
			move(get_circle_position(randomnum), delta)
		ATTACK:
			Bot_sprite.play("Idle")
			Attack()
	
	avoid(delta)
	move_and_slide()
	
	
	if velocity.x > 0:
		$sprites.scale.x = 1
	elif velocity.x < 0:
		$sprites.scale.x = -1












func Attack():# هذه الفنكشن من اجل الهجوم المستمر و جعلتها هكذا حتى اذا استخدمت الوراثة بالكود لتصنع اعداء بمزايا مختلفة يمكنك تغيير وظيفة هذه الفنكشن فقط لتغيير هجوم البوت
	fire_arrow()

func walk_to_castle(del):# لجعل البوت الأبيض يتحرك لليسار دائما و الأسود يتحرك لليمين دائما
	
	if Group == "White" :
		velocity.x = SPEED
	
	elif Group == "Black" :
		velocity.x = -SPEED
	
	velocity.y = move_toward(velocity.y, .0, del * 10.0)


func move(tarrget, delta):#للتجعل البوت يتحرك نحو هدفه 
	if tarrget != null :
		var direction = (tarrget - global_position).normalized() 
		var desired_velocity =  direction * SPEED
		var steering = (desired_velocity - velocity) * delta * 2.5
		velocity += steering
		move_and_slide()

func get_circle_position(random):# هذا التابع يعيد نقطة تقع على دائرة بشكل عشوائي و مركز الدائرة هو ال target
	if target :
		var kill_circle_centre = target.global_position
		var radius = Circule_radius
		#Distance from center to circumference of circle
		var angle = random * PI * 2;
		var x = kill_circle_centre.x + cos(angle) * radius;
		var y = kill_circle_centre.y + sin(angle) * radius;
		return Vector2(x, y)



func fire_arrow(): #تقوم باطلاق سهم مرة كل ما ينتهي وقت الcool_down يعني لو الcool_down يساوي 1 سيطلق سهم كل ثانية واحدة
	if can_fire and target != null:
		
		var new_bullet = Bullet.instantiate()
		new_bullet.position = $weappon/Arch_tip.get_global_position()
		new_bullet.rotation_degrees = $weappon.rotation_degrees
		
		get_tree().get_root().add_child(new_bullet)
		can_fire = false
		await get_tree().create_timer(cool_down).timeout
		can_fire = true
	


func take_dmg(dmg): # تقوم بانقاص صحة اللاعب اعتمادا على بارامتر الdmg
	health -= dmg
	if health <= 0:
		die()
	update_brogress_bar()












func _on_dmge_area_entered(area): # عند دخول سهم على جسم البوت يتنبه به و يتضرر و ينقص صحته بهذه الفنكشن
	
	if Group == "White" :
		if area.is_in_group("BlackWeapon"):
			take_dmg(area.dmg_scale)
			area.queue_free()
	
	
	elif Group == "Black" :
		if area.is_in_group("WhiteWeapon"):
			take_dmg(area.dmg_scale)
			area.queue_free()
	


func die(): # لجعل البوت يختفي و يحذف من اللعبة
	queue_free()


func _on_spoted_area_body_entered(body):#تجعل البوت يهاجم عندما يدخل جسم غريب عن اصدقائه عليه
	
	if !target:
		
		if Group == "White":
			if body.is_in_group("Black"):
				target = body
				state = ATTACK
				mate_in = true
		
		elif Group == "Black":
			if body.is_in_group("White"):
				target = body
				state = ATTACK
				mate_in = true
	
	velocity.x = 0


func _on_spoted_area_body_exited(body): # لجعل البوت يغير حالته من الهجوم أو اي حالة الى حالة المشي عندما يخرج الخصم من مجال الرؤية
#	if !target  :
	if Group == "White" :
		if body.is_in_group("Black"):
			state = WALK
			target = null
			mate_in = false
	
	elif Group == "Black" :
		if body.is_in_group("White"):
			state = WALK
			target = null
			mate_in = false






func avoid(delta): # لتجنب الأعداء الآخرين لو كانوا أمامي (حتى لا أقف في مكاني) 
	
	if %AvoidRayCast.is_colliding():
		velocity.y = 400
		velocity.x = 0
	else:
		velocity.y = 0



func spawn_coins():
	pass









