extends Node2D

@export_category("Properties")
@export var speed = 2000
@export var dmg_scale = 5
@export var group:String = "WhiteWeapon"


func _ready():
	add_to_group(group)# اضافة السهم لمجموعة حتى يستطيع اصابة البوت باللون المختلف عنه 
	await get_tree().create_timer(5).timeout
	queue_free()

func _process(delta):
	move_arrow(delta)

func move_arrow(del):# لجعل السهم يتحرك
	position += (Vector2.RIGHT*speed).rotated(rotation) * del

func _on_area_2d_body_entered(body):#لجعل السهميختفي عند لمس جدار أو اي جسم في مجموعة ال"Wall" 
	if body.is_in_group("Wall"):
		queue_free()
