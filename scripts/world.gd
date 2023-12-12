extends Node2D


@export var grid_size := 64

@onready var enemies = %Enemies
@onready var cursor = %Cursor
@onready var camera = %Camera2D

@onready var btns_box = %BTNSBox
@onready var control_panel = %ControlPanel # الcontrol panel هو المكان الذي يمكننا من خلاله إختيار الشخصيات 

var can_spawn_enemies := true



var enemies_types :=\
{
	"رامي سهام" : preload("res://Scenes/bot.tscn"),
	"مقاتل" : preload("res://Scenes/sword_bot.tscn"),
	"مدافع" : preload("res://Scenes/deff_bot.tscn"),
	"تنين" : preload("res://Scenes/dragon_bot.tscn"),
	"أوتاد" : preload("res://Scenes/2awtad.tscn"),
	"رامي سهام أسود" : preload("res://Scenes/black_bot.tscn"),
	"مقاتل أسود" : preload("res://Scenes/black_sword_bot.tscn"),
	"مدافع أسود" : preload("res://Scenes/black_deff_bot.tscn"),
	"تنين أسود" : preload("res://Scenes/black_dragon_bot.tscn")
}

var type := ""

var fulled_positions := []


func _ready():
	get_tree().paused = true
	
	# إذا تم الضغط على أي من الأزار سيتم تغيير النوع إلى نوع العدو 
	for btn in btns_box.get_children():
		btn.connect("enemy_btn_pressed", enemy_type_selected)
	
	cursor.size = Vector2.ONE * grid_size


func _physics_process(delta):
	
	var mouse_pos = get_global_mouse_position()
	
	spawn_manager(mouse_pos)
	
	if Input.is_action_just_pressed("Add") and get_tree().paused:
		spawn_enemy(mouse_pos)
	
	cursor.position = snapped(mouse_pos - Vector2.ONE * grid_size/2, Vector2.ONE * grid_size) # إلحاق مكان المؤشر بمكان الماوس 


# هالحكي الفاضي عشان لو دخلت الماوس على الcontrol panel ما نقدر نرسبن أعداء يا حبايبي 
# وسلملي عالمحشي 
func spawn_manager(mouse_pos : Vector2):
	
	var window_size = get_viewport_rect().size
	var globl_mouse_pos = mouse_pos.y - camera.position.y + (window_size.y/2/camera.zoom.y)
	var max_spawn_area = (window_size.y - control_panel.size.y) / camera.zoom.y
	
	can_spawn_enemies = (globl_mouse_pos < max_spawn_area)




func spawn_enemy(mouse_pos : Vector2):
	
	if can_spawn_enemies: # لو كانت الماوس خارج الcontrol panel سنستطيع إضافة الأعداء 
		
		var pos = cursor.position
		pos.x += grid_size/2 
		
		var snapped_mouse_pos = snapped(mouse_pos, Vector2.ONE * grid_size)
		var in_game_area = snapped_mouse_pos.y == clamp(snapped_mouse_pos.y, -1024, 1024)
		
		if in_game_area and !fulled_positions.has(pos) and enemies_types.has(type): # لو كان المكان الذي أضع فيه العدو غير ممتلئ ولو كان النوع صحيحا ولو كان مكان الماوس في إطار اللعبة يمكننا إضافة عدو 
			
			var enemy = enemies_types.get(type).instantiate()
			
			enemy.position = pos
			enemy.z_index = pos.y
			enemies.add_child(enemy)
			
			if get_tree().paused:
				fulled_positions += [pos] # نضيف الموقع الخاص بالعدو إلى المصفوفة حتى لا يتم وضع الأعداء فوق بعضهم 
			
			return
		
		for enemy in enemies.get_children(): # مهمة هذه الدالة حذف العدو الذي يقف عند المؤشر 
			if enemy.position == pos:
				enemy.queue_free()
				fulled_positions.erase(pos)




func enemy_type_selected(_type : String):
	type = _type


func _on_game_area_body_exited(body):
	body.queue_free()







func _on_play_btn_pressed():
	%PlayBTN.text = "بدأت اللعبة"
	
	get_tree().paused = false
	fulled_positions.clear()


func _on_enemy_type_pressed():
	
	%EnemyType.text = "أسود" if %EnemyType.text == "أبيض" else "أبيض"
	
	for btn in btns_box.get_children():
		if btn.button_pressed:
			type = btn.enemy_name if %EnemyType.text == "أبيض" else btn.black_enemy_name









